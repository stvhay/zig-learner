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

## Comptime checklist (5 rules)

| Rule | Error if violated | Fix |
|------|-------------------|-----|
| No `comptime` on module-level `const` | Already comptime — `comptime blk:` = error | Plain `blk:` label |
| No `comptime` on struct-level `const` | Same rule inside returned struct types | Plain `blk:` label |
| Return `*const [N]u8`, not `[]const u8` | "cannot return comptime value at runtime" | Helper fn computes N; return pointer to array |
| Use `comptime var` + `inline for` | Plain var/for don't work in comptime construction | Both keywords required |
| Compute lengths inside comptime blocks | Local const outside block not recognized inside | Assign inside the comptime block |
