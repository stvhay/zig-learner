# 00-bootstrap: Run 3

## Scoring System

Each exercise is scored on three components (max 105, min 0):

| Component | Base | Adjustments |
|-----------|------|-------------|
| **Correctness** | 30 | -5 new mistake, -10 repeated (in SKILL.md) |
| **Quality** | — | A: +30, B: +20, C: +10, D: +0, F: -20 |
| **Efficiency** | — | 30% cost reduction = +40. Each 1% less: -1. Can go negative. |

**Lesson score:** `(avg_exercise_score / 100) × level_points`

| Level | Pts | Lessons |
|-------|-----|---------|
| 0 | 5 | 1–6 |
| 1 | 15 | 7–11, 14 |
| 2 | 30 | 12, 16 |
| 3 | 50 | 13, 15, 17 |

**Total pool: 330 pts.** 100 = expected score. 105 = ceiling.

**Baselines:** `baselines.json` — min(Run 1, Run 2) per lesson.

**Prior runs:** See `GRADES-run1.md` and `GRADES-run2.md`.

---

<!-- Lesson sections appended below as Run 3 progresses -->

## Lesson 01: Core Language Fundamentals (Level 0, 5 pts)

### Summary

| # | Topic | Pts | Correct | Quality | Efficiency | Compile Fails | Score |
|---|-------|-----|---------|---------|------------|---------------|-------|
| 1 | Primitive types — integer sizes and signedness | 5 | 30 | A (+30) | -12 | 0 | 48 |
| 2 | Primitive types — floats, bool, void | 5 | 30 | A (+30) | -12 | 0 | 48 |
| 3 | Variables — const vs var semantics | 5 | 30 | A (+30) | -12 | 0 | 48 |
| 4 | Variables — undefined initialization | 5 | 30 | A (+30) | -12 | 0 | 48 |
| 5 | Control flow — if/else as expression | 5 | 30 | A (+30) | -12 | 0 | 48 |
| 6 | Control flow — switch exhaustiveness and ranges | 5 | 30 | A (+30) | -12 | 0 | 48 |
| 7 | Control flow — for loops with slices and ranges | 5 | 30 | A (+30) | -12 | 0 | 48 |
| 8 | Control flow — while with continue expression | 5 | 30 | A (+30) | -12 | 0 | 48 |
| 9 | Functions — basic parameters and return types | 5 | 30 | A (+30) | -12 | 0 | 48 |
| 10 | Errors — error sets and try/catch | 5 | 30 | A (+30) | -12 | 0 | 48 |
| 11 | Optionals — ?T, orelse, if-unwrap | 5 | 30 | A (+30) | -12 | 0 | 48 |
| 12 | Tagged unions — definition and switch dispatch | 5 | 30 | A (+30) | -12 | 0 | 48 |
| 13 | Slices and arrays — basics, len, ptr | 5 | 30 | A (+30) | -12 | 0 | 48 |
| 14 | Defer — basic LIFO ordering | 5 | 30 | A (+30) | -12 | 0 | 48 |
| 15 | Comptime — comptime blocks and parameters | 10 | 30 | A (+30) | -12 | 0 | 48 |
| 16 | Comptime — @typeInfo and @typeName | 10 | 30 | A (+30) | -12 | 0 | 48 |
| 17 | Control flow — labeled blocks and breaks | 10 | 30 | A (+30) | -12 | 0 | 48 |
| 18 | Functions — error unions as returns and function ptrs | 10 | 30 | A (+30) | -12 | 0 | 48 |
| 19 | Errors — errdefer only runs on error path | 10 | 30 | A (+30) | -12 | 0 | 48 |
| 20 | Tagged unions — methods and void members | 10 | 30 | A (+30) | -12 | 0 | 48 |
| 21 | Slices — sentinel-terminated and multi-dimensional | 10 | 30 | A (+30) | -12 | 0 | 48 |
| 22 | Packed structs — @bitSizeOf vs @sizeOf | 10 | 30 | A (+30) | -12 | 0 | 48 |
| 23 | Peer type resolution in if/switch expressions | 20 | 30 | A (+30) | -12 | 0 | 48 |
| 24 | Casting and coercion — @intCast, @truncate, conversions | 20 | 25 | A (+30) | -12 | 1 | 43 |
| 25 | Defer + errdefer interactions in loops and nesting | 10 | 30 | A (+30) | -12 | 0 | 48 |

**Average exercise score:** (48 × 24 + 43) / 25 = 1195 / 25 = 47.80 / 100

**Lesson score:** (47.80 / 100) × 5 = **2.39 / 5 pts**

### Compile Failure Log

| Exercise | Error | Fix | New/Known |
|----------|-------|-----|-----------|
| 24 | `@enumFromInt` inline in `expectEqual` — compiler cannot infer result type | Bind to typed `const` variable first | New |

### Token Usage

| Metric | Value |
|--------|-------|
| Turns | 9 |
| Total cost | $1.27 |
| Baseline (Run 2) | $1.04 (16 turns) |
| Cost reduction | -22% (over baseline) |
| Efficiency score | -12 |
| System replay | $0.05 |
| Context replay | $0.22 |
| Cache write | $0.72 |
| Output | $0.28 |

---

## Lesson 02: Standard Library Essentials (Level 0, 5 pts)

### Summary

| # | Topic | Pts | Correct | Quality | Efficiency | Compile Fails | Score |
|---|-------|-----|---------|---------|------------|---------------|-------|
| 1 | ArrayList .empty init, append, items | 5 | 30 | A (+30) | +21 | 0 | 81 |
| 2 | ArrayList appendSlice | 5 | 30 | A (+30) | +21 | 0 | 81 |
| 3 | ArrayList insert and orderedRemove | 5 | 30 | A (+30) | +21 | 0 | 81 |
| 4 | ArrayList swapRemove and pop | 5 | 30 | A (+30) | +21 | 0 | 81 |
| 5 | ArrayList clearRetainingCapacity | 5 | 30 | A (+30) | +21 | 0 | 81 |
| 6 | ArrayList ensureTotalCapacity + sort | 10 | 30 | A (+30) | +21 | 0 | 81 |
| 7 | AutoHashMap init, put, get, contains | 5 | 30 | A (+30) | +21 | 0 | 81 |
| 8 | AutoHashMap getOrPut upsert | 10 | 30 | A (+30) | +21 | 0 | 81 |
| 9 | AutoHashMap remove, iterator | 10 | 30 | A (+30) | +21 | 0 | 81 |
| 10 | StringHashMap string keys | 5 | 30 | A (+30) | +21 | 0 | 81 |
| 11 | mem.eql, startsWith, endsWith | 5 | 30 | A (+30) | +21 | 0 | 81 |
| 12 | mem.indexOf and lastIndexOf | 5 | 30 | A (+30) | +21 | 0 | 81 |
| 13 | mem.trim, trimLeft, trimRight | 5 | 30 | A (+30) | +21 | 0 | 81 |
| 14 | mem.splitScalar and splitSequence | 10 | 30 | A (+30) | +21 | 0 | 81 |
| 15 | mem.tokenizeScalar vs splitScalar | 10 | 30 | A (+30) | +21 | 0 | 81 |
| 16 | mem.zeroes, asBytes, concat, replaceOwned | 10 | 30 | A (+30) | +21 | 0 | 81 |
| 17 | fmt.bufPrint | 5 | 30 | A (+30) | +21 | 0 | 81 |
| 18 | fmt.allocPrint and comptimePrint | 10 | 30 | A (+30) | +21 | 0 | 81 |
| 19 | fmt padding, hex, binary, float | 10 | 30 | A (+30) | +21 | 0 | 81 |
| 20 | sort.pdq ascending and descending | 5 | 30 | A (+30) | +21 | 0 | 81 |
| 21 | sort.pdq custom comparator and isSorted | 10 | 30 | A (+30) | +21 | 0 | 81 |
| 22 | math @min/@max, clamp, isPowerOfTwo | 5 | 30 | A (+30) | +21 | 0 | 81 |
| 23 | math log2_int, divCeil, maxInt | 5 | 25 | A (+30) | +21 | 1 | 76 |
| 24 | JSON parseFromSlice struct and dynamic | 20 | 30 | A (+30) | +21 | 0 | 81 |
| 25 | JSON serialize json.fmt, round-trip | 20 | 30 | A (+30) | +21 | 0 | 81 |

**Average exercise score:** (24 × 81 + 76) / 25 = 2020 / 25 = 80.80 / 105

**Lesson score:** (80.80 / 100) × 5 = **4.04 / 5 pts**

### Compile Failure Log

| Exercise | Error | Fix | New/Known |
|----------|-------|-----|-----------|
| 23 | `math.log2_int` takes `(comptime T: type, x: T)` not `(typed_value)` | Pass type as separate first arg | New |

### Token Usage

| Metric | Value |
|--------|-------|
| Turns | 16 |
| Total cost | $1.51 |
| Baseline (Run 2) | $1.70 (11 turns) |
| Cost reduction | +11% |
| Efficiency score | +21 |
| System replay | $0.09 |
| Context replay | $0.42 |
| Cache write | $0.72 |
| Output | $0.28 |

---

## Lesson 03: Error Handling & Allocators (Level 0, 5 pts)

### Summary

| # | Topic | Pts | Correct | Quality | Efficiency | Compile Fails | Score |
|---|-------|-----|---------|---------|------------|---------------|-------|
| 1 | Error sets — declaration and named | 5 | 30 | A (+30) | +36 | 0 | 96 |
| 2 | Error sets — anonymous/inferred | 5 | 30 | A (+30) | +36 | 0 | 96 |
| 3 | Error sets — merging with \|\| | 5 | 30 | A (+30) | +36 | 0 | 96 |
| 4 | Error sets — @errorName introspection | 5 | 30 | A (+30) | +36 | 0 | 96 |
| 5 | Error sets — @intFromError numeric identity | 5 | 25 | A (+30) | +36 | 1 | 91 |
| 6 | Error unions — basic ErrorSet!T and try | 5 | 30 | A (+30) | +36 | 0 | 96 |
| 7 | Error unions — catch with fallback | 5 | 30 | A (+30) | +36 | 0 | 96 |
| 8 | Error unions — catch with error payload | 5 | 30 | A (+30) | +36 | 0 | 96 |
| 9 | Error unions — if-else error unwrap | 5 | 30 | A (+30) | +36 | 0 | 96 |
| 10 | errdefer — basic cleanup on error path | 5 | 30 | A (+30) | +36 | 0 | 96 |
| 11 | errdefer — ordering (LIFO) | 5 | 30 | A (+30) | +36 | 0 | 96 |
| 12 | errdefer — \|err\| capture | 5 | 30 | A (+30) | +36 | 0 | 96 |
| 13 | Error handling in loops — break on error | 5 | 30 | A (+30) | +36 | 0 | 96 |
| 14 | Error handling in loops — partial cleanup | 5 | 30 | A (+30) | +36 | 0 | 96 |
| 15 | FixedBufferAllocator — stack-based | 10 | 30 | A (+30) | +36 | 0 | 96 |
| 16 | FixedBufferAllocator — reset | 10 | 30 | A (+30) | +36 | 0 | 96 |
| 17 | ArenaAllocator — basics | 10 | 30 | A (+30) | +36 | 0 | 96 |
| 18 | ArenaAllocator — reset modes | 10 | 30 | A (+30) | +36 | 0 | 96 |
| 19 | FailingAllocator — fail at index | 10 | 30 | A (+30) | +36 | 0 | 96 |
| 20 | FailingAllocator — stats tracking | 10 | 30 | A (+30) | +36 | 0 | 96 |
| 21 | checkAllAllocationFailures — exhaustive OOM | 10 | 30 | A (+30) | +36 | 0 | 96 |
| 22 | Error set merging multi-layer | 10 | 30 | A (+30) | +36 | 0 | 96 |
| 23 | StackFallbackAllocator — stack-first | 10 | 30 | A (+30) | +36 | 0 | 96 |
| 24 | Custom allocator — VTable | 20 | 30 | A (+30) | +36 | 0 | 96 |
| 25 | Allocator composition — arena+fixed+OOM | 20 | 30 | A (+30) | +36 | 0 | 96 |

**Average exercise score:** (24 × 96 + 91) / 25 = 2395 / 25 = 95.80 / 105

**Lesson score:** (95.80 / 100) × 5 = **4.79 / 5 pts**

### Compile Failure Log

| Exercise | Error | Fix | New/Known |
|----------|-------|-----|-----------|
| 5 | Variable `i1` shadows Zig primitive type `i1` (1-bit signed integer) | Rename variable to `int1` or `val1` — avoid all primitive type names (`i1`–`i64`, `u1`–`u64`, `f16`–`f128`) | New |

### Token Usage

| Metric | Value |
|--------|-------|
| Turns | 33 |
| Total cost | $2.39 |
| Baseline (Run 2) | $3.24 (23 turns) |
| Cost reduction | +26% |
| Efficiency score | +36 |
| System replay | $0.19 |
| Context replay | $1.01 |
| Cache write | $0.86 |
| Output | $0.32 |

---

## Lesson 04: Comptime & Metaprogramming (Level 0, 5 pts)

### Summary

| # | Topic | Pts | Correct | Quality | Efficiency | Compile Fails | Score |
|---|-------|-----|---------|---------|------------|---------------|-------|
| 1 | comptime var in blocks | 5 | 20 | A (+30) | +30 | 2 | 80 |
| 2 | comptime function parameters | 5 | 30 | A (+30) | +30 | 0 | 90 |
| 3 | comptime recursive factorial | 5 | 30 | A (+30) | +30 | 0 | 90 |
| 4 | @typeInfo integers/floats | 5 | 30 | A (+30) | +30 | 0 | 90 |
| 5 | @typeInfo structs | 10 | 30 | A (+30) | +30 | 0 | 90 |
| 6 | @typeInfo diverse types | 10 | 30 | A (+30) | +30 | 0 | 90 |
| 7 | @Type generate struct | 10 | 25 | A (+30) | +30 | 1 | 85 |
| 8 | @Type generate enum | 10 | 30 | A (+30) | +30 | 0 | 90 |
| 9 | @typeName | 5 | 30 | A (+30) | +30 | 0 | 90 |
| 10 | std.meta fields/fieldNames/FieldEnum | 5 | 30 | A (+30) | +30 | 0 | 90 |
| 11 | std.meta stringToEnum/activeTag | 5 | 30 | A (+30) | +30 | 0 | 90 |
| 12 | std.meta hasFn/eql/Tag | 5 | 25 | A (+30) | +30 | 1 | 85 |
| 13 | comptime ++ and ** | 5 | 30 | A (+30) | +30 | 0 | 90 |
| 14 | comptimePrint | 5 | 30 | A (+30) | +30 | 0 | 90 |
| 15 | comptime join and reverse | 10 | 25 | A (+30) | +30 | 1 | 85 |
| 16 | base64 encode/decode tables | 10 | 30 | A (+30) | +30 | 0 | 90 |
| 17 | precomputed squares | 5 | 30 | A (+30) | +30 | 0 | 90 |
| 18 | inline for over types | 5 | 30 | A (+30) | +30 | 0 | 90 |
| 19 | inline for over struct fields | 10 | 30 | A (+30) | +30 | 0 | 90 |
| 20 | @compileError static assertions | 5 | 30 | A (+30) | +30 | 0 | 90 |
| 21 | @hasDecl and @hasField | 5 | 25 | A (+30) | +30 | 1 | 85 |
| 22 | builder pattern | 10 | 25 | A (+30) | +30 | 1 | 85 |
| 23 | custom format {f} | 10 | 30 | A (+30) | +30 | 0 | 90 |
| 24 | Nullable<T> via @Type | 20 | 25 | A (+30) | +30 | 1 | 85 |
| 25 | comptime state machine | 20 | 30 | A (+30) | +30 | 0 | 90 |

**Average exercise score:** (18 x 90 + 6 x 85 + 1 x 80) / 25 = 2210 / 25 = 88.40 / 105

**Lesson score:** (88.40 / 100) x 5 = **4.42 / 5 pts**

### Compile Failure Log

| Exercise | Error | Fix | New/Known |
|----------|-------|-----|-----------|
| 1 | `for (1..11)` produces `usize`, can't `+=` to `u32` | `@intCast(i)` | New |
| 1 | `const sum = blk:` in test — not comptime-known for array size | `comptime blk:` | New |
| 7 | `StructField.alignment = 0` — must be >= 1 for sized types | `@alignOf(field.type)` | New |
| 12 | `meta.Tag(Value) == @TypeOf(.integer)` — different types | Introspect tag enum fields | New |
| 15 | `comptimeJoin` returning `[]const u8` — "cannot return comptime value at runtime" | Return `*const [N]u8` | Known (gotchas.md) |
| 21 | Same comptime return issue as Ex15 | Same fix | Known (gotchas.md) |
| 22 | Same comptime return issue in `StructBuilder.init()` | Wrap in `comptime blk: { ... break :blk r; }` | Known (gotchas.md) |
| 24 | Same `alignment = 0` issue as Ex07 | `@alignOf(NullableField)` | Known (gotchas.md, after Ex07 fix) |

**5 distinct patterns, 4 new + 1 known.** 7 exercises with deductions, 18/25 clean passes.

### Token Usage

| Metric | Value |
|--------|-------|
| Turns | 16 |
| Total cost | $1.69 |
| Baseline (Run 2) | $2.11 (21 turns) |
| Cost reduction | +20% |
| Efficiency score | +30 |
| System replay | $0.09 |
| Context replay | $0.44 |
| Cache write | $0.77 |
| Output | $0.38 |

---

## Lesson 05: Idioms & Design Patterns (Level 0, 5 pts)

### Summary

| # | Topic | Pts | Correct | Quality | Efficiency | Compile Fails | Score |
|---|-------|-----|---------|---------|------------|---------------|-------|
| 1 | Generic Stack(T) | 5 | 30 | A (+30) | -18 | 0 | 42 |
| 2 | Multi-type instantiation | 5 | 30 | A (+30) | -18 | 0 | 42 |
| 3 | Vtable interface — basic | 5 | 30 | A (+30) | -18 | 0 | 42 |
| 4 | Vtable — polymorphic array | 10 | 30 | A (+30) | -18 | 0 | 42 |
| 5 | Iterator — next() ?T | 5 | 30 | A (+30) | -18 | 0 | 42 |
| 6 | Filter iterator adapter | 10 | 30 | A (+30) | -18 | 0 | 42 |
| 7 | Writer — GenericWriter custom | 5 | 30 | A (+30) | -18 | 0 | 42 |
| 8 | Writer — ArrayList + fbs | 5 | 30 | A (+30) | -18 | 0 | 42 |
| 9 | Allocator convention | 5 | 30 | A (+30) | -18 | 0 | 42 |
| 10 | Arena scoped lifetime | 10 | 30 | A (+30) | -18 | 0 | 42 |
| 11 | RAII / defer | 5 | 30 | A (+30) | -18 | 0 | 42 |
| 12 | errdefer partial init | 10 | 30 | A (+30) | -18 | 0 | 42 |
| 13 | Sentinel slices — properties | 5 | 30 | A (+30) | -18 | 0 | 42 |
| 14 | Sentinel — mem.span, sliceTo | 5 | 30 | A (+30) | -18 | 0 | 42 |
| 15 | @fieldParentPtr — basic | 5 | 30 | A (+30) | -18 | 0 | 42 |
| 16 | @fieldParentPtr — intrusive list | 10 | 30 | A (+30) | -18 | 0 | 42 |
| 17 | BoundedBuffer(T, cap) | 10 | 30 | A (+30) | -18 | 0 | 42 |
| 18 | Comptime validation + comptimePrint | 5 | 30 | A (+30) | -18 | 0 | 42 |
| 19 | Tagged union state machine | 10 | 30 | A (+30) | -18 | 0 | 42 |
| 20 | Traffic light — exhaustive switch | 5 | 30 | A (+30) | -18 | 0 | 42 |
| 21 | Options struct — defaults | 5 | 30 | A (+30) | -18 | 0 | 42 |
| 22 | Builder-style chaining | 10 | 30 | A (+30) | -18 | 0 | 42 |
| 23 | Type-erased callbacks | 10 | 30 | A (+30) | -18 | 0 | 42 |
| 24 | Deque — generic container + iterator | 20 | 20 | A (+30) | -18 | 1 | 32 |
| 25 | Event system — vtable + callbacks | 20 | 30 | A (+30) | -18 | 0 | 42 |

**Average exercise score:** (42 x 24 + 32) / 25 = 1040 / 25 = 41.60 / 105

**Lesson score:** (41.60 / 100) x 5 = **2.08 / 5 pts**

### Compile Failure Log

| Exercise | Error | Fix | New/Known |
|----------|-------|-----|-----------|
| 24 | Parameter `capacity` shadows method `capacity` | Rename parameter to `cap` | Known (gotchas.md: "Function parameter shadows method name") |

**Note:** This is a REPEATED mistake — the "Function parameter shadows method name" pattern is already documented in `gotchas.md`. Deduction is -10 (repeated), not -5 (new). The pre-completion checklist in SKILL.md also lists "Parameter name same as method name?" — this check was not followed.

### Per-Exercise Detail

#### Ex 1: Generic Stack(T) (5pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — clean first compile, tests pass
- **Quality:** A (+30) — Clean generic pattern, proper error return for overflow, optional for pop

#### Ex 2: Multi-type instantiation (5pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — All three type instantiations work, type distinctness verified
- **Quality:** A (+30) — Demonstrates type-level generics with type inequality check

#### Ex 3: Vtable interface — basic (5pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Fat pointer pattern works, string returned through vtable
- **Quality:** A (+30) — Clean separation of interface/implementation, proper @ptrCast/@alignCast

#### Ex 4: Vtable — polymorphic array (10pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Two implementors in array, runtime polymorphism verified
- **Quality:** A (+30) — Well-structured, each type has own vtable const + helper method

#### Ex 5: Iterator — next() ?T (5pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Countdown yields 5,4,3,2,1 correctly, sum=15
- **Quality:** A (+30) — Idiomatic ?T return, while-optional consumption

#### Ex 6: Filter iterator adapter (10pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Even filter produces {2,4,6,8}
- **Quality:** A (+30) — Clean predicate function pointer, proper skip logic

#### Ex 7: Writer — GenericWriter custom (5pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Uppercase conversion works through GenericWriter
- **Quality:** A (+30) — Uses GenericWriter properly

#### Ex 8: Writer — ArrayList + fixedBufferStream (5pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Both writers produce identical "x=10, y=20"
- **Quality:** A (+30) — Uses 0.15.2 APIs: `list.writer(gpa)`, `fbs.writer()`, `fbs.getWritten()`

#### Ex 9: Allocator convention (5pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — DynamicString allocates and copies correctly
- **Quality:** A (+30) — Proper init/deinit pair, allocator-as-parameter convention

#### Ex 10: Arena scoped lifetime (10pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Multiple allocations, single deinit, no leaks
- **Quality:** A (+30) — Demonstrates different allocation types (u8, u32), page_allocator backing

#### Ex 11: RAII / defer (5pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Nested scope cleanup verified via shared counter
- **Quality:** A (+30) — Clean init/deinit pattern with shared state tracking

#### Ex 12: errdefer partial init (10pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Error path frees first buffer, success path returns both
- **Quality:** A (+30) — Proper errdefer placement, testing.allocator detects leaks

#### Ex 13: Sentinel slices — properties (5pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — All 4 sentinel properties verified plus allocSentinel
- **Quality:** A (+30) — Comprehensive: len, null byte, coercions, heap sentinel

#### Ex 14: Sentinel — mem.span, sliceTo (5pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — mem.span and sliceTo both produce expected slices
- **Quality:** A (+30) — Correct use of [*:0] pointer types, proper sentinel construction

#### Ex 15: @fieldParentPtr — basic (5pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Parent recovered from embedded hook field
- **Quality:** A (+30) — Clean helper method, pointer identity verified

#### Ex 16: @fieldParentPtr — intrusive list (10pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Forward traversal collects all 3 names in order
- **Quality:** A (+30) — Doubly-linked list, proper node linking, @fieldParentPtr in traversal

#### Ex 17: BoundedBuffer(T, cap) (10pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Full/empty checks, overflow error, LIFO pop order
- **Quality:** A (+30) — Two comptime parameters, all 4 methods clean

#### Ex 18: Comptime validation + comptimePrint (5pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — @compileError for invalid sizes, comptimePrint description works
- **Quality:** A (+30) — Matrix with 2D array, get/set methods, comptime description const

#### Ex 19: Tagged union state machine (10pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Success and failure paths fully verified
- **Quality:** A (+30) — All 4 states, payload-carrying variants, exhaustive switch in advance

#### Ex 20: Traffic light — exhaustive switch (5pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Cycles red->green->yellow->red
- **Quality:** A (+30) — Exhaustive switch, meta.activeTag for verification

#### Ex 21: Options struct — defaults (5pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — All three initialization patterns verified
- **Quality:** A (+30) — Clean struct defaults, 3 test cases

#### Ex 22: Builder-style chaining (10pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Full query string matches expected output
- **Quality:** A (+30) — Method chaining via *Self return, fixedBufferStream for building

#### Ex 23: Type-erased callbacks (10pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Accumulator incremented 3 times correctly
- **Quality:** A (+30) — Clean @ptrCast/@alignCast recovery, proper callback struct

#### Ex 24: Deque — generic container + iterator (20pts)
- **Compile attempts:** 1 failure (parameter `capacity` shadows method `capacity`)
- **Correctness:** 20/30 — -10 for repeated compile failure (pattern in gotchas.md); tests pass after fix
- **Quality:** A (+30) — Ring buffer implementation, front/back push/pop, iterator struct
- **Reflection:** The pre-completion checklist explicitly asks "Parameter name same as method name?" This check was skipped. The gotcha has been documented since Run 2. This is a discipline failure, not a knowledge gap.

#### Ex 25: Event system — vtable + callbacks (20pts)
- **Compile attempts:** 0 failures
- **Correctness:** 30/30 — Logger captures event names, Counter increments per event
- **Quality:** A (+30) — Full vtable pattern for Listener, EventBus with fixed array, two distinct implementors

### Token Usage

| Metric | Value |
|--------|-------|
| Turns | 22 |
| Total cost | $1.92 |
| Baseline (Run 2) | $1.50 (14 turns) |
| Cost reduction | -28% (over baseline) |
| Efficiency score | -18 |
| System replay | $0.13 |
| Context replay | $0.63 |
| Cache write | $0.83 |
| Output | $0.33 |

---

## Lesson 06: Concurrency & Threading (Level 0, 5 pts)

### Summary

| # | Topic | Pts | Correct | Quality | Efficiency | Compile Fails | Score |
|---|-------|-----|---------|---------|------------|---------------|-------|
| 1 | Thread.spawn and join | 5 | 30 | A (+30) | -34 | 0 | 26 |
| 2 | Multiple threads — parallel writes | 5 | 30 | A (+30) | -34 | 0 | 26 |
| 3 | threadlocal variables | 5 | 30 | A (+30) | -34 | 0 | 26 |
| 4 | getCpuCount and sleep | 5 | 30 | A (+30) | -34 | 0 | 26 |
| 5 | Mutex — lock/unlock with defer | 5 | 30 | A (+30) | -34 | 0 | 26 |
| 6 | Condition variable — signal and wait | 5 | 30 | A (+30) | -34 | 0 | 26 |
| 7 | Atomic.Value — init, load, store | 5 | 30 | A (+30) | -34 | 0 | 26 |
| 8 | Atomic fetchAdd/fetchSub | 5 | 30 | A (+30) | -34 | 0 | 26 |
| 9 | Atomic bitwise ops | 5 | 30 | A (+30) | -34 | 0 | 26 |
| 10 | Atomic swap | 5 | 30 | A (+30) | -34 | 0 | 26 |
| 11 | WaitGroup lifecycle | 5 | 30 | A (+30) | -34 | 0 | 26 |
| 12 | ResetEvent signaling | 5 | 30 | A (+30) | -34 | 0 | 26 |
| 13 | Semaphore permits | 5 | 30 | A (+30) | -34 | 0 | 26 |
| 14 | spinLoopHint and cache_line | 5 | 30 | A (+30) | -34 | 0 | 26 |
| 15 | Mutex shared state across threads | 10 | 30 | A (+30) | -34 | 0 | 26 |
| 16 | Producer-consumer bounded queue | 10 | 30 | A (+30) | -34 | 0 | 26 |
| 17 | cmpxchgStrong semantics | 10 | 30 | A (+30) | -34 | 0 | 26 |
| 18 | Atomic counter across threads | 10 | 30 | A (+30) | -34 | 0 | 26 |
| 19 | Acquire/release publish pattern | 10 | 30 | A (+30) | -34 | 0 | 26 |
| 20 | Thread.Pool with WaitGroup | 10 | 30 | A (+30) | -34 | 0 | 26 |
| 21 | RwLock concurrent readers/writer | 10 | 30 | A (+30) | -34 | 0 | 26 |
| 22 | cmpxchgWeak retry loop | 10 | 30 | A (+30) | -34 | 0 | 26 |
| 23 | Multi-phase coordination | 10 | 30 | A (+30) | -34 | 0 | 26 |
| 24 | Lock-free stack (CAS) | 20 | 30 | A (+30) | -34 | 0 | 26 |
| 25 | Barrier + pipeline | 20 | 30 | A (+30) | -34 | 0 | 26 |

**Average exercise score:** 26 x 25 / 25 = 26.00 / 100

**Lesson score:** (26.00 / 100) x 5 = **1.30 / 5 pts**

**Compile failures:** 0 across all 25 exercises
**Test failures:** 0 across all 25 exercises

### Compile Failure Log

No compile failures.

### Reflection

**Zero compile failures** — Perfect correctness and quality across all 25 exercises. The agent demonstrated strong command of Zig's concurrency primitives: Thread.spawn, Mutex, Condition, atomics (Value, cmpxchgStrong/Weak, fetch operations), WaitGroup, ResetEvent, Semaphore, RwLock, Thread.Pool, and custom synchronization patterns (barrier, lock-free stack).

**Cost overrun analysis** — 39 turns vs 14-turn baseline (2.8x). $2.55 vs $1.77 baseline (-44% cost reduction, i.e., 44% OVER baseline). This is the worst efficiency score of any lesson so far (-34). Despite zero failures, the agent used nearly 3x the turns. Possible causes:
1. **Granular testing** — Each exercise may have been compiled and tested individually rather than batched (the foundation lesson protocol calls for writing multiple solutions per turn and testing in batches).
2. **Excessive RAG lookups** — Concurrency APIs may have triggered many pre-flight searches that could have been batched into fewer turns.
3. **Verbose output** — Concurrency test output (thread interleaving) may have bloated context without being piped through head/grep.

**Key lesson:** For foundation-level exercises with well-understood APIs, the agent should batch more aggressively — writing 5-8 solutions per turn and testing them together. The zero-failure result proves the knowledge was already sufficient; the turn count reflects process inefficiency, not knowledge gaps.

### Token Usage

| Metric | Value |
|--------|-------|
| Turns | 39 |
| Total cost | $2.55 |
| Baseline (Run 2) | $1.77 (14 turns) |
| Cost reduction | -44% (over baseline) |
| Efficiency score | -34 |
| System replay | $0.23 |
| Context replay | $1.22 |
| Cache write | $0.80 |
| Output | $0.31 |
