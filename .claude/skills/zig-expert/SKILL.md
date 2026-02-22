---
name: Zig-Expert
description: Use when writing, reviewing, debugging, or migrating Zig 0.15.2 code. Also use when diagnosing build errors, compile errors, runtime panics, or "error: ..." messages from the Zig compiler.
---

# Zig Expert (0.15.2)

## On Load: Skill Discovery

On first load, review available skills and annotate the useful ones:

```bash
skill                          # list all
skill <name>                   # show one
skill <name> <note>            # add note
skill <name> --delete          # remove note
```

Notes persist across sessions. Review and update as you learn which skills actually help.

## How Zig Thinks

Four design choices shape all Zig code. Understanding WHY enables correct code in novel situations.

### 1. Explicit Allocator-Passing

Every function that allocates receives its allocator as a parameter. No global malloc, no GC, no borrow checker.

**Why:** Composability. Same code works with `testing.allocator` (leak-detecting), `ArenaAllocator` (bulk-free), or `GeneralPurposeAllocator` (debug checks). Caller decides strategy; callee is agnostic.

**Bridges:** Like C's malloc/free but the *allocator* is the parameter, not the memory. Like Go's `context.Context` — threading policy through call chains. Like Rust's `Allocator` trait but required everywhere, not optional.

**Consequence:** ArrayList takes allocator per-method (`append(gpa, val)`); HashMap stores it at init (`.init(gpa)`). Know which pattern each collection uses.

### 2. Comptime = The Same Language, Earlier

No preprocessor, no templates, no macros. `comptime` runs regular Zig at compile time. Types are first-class comptime values.

**Why:** "No hidden control flow." `fn Stack(comptime T: type) type` is just a function returning a type. Generics, lookup tables, and type transforms use the same syntax as runtime.

**Bridges:** Like C++ constexpr but applies to the *entire language* including type construction. Like Rust proc macros but same syntax as runtime. `comptime fn` ≈ C++ `consteval`. No Go analogue — Go chose simplicity; Zig chose metaprogramming without a separate language.

**Concrete mappings:** C++ `template<typename T> class Stack` → Zig `fn Stack(comptime T: type) type`. Rust `const N: usize` generic → Zig `comptime n: usize`. C `#define MAX 100` → Zig `const max = 100` (module-level const is already comptime — adding `comptime` keyword = compile error).

### 3. Errors = Flat Value Sets

Errors are lightweight enum values. `try` is sugar for `catch |err| return err`. No unwinding, no hidden control flow, no heap allocation for errors.

**Why:** Composability. Sets merge with `||`. Exhaustive `switch` catches unhandled cases. `!T` documents failure modes in the signature.

**Bridges:** Go `if err != nil { return err }` → Zig `try`. Rust `Result<T, E>` → Zig `E!T`, but errors are flat sets — no `Box<dyn Error>`, no hierarchies. C errno → similar concept but compiler-enforced, can't be ignored.

**Consequence:** Prefer inferred `!T` for internal functions. Explicit error sets only at public API boundaries.

### 4. Safety Without Runtime Cost

Debug and ReleaseSafe keep all safety checks (bounds, overflow, null deref → panic with stack trace). ReleaseFast/Small remove them.

**Why:** Write natural code, test with checks on, deploy with checks off where speed matters. No need for manual bounds checking — slices are bounds-checked by default.

**Bridges:** Unlike Rust (always safe unless `unsafe`), C (never safe), Go (always safe via GC + bounds). Closest analogue: C `-fsanitize=address` as the default mode, not opt-in.

**Consequence:** Use `undefined` for uninitialized memory (fills with 0xAA in debug — detects reads). Use `+` for checked arithmetic (panics on overflow), `+%` for intentional wrapping, `+|` for saturating. **Bit-width trap:** `u3` counter `+= 1` at value 7 panics — use `u4` and check `== 8` explicitly when you need a counter that reaches a power-of-two boundary.

## 0.15.2 API Reference

Training data shows 0.14 patterns. These are the 0.15.2 equivalents. Full pitfall list: **pitfalls-reference.md**.

### Collection Initialization

The allocator-passing pattern varies by type. Check init against the type every time.

| Type | Init | Deinit | Method pattern |
|------|------|--------|---------------|
| `ArrayList(T)` | `.empty` | `.deinit(gpa)` | `.append(gpa, val)` — allocator per-method |
| `AutoHashMap`/`StringHashMap` | `.init(gpa)` | `.deinit()` | `.put(k, v)` — stored allocator |
| `json.ObjectMap` | `.init(gpa)` | `.deinit()` | `.put(k, v)` — stored allocator |
| `json.Array` | `.init(gpa)` | `.deinit()` | `.append(v)` — stored allocator |
| `PriorityQueue(T, ctx, cmp)` | `.init(gpa, ctx)` | `.deinit()` | `.add(item)` — stored allocator |
| `GPA(.{})` | `.init` (value literal) | `.deinit()` | N/A |

```zig
// ArrayList — per-method allocator
var list: std.ArrayList(i32) = .empty;
defer list.deinit(gpa);
try list.append(gpa, 42);

// JSON types — stored allocator (different from ArrayList!)
var obj = std.json.ObjectMap.init(gpa);
defer obj.deinit();
try obj.put("key", .{ .string = "value" });
// ObjectMap.deinit() does NOT recursively free nested objects — use ArenaAllocator.
```

### Memory Ownership

Five rules that prevent the most common runtime errors:

1. **One owner per resource.** If `errdefer allocator.free(x)` is active, never also manually free `x` before returning an error — errdefer fires on the error return, causing double-free.
2. **Defer-free intermediates.** When function A allocates a result and passes it to function B which also allocates, A's result leaks unless freed: `defer allocator.free(a_result)` before calling B.
3. **JSON arena lifetime.** Strings from `parseFromSlice` point into the parsed arena. After `parsed.deinit()`, those strings are dangling. Use `.allocate = .alloc_always` or dupe with the caller's allocator.
4. **No self-referential slices in value structs.** A struct can't hold a slice into its own buffer — the slice dangles when the struct is returned by value. Use `len: usize` + a method that reconstructs the slice.
5. **Nested slice constness.** `[][]u8` does not coerce to `[][]const u8`. The inner pointer's mutability is part of the type. Allocate `[]const u8` items directly.

### I/O

```zig
// stdout/stderr/stdin (NOT std.io.getStdOut/getStdErr/getStdIn!)
var buf: [1024]u8 = undefined;
var w = std.fs.File.stdout().writer(&buf);
const stdout = &w.interface;  // flush() on interface, not w

// Line reading: deprecatedReader (bufferedReaderSize does NOT exist in 0.15.2)
const stdin_file = std.fs.File.stdin();
const reader = stdin_file.deprecatedReader();
var line_buf: [4096]u8 = undefined;
const line = reader.readUntilDelimiterOrEof(&line_buf, '\n');
// Returns ?[]u8 — null on EOF. Buffer aliasing: dupe before next read.

// Writer params: use anytype (AnyWriter ≠ Writer from .interface)
fn process(stdout: anytype, stderr: anytype) !void { ... }

// !?T: try THEN orelse
const line = (try readLine(stdin, &buf)) orelse break;
```

### JSON

```zig
// Serialize (no stringify/stringifyAlloc)
const s = try std.fmt.allocPrint(gpa, "{f}", .{std.json.fmt(value, .{})});

// Parse — use .alloc_always when input will be freed
const parsed = try std.json.parseFromSlice(T, gpa, input, .{ .allocate = .alloc_always });
defer parsed.deinit();
```

### Filesystem

```zig
const f = try std.fs.cwd().createFile("out.bin", .{});
defer f.close();
try f.writeAll(&bytes);

// Read entire file by path / by handle
const data = try std.fs.cwd().readFileAlloc(gpa, "path", std.math.maxInt(usize));
const data2 = try file.readToEndAlloc(gpa, std.math.maxInt(usize));

// Dir.close() requires *Dir (mutable) — use var, not const

// Little-endian binary I/O
try f.writeAll(&std.mem.toBytes(@as(u32, value)));
const v = std.mem.readInt(u32, buf[0..4], .little);
```

### Networking

```zig
// TCP server
const addr = std.net.Address.parseIp4("127.0.0.1", port) catch unreachable;
var server = try addr.listen(.{ .reuse_address = true });
defer server.deinit();
const conn = try server.accept();
defer conn.stream.close();

// TCP client
const stream = try std.net.tcpConnectToAddress(addr);
defer stream.close();

// Socket timeout (SO_RCVTIMEO does NOT unblock accept() on macOS)
const timeout = std.posix.timeval{ .sec = 5, .usec = 0 };
std.posix.setsockopt(conn.stream.handle, std.posix.SOL.SOCKET,
    std.posix.SO.RCVTIMEO, std.mem.asBytes(&timeout)) catch {};

// TCP stream reads may return partial data — loop until complete message parsed
// stream.read() returns 0..N bytes; never assume one read = one message

// Signal handling
const sa = std.posix.Sigaction{
    .handler = .{ .handler = myHandler },  // fn(c_int) callconv(.c) void
    .mask = std.posix.sigemptyset(),
    .flags = 0,
};
std.posix.sigaction(std.posix.SIG.INT, &sa, null);
```

### Crypto

```zig
// AES-256-GCM: key [32]u8, nonce [12]u8, tag [16]u8
const Aes256Gcm = std.crypto.aead.aes_gcm.Aes256Gcm;
Aes256Gcm.encrypt(ciphertext, &tag, plaintext, &.{}, nonce, key);
Aes256Gcm.decrypt(plaintext, ciphertext, tag, &.{}, nonce, key) catch return error.AuthFailed;

// Argon2id key derivation — allocator is FIRST param
try std.crypto.pwhash.argon2.kdf(gpa, &derived_key, password, &salt,
    .{ .t = 3, .m = 65536, .p = 1 }, .argon2id);

// Secure random
std.crypto.random.bytes(&buf);
const n = std.crypto.random.uintLessThan(u8, max);
```

### Other Patterns

```zig
// CLI args (NOT argsAlloc)
var args = std.process.argsWithAllocator(gpa) catch ...;
defer args.deinit();

// Bit shifts: cast to target width BEFORE shifting
const byte: u8 = (@as(u8, nibble) << 4) | low;

// Custom format: 2 params, {f} specifier
pub fn format(self: Self, writer: anytype) !void { ... }

// C zlib (std.compress.flate.Compress has @panic("TODO"))
const c = @cImport(@cInclude("zlib.h"));
// Build: zig build-exe file.zig -lz -lc

// macOS POSIX stat: mtimespec/ctimespec (NOT mtime/ctime), .sec (isize) + .nsec (isize)
// Cast: @truncate for u64→u32, @bitCast for i32→u32, @intCast for same-sign

// EpochSeconds date/time
const es = std.time.epoch.EpochSeconds{ .secs = @intCast(std.time.timestamp()) };
const ed = es.getEpochDay();
const yd = ed.calculateYearDay();
const md = yd.calculateMonthDay();  // .month (enum), .day_index (0-based)
const ds = es.getDaySeconds();      // .getHoursIntoDay/Minutes/Seconds

// Performance timing
const t0 = std.time.nanoTimestamp();
const elapsed_ns: u64 = @intCast(std.time.nanoTimestamp() - t0);
```

### Stdlib Quick Reference

**HashMap patterns:**
```zig
// getOrPut — upsert without double-lookup
const gop = try map.getOrPut(key);
if (!gop.found_existing) gop.value_ptr.* = 0;
gop.value_ptr.* += 1;

// Iterator — key_ptr.*/value_ptr.* pattern
var it = map.iterator();
while (it.next()) |entry| { _ = entry.key_ptr.*; _ = entry.value_ptr.*; }

// remove returns bool; fetchRemove returns ?KV (struct with .key, .value)
_ = map.remove(key);  // true if existed
if (map.fetchRemove(key)) |kv| { _ = kv.key; _ = kv.value; }
```

**String/mem utilities:**
| Function | Returns | Notes |
|----------|---------|-------|
| `mem.splitScalar(u8, s, ',')` | iterator | Consecutive delimiters → empty strings |
| `mem.splitSequence(u8, s, "=>")` | iterator | Multi-char delimiter |
| `mem.tokenizeScalar(u8, s, ' ')` | iterator | **Skips** consecutive delimiters |
| `mem.tokenizeAny(u8, s, ", ;")` | iterator | Any char in set is delimiter |
| `mem.indexOf(u8, hay, needle)` | `?usize` | First occurrence |
| `mem.lastIndexOf(u8, hay, needle)` | `?usize` | Last occurrence |
| `mem.trim(u8, s, " ")` | `[]const u8` | Strip chars from both ends |
| `mem.concat(gpa, u8, &.{"a","b"})` | `![]u8` | Allocates — must free |
| `mem.replaceOwned(u8, gpa, s, "-", "_")` | `![]u8` | Allocates — must free |
| `mem.zeroes([8]u8)` | `[8]u8` | Zero-initialized, works for any type |
| `mem.asBytes(&val)` | `*[@sizeOf(T)]u8` | Reinterpret as bytes (little-endian on LE) |

**Formatting:**
```zig
// comptimePrint — zero-cost comptime string literal
const name = comptime std.fmt.comptimePrint("field_{d}", .{42});

// Format specifier syntax: {specifier:fill<alignment>width.precision}
// {d:0>8}    → "00000042"     (zero-padded decimal)
// {X}        → "FF"           (hex uppercase)
// {x}        → "ff"           (hex lowercase)
// {b}        → "1010"         (binary)
// {d:.3}     → "3.142"        (float precision — {d} works for both int and float)
// {s:_<10}   → "zig_______"   (left-align with fill char)
```

**Sort:**
```zig
std.sort.pdq(T, slice, {}, std.sort.asc(T));   // ascending
std.sort.pdq(T, slice, {}, std.sort.desc(T));   // descending
std.sort.isSorted(T, slice, {}, std.sort.asc(T)); // check sorted
// Custom: struct { fn lt(_: void, a: T, b: T) bool { ... } }.lt
```

**Math:**
```zig
@min(a, b); @max(a, b);             // builtins, NOT std.math.min/max
std.math.clamp(val, lo, hi);        // clamp to range
std.math.isPowerOfTwo(n);           // asserts n > 0 (panics on 0!)
std.math.log2_int(u32, 8);          // → 3 (floor log2)
std.math.divCeil(u32, 10, 3) catch unreachable;  // → 4 (returns error union!)
std.math.maxInt(u8);                // → 255 (comptime)
std.math.minInt(i8);                // → -128 (comptime)
```

**JSON dynamic Value access:**
```zig
const parsed = try std.json.parseFromSlice(std.json.Value, gpa, input, .{});
defer parsed.deinit();
const name = parsed.value.object.get("name").?.string;     // string field
const count = parsed.value.object.get("count").?.integer;   // i64 field
const items = parsed.value.object.get("tags").?.array.items; // []Value
```

### Compiler Gotchas

- `catch |_|` → bare `catch`; `sort` → `std.sort.pdq()`
- `@fieldParentPtr("field_name", ptr)` — string first
- `StringHashMap.deinit()` does NOT free keys — free via `keyIterator()` first
- `mem.sliceTo` requires sentinel-terminated ptr (`[*:0]u8`), NOT plain `[*]u8`
- Function params shadow same-named methods — rename to avoid compile error
- **`_ = x;` pitfalls:** (1) compile error if x was mutated — restructure to avoid the variable. (2) compile error if x is still used later in the function — the discard is pointless. Remove the discard (and any dead increment before it).
- **Dead code in function bodies:** Zig analyzes ALL function bodies even if never called. An unused `var` inside a dead helper function still triggers "local variable is never mutated." Remove dead functions before compiling.
- `catch` block value: `const x = expr catch blk: { ...; break :blk fallback; };`
- Error set exhaustiveness: concrete reader types have small known error sets — `else` prong may be unreachable. Use bare `catch` or name the specific error.
- **Comptime format strings:** `print("{X:0>2}", .{val})` vs `print("{x:0>2}", .{val})` — format specifiers must be comptime-known. To switch case at runtime, use `if (upper) print("{X:0>2}", .{v}) else print("{x:0>2}", .{v})`. Cannot build format string dynamically.
- `std.ascii.eqlIgnoreCase(a, b)` for case-insensitive string comparison
- `std.time.sleep()` does NOT exist — use `std.Thread.sleep(ns)` (nanoseconds)
- Freeing sub-slices panics: `alloc(N)` then `free(buf[0..M])` = "Invalid free"
- **Narrow arithmetic overflow:** `u8 * 100` stays `u8` — panics if result > 255. Widen first: `@as(u32, narrow_val) * 100`. Same for `+`, `-`, `<<`. Rule: cast to result width BEFORE the operation.
- **Comptime branch elimination:** `const cond = true; if (cond) a else b` evaluates at comptime — dead branch is eliminated, no peer type resolution occurs. To test peer resolution, force runtime: `var cond = true; _ = &cond;`
- **Peer type resolution for errors:** `T` and `error.Foo` resolve to `error{Foo}!T` (specific set), NOT `anyerror!T`. Only explicit annotation or `||` merging produces `anyerror`.
- **Redundant `comptime` keyword:** Module-level `const` and struct-level `const` are already comptime. Writing `const x = comptime blk: { ... }` at these scopes is a compile error. Use plain labeled blocks: `const x = blk: { ... break :blk val; };`

### Build System

- `build.zig.zon`: `.name = .identifier` (enum literal), `.fingerprint = 0xhex`
- `.root_module` (not `.root_source_file`), `b.addModule()` (not `addStaticLibrary`)

## Decision Frameworks

**Allocator:**
| Context | Choice | Reason |
|---------|--------|--------|
| Tests | `testing.allocator` | Fails on leak |
| CLI main | `GeneralPurposeAllocator` | Debug leak detection |
| Per-request / batch | `ArenaAllocator` | Bulk free, zero per-object overhead |
| Stack only | `FixedBufferAllocator` | Zero syscalls |
| C interop | `c_allocator` | Wraps malloc/free |
| Composition | Arena over FixedBuffer | Stack + bulk-free, zero syscalls |
| Stack-first fallback | `stackFallback(size, backing).get()` | Stack buffer, heap overflow |
| OOM testing | `FailingAllocator.init(backing, .{.fail_index=N})` | Fail at Nth alloc |
| Exhaustive OOM | `checkAllAllocationFailures(alloc, fn, extra_args)` | Test every failure point |

**Custom allocator VTable** (4 function pointers — `std.mem.Alignment`, NOT `Allocator.Alignment`):
```zig
alloc:  *const fn(*anyopaque, len: usize, Alignment, ret_addr: usize) ?[*]u8,
resize: *const fn(*anyopaque, []u8, Alignment, new_len: usize, ret_addr: usize) bool,
remap:  *const fn(*anyopaque, []u8, Alignment, new_len: usize, ret_addr: usize) ?[*]u8,
free:   *const fn(*anyopaque, []u8, Alignment, ret_addr: usize) void,
// Delegate via: child.vtable.alloc(child.ptr, ...) — NOT child.rawAlloc(...)
```

**Error handling:**
| Situation | Pattern |
|-----------|---------|
| Internal function | Inferred `!T` — compiler tracks the union |
| Public API boundary | Explicit error set `MyError!T` |
| Can fail OR be absent | `!?T` — unwrap: `(try fn()) orelse default` |
| Provably impossible | `catch unreachable` (with proof comment) |
| Mixed expected/fatal | `catch \|err\| switch (err) { ... }` — not bare catch |

**Comptime vs runtime:**
| Signal | Use comptime |
|--------|-------------|
| Lookup table from fixed data | Generate array at comptime |
| Type-generic code | `fn Container(comptime T: type) type` |
| String→value dispatch | `StaticStringMap` (comptime hash) |
| Config validation | `@compileError` for invalid params |
| Dynamic data / user input | Runtime |

**Comptime checklist** (5 repeated failures in Lesson 04 — scan EVERY time you write comptime code):

| Rule | Error if violated | Fix |
|------|-------------------|-----|
| **No `comptime` on module-level `const`** | `const` at module scope is already comptime — adding `comptime blk:` = compile error | Use plain `blk:` label (no `comptime` keyword) |
| **No `comptime` on struct-level `const`** | Same: `const` inside a returned `struct` type is already comptime | Use plain `blk:` label |
| **Return `*const [N]u8`, not `[]const u8`** | "function called at runtime cannot return value at comptime" | Helper `fn` computes N; return pointer to comptime array |
| **Use `comptime var` + `inline for`** | Plain `var`/`for` don't work in comptime array construction | Both keywords required |
| **Compute lengths inline in comptime blocks** | Local `const len = f()` outside block not recognized as comptime-known inside `comptime blk:` | Call length function directly where needed, or assign inside the comptime block |

**Design patterns:**
| Pattern | Structure | When |
|---------|-----------|------|
| Generic container | `fn Stack(comptime T: type) type { return struct { ... }; }` | Type-parametric data structures |
| Vtable interface | `struct { ptr: *anyopaque, vtable: *const VTable }` + convenience methods | Runtime polymorphism (allocator, writer, reader) |
| Iterator | `fn next(self: *Self) ?T` + `while (it.next()) \|val\|` | Lazy sequences, streaming |
| Iterator adapter | Wrap inner iterator, delegate `next()` with filter/map | Composable transformations |
| Intrusive container | Embed `Node` field in item, recover parent via `@fieldParentPtr` | O(1) insert/remove, no per-node allocation |
| Options struct | Struct with default field values + partial init `.{ .field = val }` | Replacing long parameter lists |
| Builder chaining | Methods return `*Self` for `init().setX().setY().build()` | Fluent configuration |
| Type-erased callback | `ctx: *anyopaque` + `fn(*anyopaque) void` | Event systems, generic hooks |
| State machine | `union(enum) { state1: T1, ... }` + `fn advance(self: *Self)` | Protocol states, parsers |

**Data structure:**
| Need | Use |
|------|-----|
| Dynamic array | `ArrayList` (`.empty`, per-method alloc) |
| JSON array | `json.Array` (`.init(gpa)` — Managed, stored alloc) |
| JSON object | `json.ObjectMap` (`.init(gpa)` — stored alloc) |
| Key→value map | `AutoHashMap`/`StringHashMap` (`.init(gpa)`) |
| Stable pointers across growth | `SegmentedList` |
| Cache-friendly field iteration | `MultiArrayList` (SoA layout) |
| Priority scheduling | `PriorityQueue` (compareFn returns `Order`!) |
| Enum bit flags (no allocator) | `EnumSet` |
| Fixed string→value (O(1)) | `StaticStringMap` |
| O(1) insert/remove, stable ptrs | `DoublyLinkedList` (intrusive) |
| Bounded collection (max N known) | Fixed array `[N]T` + `len: usize` + method (no allocator needed) |

**Concurrency primitives** (all use `.{}` static init — no `.init()` function):
| Primitive | Init | Key API |
|-----------|------|---------|
| `Thread` | `try Thread.spawn(.{}, fn, .{args})` | `.join()` or `.detach()` — handle must be consumed |
| `Mutex` | `.{}` | `.lock()` / `.unlock()` with `defer` |
| `Condition` | `.{}` | `.wait(&mutex)` in **while loop** (spurious wakeups), `.signal()`, `.broadcast()` |
| `RwLock` | `.{}` | `.lockShared()`/`.unlockShared()` (readers), `.lock()`/`.unlock()` (writer) |
| `Semaphore` | `.{ .permits = N }` | `.wait()` (decrement), `.post()` (increment) |
| `WaitGroup` | `.{}` | `.start()` before spawn, `.finish()` in worker via defer, `.wait()` |
| `ResetEvent` | `.{}` | `.set()` / `.wait()` — never `.reset()` while threads wait |
| `Thread.Pool` | `pool.init(.{ .allocator, .n_jobs })` | `pool.spawnWg(&wg, fn, .{args})` — auto start/finish |

**Atomics** (`std.atomic.Value(T)`):
- `fetchAdd`/`fetchSub`/`fetchOr`/`fetchAnd`/`fetchXor`/`swap` — all return **OLD** value
- `cmpxchgStrong(expected, new, succ_ord, fail_ord)` → `?T` (`null` = success, value = actual on failure)
- `cmpxchgWeak` — may spuriously fail, **must** be in retry loop
- Memory ordering: `.release` on store pairs with `.acquire` on load for happens-before
- `Thread.Pool` has `spawnWg(&wg, fn, .{args})` only — no plain `spawn()`. Pool auto-calls `wg.start()` and `wg.finish()`. `n_jobs` is `?usize` (null = CPU count auto-detect).
- `std.Thread.sleep(ns)` for sleep — NOT `std.time.sleep()` (does not exist in 0.15.2)

## Zig-Specific Style

Rules where Zig idiom diverges from other languages:
1. **`if (opt) |val|` not `opt.?`** — payload captures don't panic; `.?` does
2. **`StaticStringMap` for string dispatch** — comptime hash + enum + exhaustive switch
3. **`defer`/`errdefer` adjacent to allocation** — cleanup paired with acquire. LIFO is absolute: `defer` and `errdefer` interleave strictly by registration order, no grouping by type. Defers execute after the return expression is evaluated. See Memory Ownership rule #1 for the double-free trap.
4. **`anytype` for writer params** — concrete writer types don't compose
5. **Create resources once** — writer in main(), pass as parameter
6. **Honor accepted allocators** — never `_ = allocator` then hardcode
7. **`{f}` for custom format** — `{}` ambiguous with format methods; `{any}` skips them
8. **Exhaustive switch** — never `else` when all variants are known

### Pre-Completion Checklist
Before declaring done: function >40 lines? String if-else chain? Same pattern 3x? Magic numbers? Explicit error set >2 types? Unused declarations? Parameter name same as method name? These are recurring quality issues.

### Naming
camelCase (functions/vars), PascalCase (types), snake_case (constants/struct fields).

## RAG Search

A local RAG (ragling) indexes all reference docs and Zig source code via MCP. **Use `rag_search` instead of reading full reference files** — it returns only the relevant chunks, saving significant context and tokens.

| Collection | Contents | When to use |
|---|---|---|
| `zig-references` | Language ref, API ref, pitfalls, comptime, systems, stdlib API extracts | Look up syntax, API patterns, 0.15.2 changes, error fixes |
| `zig-src` | Exercise `.zig` files + quiz specs (tree-sitter parsed) | Find working code examples, review past solutions |
| `zig-stdlib` | Curated Zig 0.15.2 stdlib source (tree-sitter parsed) | Look up exact function signatures, struct fields, implementation details |

**If RAG can't answer an API question**, add the missing reference: run `.claude/scripts/extract-stdlib-api.py` to regenerate stdlib API extracts, or fetch external docs with `WebFetch` and save to `references/`.

```
rag_search(query="ArrayList append 0.15", collection="zig-references")
rag_search(query="posix Stat struct fields", collection="zig-stdlib")
```

**Batch multiple lookups in one call** with `rag_batch_search` — saves tool round-trips (each replay costs O(n) tokens):
```
rag_batch_search(queries=[
  {"query": "ArrayList append", "collection": "zig-stdlib"},
  {"query": "HashMap put getOrPut", "collection": "zig-stdlib"},
  {"query": "error handling patterns", "collection": "zig-references"}
])
```

**Prefer RAG over file reads.** Reference files total 500k+ tokens. A targeted search returns ~10 relevant chunks instead. Read full files only when you need surrounding context that search didn't provide.

### Reference file index

When RAG results aren't sufficient, these are the full files in `references/`:
- **pitfalls-reference.md** — 48 pitfalls + error→fix table *(check FIRST when debugging)*
- **api-reference.md** — Types, collections, strings, I/O, JSON, files, allocators, error patterns, testing, build, data structures
- **systems-reference.md** — Concurrency, networking, crypto, C interop, SIMD
- **comptime-reference.md** — @typeInfo, @Type, meta, type generation, format methods

## Lesson Plans

Training is organized into **lesson plans** in `src/lesson-plans/`. Each plan is a numbered directory containing numbered lessons. A lesson is either a flat `.md` file (quiz only) or a subdirectory with `quiz.md` + fixture files.

**Execution:** Lessons run in two modes. Mode 1: read quiz and SKILL.md once, work exercises, write grades to GRADES.md, return. Mode 2: orchestrator resumes you with cost data — reflect, update SKILL.md, curate snippets, record cost, commit. After completing a plan, write a final self-evaluation report.

**Cost efficiency:** Every tool round-trip replays the full conversation — cost grows O(n²) with turn count. **Batch aggressively:** write multiple solutions in one turn, test them in one turn. **Front-load reads:** read all reference material in your first turn. **Minimize tool results:** pipe verbose output through `head`/`tail`/`grep`. **Fail less:** a compile-fix-recompile cycle costs 3 turns of replay — use RAG before writing, not after failing.

**Creating plans:** Add a numbered directory with lesson entries. The agent can create new plans autonomously.

## Validation

`zig test path/to/exercise.zig`. C interop: `zig test -lc exercises/c_interop.zig`.
