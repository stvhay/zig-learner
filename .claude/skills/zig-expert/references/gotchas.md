# Zig 0.15.2 Compiler Gotchas

Searchable reference for common compile errors and runtime traps. Each entry is one RAG chunk: symptom, error text, fix, minimal code.

## getStdOut / getStdErr / getStdIn does not exist

`std.io.getStdOut()`, `getStdErr()`, `getStdIn()` do NOT exist in 0.15.2. The 0.14 names are deeply embedded in training data.

```zig
// WRONG (0.14)
const stdout = std.io.getStdOut().writer();

// CORRECT (0.15.2)
var buf: [4096]u8 = undefined;
var w = std.fs.File.stdout().writer(&buf);
const stdout = &w.interface;
```

## catch with unused error: use bare catch

`catch |_|` is a compile error in 0.15.2. Use bare `catch` when discarding the error.

```zig
// WRONG
const val = expr catch |_| default;

// CORRECT
const val = expr catch default;
```

## sort does not exist: use std.sort.pdq

`std.sort.sort()` was removed. Use `std.sort.pdq()`.

```zig
std.sort.pdq(u8, slice, {}, std.sort.asc(u8));
```

## @fieldParentPtr: string argument first

The argument order is `@fieldParentPtr("field_name", ptr)` — string comes first, not second.

## StringHashMap.deinit does not free keys

`StringHashMap.deinit()` frees the hash table but NOT the stored keys. Free keys manually via `keyIterator()` first.

```zig
var it = map.keyIterator();
while (it.next()) |key_ptr| allocator.free(key_ptr.*);
map.deinit();
```

## mem.sliceTo requires sentinel-terminated pointer

`mem.sliceTo` requires `[*:0]u8` (sentinel-terminated), NOT `[*]u8`. Use `std.mem.span` for `[*:0]u8` → `[]u8` conversion.

## Function parameter shadows method name

If a function parameter has the same name as a method on a type, the parameter shadows the method. Rename the parameter to avoid compile error.

## Discard pitfalls: _ = x

Two traps with `_ = x;`:
1. Compile error if `x` was mutated — restructure to avoid the variable entirely.
2. Compile error if `x` is still used later — the discard is pointless. Remove it.

## Dead code in function bodies

Zig analyzes ALL function bodies even if never called. An unused `var` inside a dead helper still triggers "local variable is never mutated." Remove dead functions before compiling.

## catch block value syntax

Use labeled block syntax for catch blocks that compute a value:

```zig
const x = expr catch blk: {
    // ... error handling ...
    break :blk fallback_value;
};
```

## Error set exhaustiveness: else prong unreachable

Concrete reader types have small known error sets. An `else` prong may trigger "unreachable else prong." Use bare `catch` or name specific errors.

## Comptime format strings are not dynamic

Format specifiers must be comptime-known. Cannot build format strings at runtime.

```zig
// WRONG: dynamic format string
const fmt = if (upper) "{X:0>2}" else "{x:0>2}";
print(fmt, .{val});

// CORRECT: branch on the print call
if (upper) print("{X:0>2}", .{val}) else print("{x:0>2}", .{val});
```

## flush() on Writer interface, not struct

`var w = File.stdout().writer(&buf)` creates a `File.Writer` struct. Call `flush()` on `&w.interface` (the `std.io.Writer` vtable), NOT on `w` directly. `w.flush()` does not exist.

## eqlIgnoreCase for case-insensitive comparison

Use `std.ascii.eqlIgnoreCase(a, b)`. Not `std.mem.eql` with lowercased strings.

## std.time.sleep does not exist

Use `std.Thread.sleep(ns)` (nanoseconds). `std.time.sleep()` does not exist in 0.15.2.

## Freeing sub-slices panics

`alloc(N)` then `free(buf[0..M])` = "Invalid free." Always free the exact allocation, never a sub-slice.

## Narrow arithmetic overflow

`u8 * 100` stays `u8` — panics if result > 255. Cast to result width BEFORE the operation:

```zig
// WRONG: u4 << 4 overflows
const result = hi << 4;

// CORRECT: widen first
const result = @as(u8, hi) << 4;
```

Same for `+`, `-`, `<<`. Rule: cast BEFORE the operation.

## Comptime branch elimination skips peer resolution

`const cond = true; if (cond) a else b` evaluates at comptime — dead branch eliminated, no peer type resolution. To test peer resolution, force runtime: `var cond = true; _ = &cond;`

## Peer type resolution for errors

`T` and `error.Foo` resolve to `error{Foo}!T` (specific set), NOT `anyerror!T`. Only explicit annotation or `||` merging produces `anyerror`.

## Redundant comptime keyword at module/struct scope

Module-level `const` and struct-level `const` are already comptime. Writing `const x = comptime blk: { ... }` is a compile error. Use plain labeled blocks:

```zig
const x = blk: {
    // ... comptime logic ...
    break :blk val;
};
```

## @enumFromInt needs explicit result type

`@enumFromInt` returns `anytype` — the compiler infers the enum type from context. When passed directly to a generic function like `expectEqual`, there is no type context and compilation fails.

```zig
const Color = enum { red, green, blue };

// WRONG: no type context — compiler error
try std.testing.expectEqual(Color.green, @enumFromInt(1));

// CORRECT: bind to typed const first
const color: Color = @enumFromInt(1);
try std.testing.expectEqual(Color.green, color);
```

Same applies to `@intToEnum` replacement builtins and any `anytype`-returning builtin used inline in a generic call.

## math.log2_int takes type as separate comptime parameter

`std.math.log2_int` signature is `log2_int(comptime T: type, x: T)` — the type is a separate comptime parameter, not inferred from the value. Same pattern applies to `log2`, `divCeil`, and other math functions with comptime type params.

```zig
// WRONG: passing typed value directly
const result = std.math.log2_int(@as(u32, 8));

// CORRECT: type as separate first argument
const result = std.math.log2_int(u32, 8);
```

## Variable name shadows primitive type (i1, u1, etc.)

Zig reserves all primitive type names as keywords: `i1`–`i65535`, `u1`–`u65535`, `f16`, `f32`, `f64`, `f80`, `f128`. Using one as a variable name is a compile error: "shadows primitive type."

```zig
// WRONG: i1 is a 1-bit signed integer type
const i1 = @intFromError(err1);

// CORRECT: use a descriptive name
const int1 = @intFromError(err1);
```

Common traps: `i1`, `i2`, `i8`, `u8`, `f32` as loop counters or temporaries. Use `idx`, `val`, or descriptive names instead.

## for range produces usize — needs @intCast for narrower accumulators

`for (1..11) |i|` binds `i` as `usize`. Accumulating into a narrower type like `u32` via `sum += i` is a compile error: type mismatch.

```zig
// WRONG: usize cannot coerce to u32
var sum: u32 = 0;
for (1..11) |i| { sum += i; }

// CORRECT: cast loop variable
var sum: u32 = 0;
for (1..11) |i| { sum += @intCast(i); }
```

## StructField.alignment must be >= 1 for sized types

When constructing `std.builtin.Type.StructField` for `@Type`, setting `.alignment = 0` causes a compile error for any sized type. Use `@alignOf(T)`.

```zig
// WRONG: alignment = 0 for a sized type
.{ .name = "x", .type = i32, .alignment = 0, ... }

// CORRECT: use @alignOf
.{ .name = "x", .type = i32, .alignment = @alignOf(i32), ... }

// For optionally-sized types (e.g., type transforms):
.alignment = if (@sizeOf(T) > 0) @alignOf(T) else 0,
```

## meta.Tag(U) returns tag enum type — not comparable with enum literals

`std.meta.Tag(U)` returns the tag enum TYPE of a tagged union. Comparing it with `@TypeOf(.some_literal)` fails because enum literals have their own anonymous type.

```zig
const Value = union(enum) { integer: i64, string: []const u8 };

// WRONG: @TypeOf(.integer) is an enum literal type, not Value's tag type
const TagType = std.meta.Tag(Value);
if (TagType == @TypeOf(.integer)) ...  // always false

// CORRECT: introspect the tag enum's fields
const tag_info = @typeInfo(TagType).@"enum";
// Check field names, count, etc.
```

## comptime keyword needed in test/function blocks for array sizes

Inside `test` or `fn` bodies, a labeled block result is NOT automatically comptime-known. If the result feeds an array size, add explicit `comptime`:

```zig
test "example" {
    // WRONG: sum not comptime-known — cannot use as array size
    const sum = blk: {
        var s: u32 = 0;
        for (1..11) |i| { s += @intCast(i); }
        break :blk s;
    };
    var arr: [sum]u8 = undefined;  // ERROR

    // CORRECT: explicit comptime makes result comptime-known
    const sum = comptime blk: {
        var s: u32 = 0;
        for (1..11) |i| { s += @intCast(i); }
        break :blk s;
    };
    var arr: [sum]u8 = undefined;  // OK
}
```

Note: Module-level `const` is already comptime — do NOT add `comptime` there (see "Redundant comptime keyword" entry).

## Comptime checklist (5 rules)

| Rule | Error if violated | Fix |
|------|-------------------|-----|
| No `comptime` on module-level `const` | Already comptime — `comptime blk:` = error | Plain `blk:` label |
| No `comptime` on struct-level `const` | Same rule inside returned struct types | Plain `blk:` label |
| Return `*const [N]u8`, not `[]const u8` | "cannot return comptime value at runtime" | Helper fn computes N; return pointer to array |
| Use `comptime var` + `inline for` | Plain var/for don't work in comptime construction | Both keywords required |
| Compute lengths inside comptime blocks | Local const outside block not recognized inside | Assign inside the comptime block |
