# Zig Comptime Reference (0.15.2)

## Type Introspection
```zig
const info = @typeInfo(T);
// Tags use quoted identifiers: .@"struct", .@"enum", .@"union"
// Also: .pointer, .array, .optional, .error_union, .@"fn", .int, .float

const si = @typeInfo(MyStruct).@"struct";
si.fields   // []const StructField — .name, .type, .default_value_ptr, .alignment
si.decls    // []const Declaration

@hasField(T, "x")    // struct/union fields only
@hasDecl(T, "init")  // methods, constants, nested types

// GOTCHA: @typeInfo(T).int.bits returns u16, NOT usize
// Shifting @as(u8, 1) << bits OVERFLOWS — cast with @intCast first
```

## Type Generation with @Type
```zig
// Create struct at comptime
fn MakeStruct(comptime fields: []const std.builtin.Type.StructField) type {
    return @Type(.{ .@"struct" = .{
        .layout = .auto, .fields = fields, .decls = &.{}, .is_tuple = false,
    } });
}

// Create enum from strings
fn MakeEnum(comptime names: []const []const u8) type {
    var fields: [names.len]std.builtin.Type.EnumField = undefined;
    for (names, 0..) |name, i| {
        fields[i] = .{ .name = @ptrCast(name), .value = i };
    }
    return @Type(.{ .@"enum" = .{
        .tag_type = std.math.IntFittingRange(0, names.len - 1),
        .fields = &fields, .decls = &.{}, .is_exhaustive = true,
    } });
}

// GOTCHA: .name requires [:0]const u8 (sentinel-terminated), not []const u8
// Dynamic int types: std.meta.Int(.signed, 17) → i17
```

## std.meta Utilities
```zig
meta.fields(T)           // field info slice for struct/union/enum
meta.fieldNames(T)       // [][:0]const u8
meta.FieldEnum(T)        // enum with variant per field
meta.stringToEnum(E, s)  // ?E — parse string to enum
meta.hasFn(T, "name")    // function declaration exists?
meta.Int(sign, bits)     // create integer type dynamically
```

## Key Patterns
```zig
// Inline for: unrolled at comptime, enables field access by comptime name
inline for (@typeInfo(T).@"struct".fields) |field| {
    @field(value, field.name) = ...;
}

// StaticStringMap: comptime-built perfect hash
const map = std.StaticStringMap(V).initComptime(.{
    .{ "if", .kw_if }, .{ "else", .kw_else },
});
map.get("if") // ?V; map.has("if") // bool

// Comptime strings
const s = std.fmt.comptimePrint("field_{d}", .{42}); // *const [N:0]u8
const cat = "hello" ++ " " ++ "world";               // ++ only at comptime
const rep = "-" ** 10;                                 // "----------"

// Lookup table generation (module-level const is already comptime)
const hex_table = blk: {
    var t: [256]u8 = [_]u8{0xFF} ** 256;
    for ("0123456789", 0..) |c, i| t[c] = @intCast(i);
    for ("abcdef", 0..) |c, i| t[c] = @intCast(i + 10);
    break :blk t;
};

// @setEvalBranchQuota(n * 10) — raise for expensive loops (default 1000)
// @compileError("msg") — catch bad config at compile time
```

## Type Transformations
```zig
// Nullable<T>: make all struct fields optional with null defaults
fn Nullable(comptime T: type) type {
    const info = @typeInfo(T).@"struct";
    var fields: [info.fields.len]std.builtin.Type.StructField = undefined;
    for (info.fields, 0..) |field, i| {
        const Opt = ?field.type;
        fields[i] = .{
            .name = field.name, .type = Opt,
            .default_value_ptr = @as(?*const anyopaque, @ptrCast(&@as(Opt, null))),
            .is_comptime = false,
            .alignment = if (@sizeOf(Opt) > 0) @alignOf(Opt) else 0,
        };
    }
    return @Type(.{ .@"struct" = .{
        .layout = .auto, .fields = &fields, .decls = &.{}, .is_tuple = false,
    } });
}

// EnumBitSet: bit-flag set backed by exact-width integer
fn EnumBitSet(comptime E: type) type {
    const n = @typeInfo(E).@"enum".fields.len;
    const Backing = std.meta.Int(.unsigned, n);
    return struct {
        bits: Backing = 0,
        fn insert(self: *@This(), v: E) void { self.bits |= @as(Backing, 1) << @intFromEnum(v); }
        fn contains(self: @This(), v: E) bool { return (self.bits & (@as(Backing, 1) << @intFromEnum(v))) != 0; }
        fn count(self: @This()) usize { return @popCount(self.bits); }
    };
}

// Builder pattern, MapFields, DispatchTable — same technique:
// iterate @typeInfo fields at comptime, construct new type with @Type
```

## Custom format Method (0.15.2)
```zig
// Signature: 2 params only — self + writer (NOT the 0.14 4-param version)
pub fn format(self: Vec2, writer: anytype) !void {
    try writer.print("({d:.1}, {d:.1})", .{ self.x, self.y });
}
// Use {f} specifier to invoke: std.fmt.bufPrint(&buf, "{f}", .{my_vec2})
// {} is ambiguous (compile error) if type has format method
// {any} skips format method, prints raw struct fields

// comptimeHash for switch: MUST return comptime_int, not u32
fn comptimeHash(comptime s: []const u8) comptime_int {
    var hash: u32 = 2166136261;
    for (s) |byte| { hash ^= byte; hash *%= 16777619; }
    return hash;
}
```
