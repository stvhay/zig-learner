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

**Consequence:** Use `undefined` for uninitialized memory (fills with 0xAA in debug — detects reads). Use `+` for checked arithmetic (panics on overflow), `+%` for intentional wrapping, `+|` for saturating.

## 0.15.2 API Corrections

These changed from 0.14. Training data overwhelmingly shows the OLD way. Full pitfall list: **pitfalls-reference.md**.

```zig
// ArrayList: .empty + per-method allocator (NOT .init())
var list: std.ArrayList(i32) = .empty;
defer list.deinit(gpa);
try list.append(gpa, 42);

// HashMap: .init(gpa) — stored allocator (inconsistent with ArrayList!)
var map = std.AutoHashMap(K, V).init(gpa);

// GPA: value literal (NOT .init{})
var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
defer _ = gpa.deinit();

// stdout/stderr/stdin (NOT std.io.getStdOut/getStdErr/getStdIn!)
var buf: [1024]u8 = undefined;
var w = std.fs.File.stdout().writer(&buf);
const stdout = &w.interface;  // flush() HERE, not on w
const stdin_file = std.fs.File.stdin();  // for raw reads: stdin_file.read(&buf)

// JSON serialize (no stringify/stringifyAlloc)
const s = try std.fmt.allocPrint(gpa, "{f}", .{std.json.fmt(value, .{})});

// Writer params: anytype (AnyWriter ≠ Writer from .interface)
fn process(stdout: anytype, stderr: anytype) !void { ... }

// !?T: try THEN orelse
const line = (try readLine(stdin, &buf)) orelse break;

// CLI args: argsWithAllocator (NOT argsAlloc + free)
var args = std.process.argsWithAllocator(gpa) catch ...;
defer args.deinit();

// Bit shifts: cast to target width BEFORE shifting
const byte: u8 = (@as(u8, nibble) << 4) | low;

// Custom format: 2 params only, use {f} specifier
pub fn format(self: Self, writer: anytype) !void { ... }

// catch |_| → bare catch; sort → std.sort.pdq()
// @fieldParentPtr("field_name", ptr) — string first
// StringHashMap.deinit() does NOT free keys — free via keyIterator() first
// No self-referential slices in value structs — use method to reconstruct
// mem.sliceTo requires sentinel-terminated ptr ([*:0]u8), NOT plain [*]u8
// Function params shadow same-named methods — rename to avoid compile error
```

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

**Comptime string/array returns:** Functions with comptime params that build strings/arrays must return `*const [N]u8` where N is comptime-known (use a helper `fn` to compute length). Returning `[]const u8` from a comptime block inside such a function fails with "function called at runtime cannot return value at comptime". Use `comptime var` + `inline for` to fill the buffer. Variables used in comptime loops inside these functions need `comptime var` (not plain `var`) and `inline for` (not plain `for`). Same pattern applies to `const` decls inside returned struct types — omit redundant `comptime` keyword since struct-level `const` is already comptime.

**Data structure:**
| Need | Use |
|------|-----|
| Dynamic array | `ArrayList` (`.empty`, per-method alloc) |
| Key→value map | `AutoHashMap`/`StringHashMap` (`.init(gpa)`) |
| Stable pointers across growth | `SegmentedList` |
| Cache-friendly field iteration | `MultiArrayList` (SoA layout) |
| Priority scheduling | `PriorityQueue` (compareFn returns `Order`!) |
| Enum bit flags (no allocator) | `EnumSet` |
| Fixed string→value (O(1)) | `StaticStringMap` |
| O(1) insert/remove, stable ptrs | `DoublyLinkedList` (intrusive) |

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
| `Thread.Pool` | `pool.init(.{ .allocator, .n_jobs })` | `try pool.spawn(fn, args)` — returns error union! |

**Atomics** (`std.atomic.Value(T)`):
- `fetchAdd`/`fetchSub`/`fetchOr`/`fetchAnd`/`fetchXor`/`swap` — all return **OLD** value
- `cmpxchgStrong(expected, new, succ_ord, fail_ord)` → `?T` (`null` = success, value = actual on failure)
- `cmpxchgWeak` — may spuriously fail, **must** be in retry loop
- Memory ordering: `.release` on store pairs with `.acquire` on load for happens-before
- `Thread.Pool.spawn` returns error union — must use `try`; pool does NOT call `wg.finish()` for you

## Zig-Specific Style

Rules where Zig idiom diverges from other languages:
1. **`if (opt) |val|` not `opt.?`** — payload captures don't panic; `.?` does
2. **`StaticStringMap` for string dispatch** — comptime hash + enum + exhaustive switch
3. **`defer`/`errdefer` adjacent to allocation** — cleanup paired with acquire. **LIFO is absolute**: on the error path, `defer` and `errdefer` interleave strictly by registration order (last registered = first to fire). A `defer` registered *after* an `errdefer` fires *before* the errdefer — there is no grouping by type. **Timing**: defers execute *after* the return expression is evaluated — you cannot observe their side effects through a function's return value.
4. **`anytype` for writer params** — concrete writer types don't compose
5. **Create resources once** — writer in main(), pass as parameter
6. **Honor accepted allocators** — never `_ = allocator` then hardcode
7. **`{f}` for custom format** — `{}` ambiguous with format methods; `{any}` skips them
8. **Exhaustive switch** — never `else` when all variants are known

### Pre-Completion Checklist
Before declaring done: function >40 lines? String if-else chain? Same pattern 3x? Magic numbers? Explicit error set >2 types? Unused declarations? These are recurring quality issues.

### Naming
camelCase (functions/vars), PascalCase (types), snake_case (constants/struct fields).

## RAG Search

A local RAG (ragling) indexes all reference docs and Zig source code via MCP. **Use `rag_search` instead of reading full reference files** — it returns only the relevant chunks, saving significant context and tokens.

| Collection | Contents | When to use |
|---|---|---|
| `zig-references` | Language ref, API ref, pitfalls, comptime, systems | Look up syntax, API patterns, 0.15.2 changes, error fixes |
| `zig-src` | Exercise `.zig` files + quiz specs (tree-sitter parsed) | Find working code examples, review past solutions |

```
rag_search(query="ArrayList append 0.15", collection="zig-references")
rag_search(query="generic stack allocator", collection="zig-src")
rag_search(query="HashMap deinit keys")  // searches all collections
```

**Prefer RAG over file reads.** Reference files total 500k+ tokens. A targeted `rag_search` returns ~10 relevant chunks instead. Read full files only when you need surrounding context that search didn't provide.

### Reference file index

When RAG results aren't sufficient, these are the full files in `references/`:
- **pitfalls-reference.md** — 48 pitfalls + error→fix table *(check FIRST when debugging)*
- **api-reference.md** — Types, collections, strings, I/O, JSON, files, allocators, error patterns, testing, build, data structures
- **systems-reference.md** — Concurrency, networking, crypto, C interop, SIMD
- **comptime-reference.md** — @typeInfo, @Type, meta, type generation, format methods

## Lesson Plans

Training is organized into **lesson plans** in `src/lesson-plans/`. Each plan is a numbered directory containing numbered lessons. A lesson is either a flat `.md` file (quiz only) or a subdirectory with `quiz.md` + fixture files.

**Execution:** Work through lessons in order. Grade each, reflect, update skill. After completing a plan, write a final self-evaluation report. Record grades in `GRADES.md` within the plan directory.

**Token efficiency:** Minimize token waste — read the quiz once (not per-exercise), batch difficulty-1 exercises, use RAG instead of full file reads. Record estimated token usage in GRADES.md for each lesson (total tokens, tool calls, tokens/exercise) to track learning throughput.

**Creating plans:** Add a numbered directory with lesson entries. The agent can create new plans autonomously.

## Validation

`zig test path/to/exercise.zig`. C interop: `zig test -lc exercises/c_interop.zig`.
