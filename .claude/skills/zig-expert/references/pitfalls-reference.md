# Zig 0.15.2 Common Pitfalls & Error Messages

## Pitfalls

1. **ArrayList vs HashMap allocator pattern**: ArrayList uses `.empty` + per-method allocator; HashMap uses `.init(gpa)` + stored allocator
2. **Dangling pointers**: Never return slices of local arrays
3. **Iterator invalidation**: ArrayList reallocation invalidates `.items` slices
4. **Forgetting to flush writers**: Always `try stdout.flush()`
5. **JSON serialize**: Use `{f}` specifier with `std.json.fmt()`, NOT `{any}` or `{}`
6. **GPA init**: `.init` (value literal), NOT `.init{}` or `init()`
7. **Slice types**: `[]u8` (fat ptr), `[*]u8` (unbounded ptr), `[*:0]u8` (sentinel ptr), `*[N]u8` (ptr to array)
8. **@typeInfo tag names**: Use `.@"struct"`, `.@"enum"`, `.@"union"` (quoted identifiers)
9. **Unused error captures**: `catch |_|` is a compile error in 0.15.2; use bare `catch`
10. **Custom format method**: Signature is `fn format(self: T, writer: anytype) !void` in 0.15.2. Use `{f}` specifier.
11. **Thread.Pool.spawn**: Worker must manually call `wg.finish()` — pool does NOT do it for you
12. **Condition.wait must loop**: Always `while (!pred) cond.wait(&mutex)` — spurious wakeups happen
13. **ResetEvent.reset() while waiting**: Undefined behavior — never call reset while threads are blocked on wait
14. **`comptime` keyword in module scope**: Module-level `const` is already comptime; adding `comptime` keyword is a compile error
15. **C string functions**: `std.c` lacks strlen/memcpy — use `@cImport(@cInclude("string.h"))`
16. **@splat needs type context**: `@as(@Vector(4, u32), @splat(42))` — bare `@splat` fails
17. **@shuffle 2nd-vector indices**: Use `~@as(i32, idx)` (bitwise NOT)
18. **PriorityQueue compareFn**: Returns `std.math.Order`, not `bool`
19. **DoublyLinkedList**: Intrusive — embed `Node`, recover parent with `@fieldParentPtr`
20. **Platform info**: `@import("builtin")`, not `std.builtin.cpu`
21. **Allocator.Alignment type**: Use `std.mem.Alignment`, NOT `mem.Allocator.Alignment` (not public)
22. **@Type field names**: `.name` in StructField/EnumField requires `[:0]const u8` (sentinel-terminated), not `[]const u8`
23. **`{f}` vs `{any}` vs `{}`**: With custom `format` method, `{}` is ambiguous (compile error). Use `{f}` to call format, `{any}` to skip it
24. **comptimeHash return**: Functions called in comptime switch must return `comptime_int`, not `u32`
25. **`std.heap.page_size`**: Does not exist — use `std.heap.page_allocator` or hardcoded page sizes
26. **`std.math.log2_int`**: Signature is `(comptime T: type, x: T)` — type parameter first, then value. Not `log2_int(x)`
27. **`std.io.getStdOut()`/`getStdErr()`**: Do NOT exist in 0.15.2. Use `std.fs.File.stdout()`, `.stderr()`, `.stdin()`
28. **`flush()` location**: Lives on `.interface` (the AnyWriter), NOT on the `File.Writer` struct. Always: `writer.interface.flush()`, not `writer.flush()`
29. **`file.readAll(buf)`**: Returns `usize` (bytes read), NOT the buffer. Use `buf[0..n]` to get the content slice
30. **`Dir.close()` takes `*Dir`**: `close()` requires a mutable pointer — must use `var` not `const` when declaring Dir values that will be closed
31. **`EpochDay.calculateDayOfWeek()`**: Does NOT exist in 0.15.2. Compute manually: epoch day 0 (Jan 1 1970) = Thursday, so `day % 7` with offset table `[Thu, Fri, Sat, Sun, Mon, Tue, Wed]`
32. **`std.net.Address` format**: Use `{any}` not `{}` — `{}` may trigger ambiguous format error if Address has a custom format method
33. **`std.posix.sigaction()` on macOS**: Returns `void`, NOT an error union — do NOT use `catch`. On Linux it may return `!void`.
34. **`std.posix.empty_sigset`**: Does NOT exist. Use `std.posix.sigemptyset()` (function call) to get an empty signal set
35. **`SO_RCVTIMEO` does not unblock `accept()`**: On macOS, socket receive timeout only affects `read()`/`recv()`, NOT `accept()`. Use a shutdown monitor thread with self-connection to unblock accept loops
36. **`std.net.Address` IP extraction**: `{any}` format may fail in some contexts. Extract IPv4 octets directly: `addr.in.sa.addr` (u32 in network byte order), shift+truncate for octets; `addr.in.sa.port` in big-endian, use `std.mem.bigToNative`
37. **`File.reader(buf)` returns `File.Reader`**: In 0.15.2, `file.reader(&buf)` takes a buffer and returns a `File.Reader` struct — this does NOT have a `.read()` method. For raw byte reading in a loop, use `file.read(&buf)` directly on the `File` object. The `Reader` is for buffered/streaming access via `.readByte()` etc.
38. **`std.compress.flate.Compress` is incomplete**: The `Compress` module has `@panic("TODO")` — zlib compression is NOT functional in 0.15.2. Use C zlib via `@cImport(@cInclude("zlib.h"))` with `link_libc = true` and `mod.linkSystemLibrary("z", .{})`. The `Decompress` module works fine for decompression.
39. **`statFile()` return value**: `Dir.statFile()` returns a `Stat` struct — if only checking file existence, assign to `_ =` to discard the value, or the compiler will error with "value ignored"
40. **`defer` in `while` loops**: `defer` runs at end of each iteration. Don't use defer to null out the loop variable if you update it in the body — the defer runs AFTER the body, overriding your update
41. **`std.io.AnyWriter` ≠ `std.io.Writer`**: In 0.15.2, `writer.interface` yields `*std.io.Writer` (new type), NOT `*std.io.AnyWriter` (deprecated). Use `anytype` for writer parameters in functions to accept either
42. **`!?T` requires `try` before `orelse`**: When a function returns `!?T` (error union wrapping optional), use `(try fn()) orelse default` — must unwrap error union first, then handle optional
43. **`argsAlloc` lifetime with `defer argsFree`**: `std.process.argsAlloc` returns slices pointing into allocated memory. If you `defer argsFree` inside a parse function and return a config struct holding those slices, the slices become dangling pointers. Either keep args alive for program lifetime or `allocator.dupe()` strings you store
44. **Self-referential slice in value-type struct**: Never store a `[]T` slice pointing into a struct's own embedded array (e.g. `params: []const []const u8` pointing into `_params_buf`). When the struct is returned by value, the array is copied but the slice pointer still references the old location → dangling pointer / segfault. Fix: use a method that reconstructs the slice from the copied array on each access.
45. **Integer width for bit shifts**: Shifting a small integer left by more bits than its width is a compile error. `u4 << 4` fails because u4 only has 2 bits for the shift amount (log2(4)=2), which can't represent 4. Cast first: `@as(u8, nibble) << 4`. Rule: always cast to the target width before shifting.
46. **`argsAlloc` cannot be freed with `allocator.free()`**: `std.process.argsAlloc` returns a specially-allocated structure — calling `allocator.free(args)` causes `Invalid free` panic. Must use `std.process.argsFree(allocator, args)`. Better alternative: use `std.process.argsWithAllocator(allocator)` which returns an `ArgIterator` with clean `deinit()` lifecycle.
47. **`realpathAlloc` fails for non-existent paths**: When checking path traversal, `realpathAlloc` returns an error for paths that don't exist on disk. This means `/../etc/nonexistent` gets a 404 (file not found) instead of 403 (forbidden). Pre-check for `..` path components before calling `realpathAlloc` to ensure correct 403 responses for traversal attempts.
48. **`StringHashMap.deinit()` does NOT free keys**: When keys are heap-allocated (e.g., via `allocPrint` or `allocator.dupe`), you must iterate `keyIterator()` and free each key before calling `deinit()`. This applies to any `HashMap` where the key type is `[]const u8` and keys were dynamically allocated. Pattern: `defer { var it = map.keyIterator(); while (it.next()) |k| alloc.free(k.*); map.deinit(); }`

49. **`![]u8` does not coerce to `!?[]u8`**: When a function returns `!?T`, you cannot directly return a call to a function returning `!T`. Zig won't auto-coerce `!T` → `!?T` through the error union. Fix: use `try` to unwrap the error first, then the `T` value coerces to `?T`. Pattern: `return try formatResponse(...)` not `return formatResponse(...)`.
50. **Recursive functions need explicit error sets with `anytype`**: When two functions with `anytype` params call each other recursively (e.g., `writeArray` → `writeItem` → `writeArray`), Zig can't infer the error set. Fix: use `anyerror!void` as the return type instead of `!void`.
51. **Recursive `free` double-free**: When writing a recursive `freeTree(items)` that calls `freeTree(item.children)` and then `allocator.free(items)`, the recursive call already frees the children slice. Don't also call `allocator.free(item.children)` — that's a double-free.

## Error Messages → Fixes

| Error | Fix |
|---|---|
| `catch \|_\|` type error | Use bare `catch` |
| `redundant comptime keyword` | Remove `comptime` from module-level `const` |
| `member access into non-struct type` | Use `.@"struct"` (quoted identifier) |
| `access of undefined memory` | Dangling slice, use-after-free, or reading `undefined` |
| `no field named 'root_source_file'` | Use `.root_module` with `b.createModule(.{...})` |
| `no member named 'addStaticLibrary'` | Use `b.addModule()` |
| Leak detected in test | Missing `defer` for `alloc`/`deinit` |
| `integer overflow` in shift | Cast `@typeInfo(T).int.bits` (u16) before shifting |
| `ambiguous format string` | Use `{f}` (call format method) or `{any}` (skip it), not `{}` |
| `destination pointer requires '0' sentinel` | @Type field `.name` needs `[:0]const u8`, not `[]const u8` |
| `'Alignment' is not marked 'pub'` | Use `std.mem.Alignment`, not `mem.Allocator.Alignment` |
| `function called at runtime cannot return value at comptime` | Return `comptime_int` from `comptime` fns used in switch |
| `expected 2 argument(s), found 1` on `log2_int` | `math.log2_int(T, x)` — pass type first, then value |
| `has no member named 'getStdOut'` / `'getStdErr'` | Use `std.fs.File.stdout()` / `.stderr()` / `.stdin()` |
| `no field or member function named 'flush'` on Writer | `flush()` is on `.interface` (AnyWriter), not on the Writer struct |
| `cast discards const qualifier` on `Dir.close()` | Use `var` not `const` — `Dir.close()` takes `*Dir` (mutable) |
| `no field or member function named 'calculateDayOfWeek'` | Compute day-of-week manually from epoch day: `day % 7` with Thu=0 offset |
| `expected error union type, found 'void'` on `sigaction catch` | `std.posix.sigaction()` returns `void` on macOS — remove `catch` |
| `no field or member function named 'read'` in `fs.File.Reader` | `File.Reader` lacks `.read()`. Use `file.read(&buf)` directly on the `File` object for raw byte reading |
| `local variable is never mutated` | Change `var` to `const` — Zig enforces immutability when variable is never reassigned |
| `value of type 'Stat' ignored` / `all non-void values must be used` | Assign to `_ =` when checking existence with `statFile()` — Zig requires all non-void returns to be used |
| `@panic("TODO")` from `std.compress.flate.Compress` | Compress is unfinished in 0.15.2 — use C zlib: `@cImport(@cInclude("zlib.h"))` with `link_libc = true` |
| `expected type '*DeprecatedWriter', found '*Writer'` | `writer.interface` yields `*Writer` (new), not `*AnyWriter` (deprecated) — use `anytype` for writer params |
| `expected optional type, found '...error_union...!?...'` | Function returns `!?T` — use `(try fn()) orelse default`, not `fn() orelse default` |
| Segfault / `access of undefined memory` after `argsFree` | Stored a slice from `argsAlloc` result in config, then freed args — use `allocator.dupe()` or keep args alive |
| Segfault accessing slice from returned struct | Self-referential slice (e.g. `params: []const u8` pointing into own `_params_buf`) — struct copy copies array but not slice target. Use a method to reconstruct the slice |
| Leak detected with `StringHashMap` | `deinit()` only frees the hash table structure, not the keys. Free keys via `keyIterator()` before `deinit()` |
| `type 'u2' cannot represent integer value '4'` | u4 << 4 overflow — cast to target width first: `@as(u8, nibble) << 4` |
| `Invalid free` / panic in `allocator.free(argsAlloc result)` | `argsAlloc` returns special allocation — use `argsFree()` or switch to `argsWithAllocator` + `ArgIterator` |
| `error union payload '[]u8' cannot cast into error union payload '?[]u8'` | Can't coerce `!T` → `!?T` directly. Use `try` first: `return try fn()` unwraps error, then `T` coerces to `?T` |
| `unable to resolve inferred error set` on recursive call | Recursive `anytype`-param functions can't infer error sets. Use explicit `anyerror!void` |
| `Double free detected` in recursive free function | If `freeTree(children)` already frees the slice at the end, don't also call `allocator.free(children)` |
