const std = @import("std");
const testing = std.testing;
const meta = std.meta;

// Minimal comptime metaprogramming validation exercises for the zig-expert skill.
// Copied from src/exercises/advanced_comptime.zig — 10 core tests.

const Point = struct { x: f64, y: f64, z: f64 = 0.0 };

// ---------------------------------------------------------------------------
// 1. @typeInfo struct field iteration
// ---------------------------------------------------------------------------

test "@typeInfo struct field iteration" {
    const info = @typeInfo(Point).@"struct";
    try testing.expectEqual(@as(usize, 3), info.fields.len);
    try testing.expectEqualStrings("x", info.fields[0].name);
    try testing.expect(info.fields[0].type == f64);
}

// ---------------------------------------------------------------------------
// 2. @Type to create new struct type
// ---------------------------------------------------------------------------

fn MakeStruct(comptime fields: []const std.builtin.Type.StructField) type {
    return @Type(.{ .@"struct" = .{
        .layout = .auto,
        .fields = fields,
        .decls = &.{},
        .is_tuple = false,
    } });
}

test "@Type to create struct at comptime" {
    const MyPair = MakeStruct(&.{
        .{ .name = "first", .type = i32, .default_value_ptr = null, .is_comptime = false, .alignment = @alignOf(i32) },
        .{ .name = "second", .type = i32, .default_value_ptr = null, .is_comptime = false, .alignment = @alignOf(i32) },
    });
    const pair = MyPair{ .first = 10, .second = 20 };
    try testing.expectEqual(@as(i32, 10), pair.first);
    try testing.expectEqual(@as(i32, 20), pair.second);
}

// ---------------------------------------------------------------------------
// 3. Builder pattern via field introspection
// ---------------------------------------------------------------------------

fn Builder(comptime T: type) type {
    return struct {
        const Self = @This();
        value: T,
        fn init() Self {
            var val: T = undefined;
            const info = @typeInfo(T).@"struct";
            inline for (info.fields) |field| {
                if (field.default_value_ptr) |default_ptr| {
                    const default = @as(*const field.type, @ptrCast(@alignCast(default_ptr)));
                    @field(val, field.name) = default.*;
                } else {
                    @field(val, field.name) = std.mem.zeroes(field.type);
                }
            }
            return .{ .value = val };
        }
        fn set(self: *Self, comptime name: []const u8, val: @TypeOf(@field(self.value, name))) *Self {
            @field(self.value, name) = val;
            return self;
        }
        fn build(self: Self) T { return self.value; }
    };
}

test "Builder pattern via field introspection" {
    var b = Builder(Point).init();
    const p = b.set("x", 10.0).set("y", 20.0).build();
    try testing.expectApproxEqAbs(@as(f64, 10.0), p.x, 0.001);
    try testing.expectApproxEqAbs(@as(f64, 20.0), p.y, 0.001);
    try testing.expectApproxEqAbs(@as(f64, 0.0), p.z, 0.001);
}

// ---------------------------------------------------------------------------
// 4. MapFields / Nullable type transformation
// ---------------------------------------------------------------------------

fn Nullable(comptime T: type) type {
    const info = @typeInfo(T).@"struct";
    var new_fields: [info.fields.len]std.builtin.Type.StructField = undefined;
    for (info.fields, 0..) |field, i| {
        const NullableField = ?field.type;
        new_fields[i] = .{
            .name = field.name,
            .type = NullableField,
            .default_value_ptr = @as(?*const anyopaque, @ptrCast(&@as(NullableField, null))),
            .is_comptime = false,
            .alignment = if (@sizeOf(NullableField) > 0) @alignOf(NullableField) else 0,
        };
    }
    return @Type(.{ .@"struct" = .{ .layout = .auto, .fields = &new_fields, .decls = &.{}, .is_tuple = false } });
}

fn MapFields(comptime T: type, comptime mapFn: fn (type) type) type {
    const info = @typeInfo(T).@"struct";
    var new_fields: [info.fields.len]std.builtin.Type.StructField = undefined;
    for (info.fields, 0..) |field, i| {
        const NewType = mapFn(field.type);
        new_fields[i] = .{
            .name = field.name, .type = NewType, .default_value_ptr = null,
            .is_comptime = false, .alignment = if (@sizeOf(NewType) > 0) @alignOf(NewType) else 0,
        };
    }
    return @Type(.{ .@"struct" = .{ .layout = .auto, .fields = &new_fields, .decls = &.{}, .is_tuple = false } });
}

fn ToSlice(comptime T: type) type { return []const T; }

test "Nullable and MapFields type transformation" {
    // Nullable: all fields become optional with null default
    const NP = Nullable(Point);
    const empty: NP = .{};
    try testing.expectEqual(@as(?f64, null), empty.x);
    const partial: NP = .{ .x = 1.0, .y = null, .z = null };
    try testing.expectEqual(@as(?f64, 1.0), partial.x);

    // MapFields: transform all field types
    const Sliced = MapFields(struct { a: u8, b: i32, c: f64 }, ToSlice);
    const info = @typeInfo(Sliced).@"struct";
    try testing.expect(info.fields[0].type == []const u8);
    try testing.expect(info.fields[1].type == []const i32);
    try testing.expect(info.fields[2].type == []const f64);
}

// ---------------------------------------------------------------------------
// 5. Dispatch table from tagged union
// ---------------------------------------------------------------------------

fn DispatchTable(comptime U: type) type {
    const field_count = @typeInfo(U).@"union".fields.len;
    return struct {
        const Self = @This();
        handlers: [field_count]?*const fn () void = @splat(null),
        fn setHandler(self: *Self, comptime tag: std.meta.FieldEnum(U), handler: *const fn () void) void {
            self.handlers[@intFromEnum(tag)] = handler;
        }
        fn dispatch(self: *const Self, value: U) void {
            if (self.handlers[@intFromEnum(value)]) |handler| handler();
        }
    };
}

test "dispatch table from tagged union" {
    const Event = union(enum) { click: void, keypress: u8, resize: struct { w: u32, h: u32 } };
    var table = DispatchTable(Event){};
    const handler = struct {
        fn handle() void {}
    }.handle;
    table.setHandler(.click, handler);
    try testing.expect(table.handlers[0] != null);
    try testing.expect(table.handlers[1] == null);
}

// ---------------------------------------------------------------------------
// 6. @setEvalBranchQuota
// ---------------------------------------------------------------------------

fn slowComptime(comptime n: comptime_int) comptime_int {
    @setEvalBranchQuota(n * 10);
    var sum: comptime_int = 0;
    for (0..n) |i| sum += i;
    return sum;
}

test "@setEvalBranchQuota for expensive comptime" {
    const result = comptime slowComptime(1000);
    try testing.expectEqual(@as(comptime_int, 499500), result);
}

// ---------------------------------------------------------------------------
// 7. StaticStringMap usage
// ---------------------------------------------------------------------------

const keyword_map = std.StaticStringMap(enum { kw_if, kw_else, kw_while, kw_for, kw_return }).initComptime(.{
    .{ "if", .kw_if },
    .{ "else", .kw_else },
    .{ "while", .kw_while },
    .{ "for", .kw_for },
    .{ "return", .kw_return },
});

test "StaticStringMap for keyword lookup" {
    try testing.expectEqual(.kw_if, keyword_map.get("if").?);
    try testing.expectEqual(.kw_while, keyword_map.get("while").?);
    try testing.expect(keyword_map.get("var") == null);
}

// ---------------------------------------------------------------------------
// 8. EnumBitSet generation
// ---------------------------------------------------------------------------

fn EnumBitSet(comptime E: type) type {
    const field_count = @typeInfo(E).@"enum".fields.len;
    const Backing = meta.Int(.unsigned, field_count);
    return struct {
        const Self = @This();
        bits: Backing = 0,
        fn insert(self: *Self, val: E) void { self.bits |= @as(Backing, 1) << @intFromEnum(val); }
        fn contains(self: Self, val: E) bool { return (self.bits & (@as(Backing, 1) << @intFromEnum(val))) != 0; }
        fn count(self: Self) usize { return @popCount(self.bits); }
        fn setUnion(a: Self, b: Self) Self { return .{ .bits = a.bits | b.bits }; }
        fn setIntersection(a: Self, b: Self) Self { return .{ .bits = a.bits & b.bits }; }
    };
}

test "EnumBitSet generation" {
    const Permission = enum { read, write, execute };
    const PermSet = EnumBitSet(Permission);
    var perms: PermSet = .{};
    perms.insert(.read);
    perms.insert(.write);
    try testing.expect(perms.contains(.read));
    try testing.expect(!perms.contains(.execute));
    try testing.expectEqual(@as(usize, 2), perms.count());

    var other: PermSet = .{};
    other.insert(.write);
    other.insert(.execute);
    const u = PermSet.setUnion(perms, other);
    try testing.expectEqual(@as(usize, 3), u.count());
    const inter = PermSet.setIntersection(perms, other);
    try testing.expect(inter.contains(.write));
}

// ---------------------------------------------------------------------------
// 9. Custom format method (2-param signature in 0.15.2)
// ---------------------------------------------------------------------------

const Vec2 = struct {
    x: f32,
    y: f32,
    pub fn format(self: Vec2, writer: anytype) !void {
        try writer.print("({d:.1}, {d:.1})", .{ self.x, self.y });
    }
};

test "custom format method (0.15.2 two-param)" {
    const v = Vec2{ .x = 1.5, .y = 2.5 };
    var buf: [64]u8 = undefined;
    const result = try std.fmt.bufPrint(&buf, "{f}", .{v});
    try testing.expectEqualStrings("(1.5, 2.5)", result);
}

// ---------------------------------------------------------------------------
// 10. fieldsMatch — comparing struct layouts at comptime
// ---------------------------------------------------------------------------

fn fieldsMatch(comptime A: type, comptime B: type) bool {
    const a_fields = @typeInfo(A).@"struct".fields;
    const b_fields = @typeInfo(B).@"struct".fields;
    if (a_fields.len != b_fields.len) return false;
    for (a_fields, b_fields) |af, bf| {
        if (!std.mem.eql(u8, af.name, bf.name)) return false;
        if (af.type != bf.type) return false;
    }
    return true;
}

test "fieldsMatch: comptime struct layout comparison" {
    const A = struct { x: i32, y: i32 };
    const B = struct { x: i32, y: i32 };
    const C = struct { x: i32, z: i32 };
    try testing.expect(comptime fieldsMatch(A, B));
    try testing.expect(comptime !fieldsMatch(A, C));
}

// ---------------------------------------------------------------------------
// 11. Comptime string return — *const [N]u8 pattern
//
// Functions with comptime params that build strings CANNOT return []const u8.
// "function called at runtime cannot return value at comptime".
// Return *const [N]u8 where N is comptime-known via a helper function.
// ---------------------------------------------------------------------------

fn comptimeJoinLen(comptime parts: []const []const u8, comptime sep: []const u8) usize {
    var len: usize = 0;
    for (parts, 0..) |part, i| {
        if (i > 0) len += sep.len;
        len += part.len;
    }
    return len;
}

fn comptimeJoin(comptime parts: []const []const u8, comptime sep: []const u8) *const [comptimeJoinLen(parts, sep)]u8 {
    // Must use `comptime` block + break pattern for the array construction.
    // NOTE: Call comptimeJoinLen() directly for the array size — a local
    // `const len = ...` is NOT recognized as comptime-known inside the block.
    const result = comptime blk: {
        var buf: [comptimeJoinLen(parts, sep)]u8 = undefined;
        var pos: usize = 0;
        for (parts, 0..) |part, i| {
            if (i > 0) {
                for (sep) |c| {
                    buf[pos] = c;
                    pos += 1;
                }
            }
            for (part) |c| {
                buf[pos] = c;
                pos += 1;
            }
        }
        break :blk buf;
    };
    return &result;
}

test "comptime string return: *const [N]u8 join pattern" {
    // comptimeJoin returns *const [N]u8, which coerces to []const u8
    const joined: []const u8 = comptimeJoin(&.{ "hello", "world", "zig" }, ", ");
    try testing.expectEqualStrings("hello, world, zig", joined);

    // Can also use at module level (no `comptime` keyword needed for module-level const!)
    const module_level = comptimeJoin(&.{ "a", "b" }, "-");
    try testing.expectEqualStrings("a-b", module_level);
}

// ---------------------------------------------------------------------------
// 12. Module-level comptime lookup table — NO `comptime` keyword
//
// Module-level `const` is ALREADY comptime. Adding `comptime blk:` is a
// compile error. Use plain labeled blocks instead.
// ---------------------------------------------------------------------------

const squares = blk: {
    // CORRECT: plain `blk:` label, no `comptime` keyword
    var table: [16]u32 = undefined;
    for (0..16) |i| {
        table[i] = @as(u32, @intCast(i)) * @as(u32, @intCast(i));
    }
    break :blk table;
};

test "module-level lookup table: no comptime keyword" {
    try testing.expectEqual(@as(u32, 0), squares[0]);
    try testing.expectEqual(@as(u32, 1), squares[1]);
    try testing.expectEqual(@as(u32, 9), squares[3]);
    try testing.expectEqual(@as(u32, 225), squares[15]);
}
