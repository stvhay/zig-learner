const std = @import("std");
const testing = std.testing;

// Minimal core language exercises — validates specific claims and gotchas.
// Run: zig test path/to/core_language.zig

// 1. Comptime evaluation and @setEvalBranchQuota
fn slowComptime(comptime n: comptime_int) comptime_int {
    @setEvalBranchQuota(n * 10);
    var sum: comptime_int = 0;
    for (0..n) |i| {
        sum += i;
    }
    return sum;
}

test "comptime: @setEvalBranchQuota for expensive operations" {
    const result = comptime slowComptime(1000);
    try testing.expectEqual(@as(comptime_int, 499500), result);
}

// 2. Tagged union with method dispatch
test "tagged union: method dispatch via switch" {
    const Shape = union(enum) {
        circle: f64,
        rectangle: struct { width: f64, height: f64 },
        point: void,

        pub fn area(self: @This()) f64 {
            return switch (self) {
                .circle => |r| std.math.pi * r * r,
                .rectangle => |rect| rect.width * rect.height,
                .point => 0.0,
            };
        }
    };

    const c = Shape{ .circle = 5.0 };
    try testing.expectApproxEqAbs(78.5398, c.area(), 0.001);

    const p: Shape = .point;
    try testing.expectEqual(@as(f64, 0.0), p.area());

    // Tag comparison
    try testing.expect(c == .circle);
    try testing.expect(c != .point);
}

// 3. Error union handling patterns
const FileError = error{ NotFound, PermissionDenied, DiskFull };

fn riskyFileOp(succeed: bool) FileError!u32 {
    if (!succeed) return FileError.NotFound;
    return 42;
}

test "error union: try, catch, catch with capture" {
    // try: propagate
    const val = try riskyFileOp(true);
    try testing.expectEqual(@as(u32, 42), val);

    // catch with default
    const val2 = riskyFileOp(false) catch 999;
    try testing.expectEqual(@as(u32, 999), val2);

    // catch with capture and labeled block
    const val3 = riskyFileOp(false) catch |err| blk: {
        try testing.expectEqual(FileError.NotFound, err);
        break :blk 0;
    };
    try testing.expectEqual(@as(u32, 0), val3);
}

// 4. Optional chaining/unwrap
test "optional: orelse, if-unwrap, force unwrap" {
    const maybe: ?i32 = 42;
    const val = maybe.?; // force unwrap
    try testing.expectEqual(@as(i32, 42), val);

    const missing: ?i32 = null;
    const val2 = missing orelse 0;
    try testing.expectEqual(@as(i32, 0), val2);

    if (maybe) |v| {
        try testing.expectEqual(@as(i32, 42), v);
    } else {
        return error.ShouldNotReachHere;
    }
}

// 5. Inline for over types
test "inline for: iterate over types at comptime" {
    const types = [_]type{ u8, u16, u32, u64 };
    var total_bits: u32 = 0;

    inline for (types) |T| {
        total_bits += @typeInfo(T).int.bits;
    }
    // 8 + 16 + 32 + 64 = 120
    try testing.expectEqual(@as(u32, 120), total_bits);
}

// 6. Labeled block with break
test "labeled block: complex comptime initialization" {
    const val = comptime blk: {
        var x: u32 = 1;
        for (0..5) |_| {
            x *= 2;
        }
        break :blk x;
    };
    try testing.expectEqual(@as(u32, 32), val);
}

// 7. Defer ordering (LIFO)
test "defer: LIFO execution order" {
    var order: [4]u8 = undefined;
    var idx: usize = 0;

    {
        defer {
            order[idx] = 'A';
            idx += 1;
        }
        defer {
            order[idx] = 'B';
            idx += 1;
        }
        defer {
            order[idx] = 'C';
            idx += 1;
        }
        // Defers execute in reverse order: C, B, A
    }

    try testing.expect(std.mem.eql(u8, "CBA", order[0..idx]));
}

// 8. Defer in loop bodies — runs at end of each iteration
test "defer: runs per iteration in loops" {
    var sum: u32 = 0;
    var loop_count: u32 = 0;

    for (0..5) |_| {
        defer loop_count += 1;
        sum += loop_count;
    }
    // sum = 0+1+2+3+4 = 10 (defer increments AFTER use each iteration)
    try testing.expectEqual(@as(u32, 10), sum);
    try testing.expectEqual(@as(u32, 5), loop_count);
}

// 9. Packed struct with bitcast — explicit bit positions
test "packed struct: bitcast with explicit bit layout" {
    const PackedPair = packed struct {
        low: u4,
        high: u4,
    };

    const p = PackedPair{ .low = 0xA, .high = 0x5 };
    const as_u8: u8 = @bitCast(p);
    // low nibble = 0xA, high nibble = 0x5 -> 0x5A
    try testing.expectEqual(@as(u8, 0x5A), as_u8);

    const p2: PackedPair = @bitCast(@as(u8, 0xF3));
    try testing.expectEqual(@as(u4, 0x3), p2.low);
    try testing.expectEqual(@as(u4, 0xF), p2.high);
}

// 10. Slice vs array pointer distinction
test "slice types: []u8 vs [*]u8 vs *[N]u8" {
    var buf: [5]u8 = "hello".*;

    // *[5]u8 -> pointer to the array itself
    const arr_ptr: *[5]u8 = &buf;
    try testing.expectEqual(@as(usize, 5), arr_ptr.len);

    // []u8 -> slice (fat pointer with length)
    const slice: []u8 = &buf;
    try testing.expectEqual(@as(usize, 5), slice.len);

    // [*]u8 -> many-item pointer (no length, can index but no bounds check)
    const many_ptr: [*]u8 = &buf;
    try testing.expectEqual(@as(u8, 'h'), many_ptr[0]);
}

// 11. @typeInfo bit width returns u16 (gotcha)
test "@typeInfo: .int.bits is u16, not usize" {
    const info = @typeInfo(u32);
    switch (info) {
        .int => |int_info| {
            // bits field is u16 — this matters for shift operations
            try testing.expectEqual(@as(u16, 32), int_info.bits);
            try testing.expectEqual(std.builtin.Signedness.unsigned, int_info.signedness);
        },
        else => return error.UnexpectedType,
    }
}

// 12. @enumFromInt requires explicit result type when used in generic context
// Gotcha: @enumFromInt returns anytype — compiler needs type context.
// Inline in expectEqual (which takes anytype) fails. Bind to typed const first.
test "@enumFromInt: explicit type binding for generic contexts" {
    const Color = enum(u8) { red = 0, green = 1, blue = 2 };

    // CORRECT: bind to typed const — compiler knows the target enum
    const c: Color = @enumFromInt(1);
    try testing.expectEqual(Color.green, c);

    // CORRECT: @as also provides type context
    try testing.expectEqual(Color.blue, @as(Color, @enumFromInt(2)));

    // Round-trip: @intFromEnum -> @enumFromInt
    const val = @intFromEnum(Color.red);
    const back: Color = @enumFromInt(val);
    try testing.expectEqual(Color.red, back);
}

// 13. Comptime lookup table generation
fn comptimePowersOfTwo(comptime n: usize) [n]u64 {
    var result: [n]u64 = undefined;
    for (&result, 0..) |*slot, i| {
        slot.* = @as(u64, 1) << @intCast(i);
    }
    return result;
}

test "comptime: lookup table generation pattern" {
    const powers = comptime comptimePowersOfTwo(8);
    try testing.expectEqual(@as(u64, 1), powers[0]);
    try testing.expectEqual(@as(u64, 2), powers[1]);
    try testing.expectEqual(@as(u64, 4), powers[2]);
    try testing.expectEqual(@as(u64, 128), powers[7]);

    // Verify it's truly comptime
    comptime {
        const p = comptimePowersOfTwo(4);
        if (p[3] != 8) @compileError("expected 8");
    }
}
