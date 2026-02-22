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

## 0.15.2 API Quick Reference

Training data shows 0.14 patterns. These are the critical 0.15.2 changes. **For full API details, search RAG** (`zig-references` or `zig-stdlib` collections).

### Collection Init (varies by type — check every time)

| Type | Init | Deinit | Method pattern |
|------|------|--------|---------------|
| `ArrayList(T)` | `.empty` | `.deinit(gpa)` | `.append(gpa, val)` — allocator per-method |
| `AutoHashMap`/`StringHashMap` | `.init(gpa)` | `.deinit()` | `.put(k, v)` — stored allocator |
| `json.ObjectMap` | `.init(gpa)` | `.deinit()` | `.put(k, v)` — stored allocator |
| `json.Array` | `.init(gpa)` | `.deinit()` | `.append(v)` — stored allocator |
| `PriorityQueue(T, ctx, cmp)` | `.init(gpa, ctx)` | `.deinit()` | `.add(item)` — stored allocator |
| `GPA(.{})` | `.init` (value literal) | `.deinit()` | N/A |

### Memory Ownership (7 rules)

1. **One owner per resource.** If `errdefer allocator.free(x)` is active, never also manually free `x` before returning an error — double-free.
2. **Defer-free intermediates.** When A allocates and passes to B which also allocates, A's result leaks unless freed: `defer allocator.free(a_result)`.
3. **JSON arena lifetime.** Strings from `parseFromSlice` point into the parsed arena. After `parsed.deinit()`, they dangle. Use `.allocate = .alloc_always` or dupe.
4. **No self-referential slices in value structs.** Slice dangles when struct returned by value. Use `len: usize` + method.
5. **Nested slice constness.** `[][]u8` does not coerce to `[][]const u8`. Allocate `[]const u8` items directly.
6. **`ArrayListUnmanaged.items` is NOT a transferable allocation.** `.items` returns a slice into the list's over-allocated internal buffer. `allocator.free(list.items)` panics — use `.toOwnedSlice(allocator)` to get an exact-sized, independently-freeable allocation.
7. **Never return a slice of a stack-local buffer.** The slice becomes a dangling pointer when the function returns. Either heap-allocate, or have the caller provide the buffer (out-parameter pattern).

### I/O (0.15.2 — NOT getStdOut/getStdErr/getStdIn!)

```zig
// Writing
var wbuf: [4096]u8 = undefined;
var w = std.fs.File.stdout().writer(&wbuf);
const stdout = &w.interface;  // flush() on interface, not w

// Reading lines
var rbuf: [4096]u8 = undefined;
var r = file.reader(&rbuf);
while (r.interface.takeDelimiter('\n')) |line| { ... } // null on EOF

// AtomicFile (safe write-then-rename)
var af = try std.fs.cwd().atomicFile(path, .{ .mode = stat.mode });
defer af.deinit();
// write to af.file ...
try af.finish();
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

**Data structure:** Search RAG for full table. Key choices: `ArrayList` (per-method alloc), `AutoHashMap`/`StringHashMap` (stored alloc), `ArenaAllocator` for batch operations, `StaticStringMap` for compile-time dispatch.

**Concurrency primitives** — all use `.{}` static init (no `.init()`). Search RAG for full API.

## Zig-Specific Style

Rules where Zig idiom diverges from other languages:
1. **`if (opt) |val|` not `opt.?`** — payload captures don't panic; `.?` does
2. **`StaticStringMap` for string dispatch** — comptime hash + enum + exhaustive switch
3. **`defer`/`errdefer` adjacent to allocation** — cleanup paired with acquire. LIFO is absolute.
4. **`anytype` for writer params** — concrete writer types don't compose
5. **Create resources once** — writer in main(), pass as parameter
6. **Honor accepted allocators** — never `_ = allocator` then hardcode
7. **`{f}` for custom format** — `{}` ambiguous with format methods; `{any}` skips them
8. **Exhaustive switch** — never `else` when all variants are known

### Pre-Completion Checklist
Before declaring done: function >40 lines? String if-else chain? Same pattern 3x? Magic numbers? Explicit error set >2 types? Unused declarations? Parameter name same as method name?

### Naming
camelCase (functions/vars), PascalCase (types), snake_case (constants/struct fields).

## RAG Search

A local RAG (ragling) indexes all reference docs and Zig source code. **Use `rag_search` instead of reading full reference files** — it returns only the relevant chunks, saving significant context.

| Collection | Contents | When to use |
|---|---|---|
| `zig-references` | Language ref, API ref, pitfalls, gotchas, comptime, systems, stdlib API extracts | Look up syntax, API patterns, 0.15.2 changes, error fixes |
| `zig-src` | Exercise `.zig` files + quiz specs (tree-sitter parsed) | Find working code examples, review past solutions |
| `zig-stdlib` | Curated Zig 0.15.2 stdlib source (tree-sitter parsed) | Look up exact function signatures, struct fields, implementation details |

**Pre-flight search:** Before writing ANY code for a lesson, search RAG for gotchas relevant to the domain (I/O, networking, crypto, etc.). Front-loads failure patterns into context before they cause compile errors.

```
rag_search(query="getStdOut compile error stdout 0.15", collection="zig-references")
rag_batch_search(queries=[
  {"query": "ArrayList append", "collection": "zig-stdlib"},
  {"query": "error handling patterns", "collection": "zig-references"}
])
```

**CLI alternative** (for background agents without MCP):
```bash
.claude/scripts/rag-search.sh "ArrayList append" --collection zig-stdlib
.claude/scripts/rag-index.sh project zig-references "$PWD/rag/references/"
```

**If RAG can't answer an API question**, add the missing reference: run `.claude/scripts/extract-stdlib-api.py` to regenerate stdlib API extracts, or fetch external docs with `WebFetch` and save to `references/`.

### Writing RAG Entries

When adding gotchas or reference material to `references/`, structure each entry for optimal RAG retrieval (256-token chunks):

1. **H2 header = symptom** (what the agent would search for): `## getStdOut does not exist`
2. **Error text verbatim** — exact compiler message so keyword search matches
3. **Fix** — correct 0.15.2 pattern with minimal code
4. **One entry per chunk** — ~100-150 words. Don't combine unrelated gotchas under one header.

Bad: `## Common I/O Errors` (too broad, multiple unrelated fixes)
Good: `## flush() on Writer interface, not struct` (specific symptom, one fix)

### Reference file index

When RAG results aren't sufficient, these are the full files in `references/`:
- **pitfalls-reference.md** — 48 pitfalls + error→fix table *(check FIRST when debugging)*
- **api-reference.md** — Types, collections, strings, I/O, JSON, files, allocators, testing, build
- **systems-reference.md** — Concurrency, networking, crypto, C interop, SIMD
- **comptime-reference.md** — @typeInfo, @Type, meta, type generation, format methods
- **gotchas.md** — Compiler gotchas (migrated from SKILL.md for RAG indexing)

## Lesson Plans

Training is organized into **lesson plans** in `src/lesson-plans/`. Each plan is a numbered directory containing numbered lessons. A lesson is either a flat `.md` file (quiz only) or a subdirectory with `quiz.md` + fixture files.

**Execution:** Lessons run in two modes. Mode 1: read quiz and SKILL.md once, work exercises, write grades to GRADES.md, return. Mode 2: orchestrator resumes you with cost data — reflect, update SKILL.md, curate snippets, record cost, commit. After completing a plan, write a final self-evaluation report.

**Cost efficiency:** Every tool round-trip replays the full conversation — cost grows O(n²) with turn count. **Batch aggressively:** write multiple solutions in one turn, test them in one turn. **Front-load reads:** read all reference material in your first turn. **Minimize tool results:** pipe verbose output through `head`/`tail`/`grep`. **Fail less:** a compile-fix-recompile cycle costs 3 turns of replay — use RAG before writing, not after failing.

**Creating plans:** Add a numbered directory with lesson entries. The agent can create new plans autonomously.

## Validation

`zig test path/to/exercise.zig`. C interop: `zig test -lc exercises/c_interop.zig`.
