const std = @import("std");
const testing = std.testing;
const mem = std.mem;
const Allocator = std.mem.Allocator;

// Minimal idioms exercises — validates key Zig patterns and gotchas.
// Run: zig test path/to/idioms.zig

// 1. Allocator pattern (arena, GPA)
test "allocator: arena for batch allocation" {
    const page_allocator = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(page_allocator);
    defer arena.deinit(); // Frees EVERYTHING allocated from this arena

    const alloc = arena.allocator();

    // Allocate multiple things -- no need to free individually
    const buf1 = try alloc.alloc(u8, 100);
    const buf2 = try alloc.alloc(u8, 200);
    const buf3 = try alloc.alloc(u8, 300);

    buf1[0] = 'A';
    buf2[0] = 'B';
    buf3[0] = 'C';
    try testing.expectEqual(@as(u8, 'A'), buf1[0]);
    try testing.expectEqual(@as(u8, 'B'), buf2[0]);
    try testing.expectEqual(@as(u8, 'C'), buf3[0]);
}

// 2. Generic type function pattern
fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        items: []T,
        len: usize,
        allocator: Allocator,

        pub fn init(allocator: Allocator, capacity: usize) !Self {
            return .{
                .items = try allocator.alloc(T, capacity),
                .len = 0,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }

        pub fn push(self: *Self, value: T) !void {
            if (self.len >= self.items.len) return error.StackOverflow;
            self.items[self.len] = value;
            self.len += 1;
        }

        pub fn pop(self: *Self) ?T {
            if (self.len == 0) return null;
            self.len -= 1;
            return self.items[self.len];
        }
    };
}

test "generic: comptime type parameter returns struct type" {
    const gpa = testing.allocator;
    var stack = try Stack(i32).init(gpa, 10);
    defer stack.deinit();

    try stack.push(1);
    try stack.push(2);
    try stack.push(3);

    try testing.expectEqual(@as(?i32, 3), stack.pop());
    try testing.expectEqual(@as(?i32, 2), stack.pop());
    try testing.expectEqual(@as(?i32, 1), stack.pop());
    try testing.expectEqual(@as(?i32, null), stack.pop());
}

// 3. Vtable/interface pattern
const Drawable = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    const VTable = struct {
        area: *const fn (ptr: *anyopaque) f64,
    };

    pub fn area(self: Drawable) f64 {
        return self.vtable.area(self.ptr);
    }
};

const Circle = struct {
    radius: f64,

    pub fn area(self: *const Circle) f64 {
        return std.math.pi * self.radius * self.radius;
    }

    pub fn drawable(self: *Circle) Drawable {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &.{
                .area = &typeErasedArea,
            },
        };
    }

    fn typeErasedArea(ptr: *anyopaque) f64 {
        const self: *Circle = @ptrCast(@alignCast(ptr));
        return self.area();
    }
};

const Rectangle = struct {
    width: f64,
    height: f64,

    pub fn area(self: *const Rectangle) f64 {
        return self.width * self.height;
    }

    pub fn drawable(self: *Rectangle) Drawable {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &.{
                .area = &typeErasedArea,
            },
        };
    }

    fn typeErasedArea(ptr: *anyopaque) f64 {
        const self: *Rectangle = @ptrCast(@alignCast(ptr));
        return self.area();
    }
};

test "vtable: type-erased interface pattern" {
    var circle = Circle{ .radius = 5.0 };
    var rect = Rectangle{ .width = 3.0, .height = 4.0 };

    const shapes = [_]Drawable{
        circle.drawable(),
        rect.drawable(),
    };

    try testing.expectApproxEqAbs(@as(f64, 78.539816), shapes[0].area(), 0.001);
    try testing.expectApproxEqAbs(@as(f64, 12.0), shapes[1].area(), 0.001);
}

// 4. Iterator pattern (next() returning ?T)
const RangeIterator = struct {
    current: u32,
    end: u32,
    step: u32,

    pub fn init(start: u32, end: u32, step: u32) RangeIterator {
        return .{ .current = start, .end = end, .step = step };
    }

    pub fn next(self: *RangeIterator) ?u32 {
        if (self.current >= self.end) return null;
        const val = self.current;
        self.current += self.step;
        return val;
    }
};

test "iterator: next() returns ?T, null signals end" {
    var iter = RangeIterator.init(0, 5, 1);
    var sum: u32 = 0;

    while (iter.next()) |val| {
        sum += val;
    }

    try testing.expectEqual(@as(u32, 10), sum); // 0+1+2+3+4
}

// 5. Sentinel-terminated slice handling
test "sentinel: [:0]const u8 — null accessible at [len]" {
    const hello: [:0]const u8 = "hello";
    try testing.expectEqual(@as(usize, 5), hello.len);
    // The sentinel IS accessible past the end
    try testing.expectEqual(@as(u8, 0), hello[hello.len]);

    // mem.span converts sentinel-terminated pointer to slice
    const c_string: [*:0]const u8 = "hello world";
    const slice = mem.span(c_string);
    try testing.expectEqualStrings("hello world", slice);
}

// 6. errdefer cleanup pattern
test "errdefer: cleanup only runs on error path" {
    const gpa = testing.allocator;
    const S = struct {
        fn mayFail(allocator: Allocator, should_fail: bool) ![]u8 {
            const data = try allocator.alloc(u8, 10);
            errdefer allocator.free(data); // Only runs if we return an error
            if (should_fail) return error.Oops;
            return data;
        }
    };

    // Success path: caller is responsible for freeing
    const data = try S.mayFail(gpa, false);
    defer gpa.free(data);
    try testing.expectEqual(@as(usize, 10), data.len);

    // Error path: errdefer frees automatically, no leak
    try testing.expectError(error.Oops, S.mayFail(gpa, true));
}

// 7. Writer interface pattern
const CountingWriter = struct {
    bytes_written: usize,

    const Writer = std.io.GenericWriter(*CountingWriter, error{}, write);

    fn write(self: *CountingWriter, bytes: []const u8) error{}!usize {
        self.bytes_written += bytes.len;
        return bytes.len;
    }

    fn writer(self: *CountingWriter) Writer {
        return .{ .context = self };
    }
};

test "writer: custom GenericWriter implementation" {
    var counter = CountingWriter{ .bytes_written = 0 };
    const w = counter.writer();

    _ = try w.write("hello");
    try w.print("value: {d}\n", .{42});

    // "hello" (5) + "value: 42\n" (10) = 15
    try testing.expectEqual(@as(usize, 15), counter.bytes_written);
}

// 8. Comptime string operations
test "comptime: comptimePrint for compile-time string formatting" {
    const msg = std.fmt.comptimePrint("size of u64 is {d} bytes", .{@sizeOf(u64)});
    try testing.expectEqualStrings("size of u64 is 8 bytes", msg);
}

// 9. @fieldParentPtr for intrusive data structures
test "@fieldParentPtr: recover containing struct from field pointer" {
    const Node = struct {
        value: u32,
        hook: Hook,

        const Hook = struct {
            next: ?*Hook,
        };

        fn fromHook(hook: *Hook) *@This() {
            return @fieldParentPtr("hook", hook);
        }
    };

    var node = Node{ .value = 42, .hook = .{ .next = null } };
    const recovered = Node.fromHook(&node.hook);
    try testing.expectEqual(@as(u32, 42), recovered.value);
}

// 10. Safety checks (overflow, saturating arithmetic)
test "safety: wrapping and saturating arithmetic" {
    // Wrapping: +% explicitly wraps on overflow
    var x: u8 = 250;
    x +%= 10; // 260 wraps to 4
    try testing.expectEqual(@as(u8, 4), x);

    // Saturating: +| clamps at max
    var y: u8 = 250;
    y +|= 10; // min(260, 255) = 255
    try testing.expectEqual(@as(u8, 255), y);
}

// 11. ArrayList with .empty init (0.15 API)
test "ArrayList: .empty init and allocator-per-method (0.15 API)" {
    const gpa = testing.allocator;
    var list: std.ArrayList(u32) = .empty;
    defer list.deinit(gpa);

    try list.append(gpa, 10);
    try list.append(gpa, 20);
    try list.append(gpa, 30);

    try testing.expectEqual(@as(usize, 3), list.items.len);
    try testing.expectEqual(@as(u32, 30), list.pop());
}
