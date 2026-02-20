// Minimal style exercises — one test per Kernighan & Plauger principle applied to Zig.
// Run with: zig test .claude/skills/zig-expert/exercises/style.zig

const std = @import("std");
const testing = std.testing;
const mem = std.mem;

// ---- 1. Library function preference: stdlib over manual bit tricks ----

test "prefer library functions over clever tricks" {
    // std.math.isPowerOfTwo is instantly readable vs n & (n-1) trick.
    // Note: isPowerOfTwo asserts n > 0.
    const cases = [_]u32{ 1, 2, 3, 4, 8, 15, 16, 31, 32, 64, 100, 128 };
    for (cases) |n| {
        const manual = n != 0 and (n & (n - 1)) == 0;
        try testing.expectEqual(manual, std.math.isPowerOfTwo(n));
    }
    try testing.expect(std.math.isPowerOfTwo(@as(u32, 64)));
    try testing.expect(!std.math.isPowerOfTwo(@as(u32, 63)));
}

// ---- 2. Switch vs if-chain readability ----

test "switch with ranges reads like a specification" {
    const classify = struct {
        fn call(c: u8) []const u8 {
            return switch (c) {
                'a'...'z', 'A'...'Z' => "letter",
                '0'...'9' => "digit",
                ' ', '\t', '\n', '\r' => "whitespace",
                else => "other",
            };
        }
    }.call;

    try testing.expectEqualStrings("letter", classify('g'));
    try testing.expectEqualStrings("digit", classify('5'));
    try testing.expectEqualStrings("whitespace", classify(' '));
    try testing.expectEqualStrings("other", classify('!'));
}

// ---- 3. Generic type function (BoundedBuffer) ----

fn BoundedBuffer(comptime T: type, comptime capacity: usize) type {
    return struct {
        items: [capacity]T = undefined,
        len: usize = 0,

        const Self = @This();

        fn push(self: *Self, value: T) !void {
            if (self.len >= capacity) return error.BufferFull;
            self.items[self.len] = value;
            self.len += 1;
        }

        fn slice(self: *const Self) []const T {
            return self.items[0..self.len];
        }
    };
}

test "one generic replaces many specialized types" {
    var ints: BoundedBuffer(i32, 4) = .{};
    try ints.push(10);
    try ints.push(20);
    try testing.expectEqualSlices(i32, &[_]i32{ 10, 20 }, ints.slice());

    var bytes: BoundedBuffer(u8, 8) = .{};
    try bytes.push('Z');
    try bytes.push('i');
    try bytes.push('g');
    try testing.expectEqualSlices(u8, "Zig", bytes.slice());
}

// ---- 4. Tagged union for state machines ----

test "tagged unions make state machines explicit" {
    const ConnectionState = union(enum) {
        disconnected: void,
        connecting: struct { attempt: u32 },
        connected: struct { latency_ms: u32 },
        failed: struct { reason: []const u8 },
    };

    const describe = struct {
        fn call(state: ConnectionState) []const u8 {
            return switch (state) {
                .disconnected => "idle",
                .connecting => "in progress",
                .connected => "ready",
                .failed => "error",
            };
        }
    }.call;

    try testing.expectEqualStrings("idle", describe(.disconnected));
    try testing.expectEqualStrings("in progress", describe(.{ .connecting = .{ .attempt = 3 } }));
    try testing.expectEqualStrings("ready", describe(.{ .connected = .{ .latency_ms = 42 } }));
    try testing.expectEqualStrings("error", describe(.{ .failed = .{ .reason = "timeout" } }));
}

// ---- 5. defer ordering (LIFO) ----

test "defer keeps acquire and release adjacent" {
    const gpa = testing.allocator;

    // Acquire and release are visually paired; cleanup is LIFO at scope exit.
    const data = try gpa.alloc(u8, 100);
    defer gpa.free(data);

    const more = try gpa.alloc(u8, 200);
    defer gpa.free(more);

    @memset(data, 'A');
    @memset(more, 'B');
    try testing.expectEqual(@as(u8, 'A'), data[0]);
    try testing.expectEqual(@as(u8, 'B'), more[0]);
}

// ---- 6. errdefer cleanup pattern ----

test "errdefer keeps error cleanup close to allocation" {
    const gpa = testing.allocator;

    const allocAndValidate = struct {
        fn call(allocator: mem.Allocator, valid: bool) ![]u8 {
            const buf = try allocator.alloc(u8, 64);
            errdefer allocator.free(buf); // paired with allocation above

            if (!valid) return error.ValidationFailed;
            @memset(buf, 0);
            return buf;
        }
    }.call;

    // Success: caller owns the memory
    const result = try allocAndValidate(gpa, true);
    defer gpa.free(result);
    try testing.expectEqual(@as(u8, 0), result[0]);

    // Failure: errdefer freed automatically, no leak
    try testing.expectError(error.ValidationFailed, allocAndValidate(gpa, false));
}

// ---- 7. Comptime lookup table generation ----

fn asciiLookup(comptime predicate: fn (u8) bool) [256]bool {
    var table: [256]bool = undefined;
    for (0..256) |i| {
        table[i] = predicate(@intCast(i));
    }
    return table;
}

const is_vowel_table = asciiLookup(struct {
    fn call(c: u8) bool {
        return switch (c) {
            'a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U' => true,
            else => false,
        };
    }
}.call);

test "comptime lookup tables — let the compiler do the work" {
    try testing.expect(is_vowel_table['a']);
    try testing.expect(is_vowel_table['E']);
    try testing.expect(!is_vowel_table['b']);
    try testing.expect(!is_vowel_table['Z']);
    try testing.expect(!is_vowel_table[0]);
}

// ---- 8. Packed struct for data layout ----

test "packed struct documents bit-level protocol" {
    const TcpFlags = packed struct {
        fin: bool, // bit 0
        syn: bool, // bit 1
        rst: bool, // bit 2
        psh: bool, // bit 3
        ack: bool, // bit 4
        urg: bool, // bit 5
        _reserved: u2 = 0,
    };

    const syn_ack = TcpFlags{
        .fin = false,
        .syn = true,
        .rst = false,
        .psh = false,
        .ack = true,
        .urg = false,
    };

    const as_byte: u8 = @bitCast(syn_ack);
    try testing.expectEqual(@as(u8, 0b00010010), as_byte);
}

// ---- 9. @compileError for invalid config ----

test "comptime validation catches errors before runtime" {
    const Config = struct {
        max_connections: u32,
        port: u16,

        fn validate(comptime self: @This()) @This() {
            if (self.max_connections == 0) @compileError("max_connections must be > 0");
            if (self.port == 0) @compileError("port must be > 0");
            return self;
        }
    };

    const valid = comptime (Config{ .max_connections = 100, .port = 8080 }).validate();
    try testing.expectEqual(@as(u32, 100), valid.max_connections);
    try testing.expectEqual(@as(u16, 8080), valid.port);
}

// ---- 10. Self-documenting optional and error types ----

test "optional and error types document intent without comments" {
    // ?T says "might not exist" — no comment needed
    const numbers = [_]i32{ 1, 3, 5, 8, 11, 14 };

    const isEven = struct {
        fn call(n: i32) bool {
            return @rem(n, 2) == 0;
        }
    }.call;

    // Generic findFirst with ?T return: self-documenting "might not find it"
    const result: ?i32 = blk: {
        for (numbers) |n| {
            if (isEven(n)) break :blk n;
        }
        break :blk null;
    };
    try testing.expectEqual(@as(?i32, 8), result);

    // error{X}!T documents failure modes in the signature
    const safeDivide = struct {
        fn call(a: f64, b: f64) error{DivisionByZero}!f64 {
            if (b == 0) return error.DivisionByZero;
            return a / b;
        }
    }.call;

    try testing.expectEqual(@as(f64, 5.0), try safeDivide(10.0, 2.0));
    try testing.expectError(error.DivisionByZero, safeDivide(1.0, 0.0));
}
