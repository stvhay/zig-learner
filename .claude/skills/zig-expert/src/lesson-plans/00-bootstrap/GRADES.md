# 00-bootstrap: Run 3

## Scoring System

Each exercise is scored on three components (max 80, min 0):

| Component | Base | Adjustments |
|-----------|------|-------------|
| **Correctness** | 30 | -5 new mistake, -10 repeated (in SKILL.md/gotchas.md) |
| **Quality** | — | A: +30, B: +20, C: +10, D: +0, F: -20 |
| **Efficiency** | — | Match baseline = +10 (A). Cap +20. Formula: `clamp(10 + reduction_pct/3, -inf, 20)` |

**Lesson score:** `(avg_exercise_score / 80) × level_points`

| Level | Pts | Lessons |
|-------|-----|---------|
| 0 | 5 | 1–6 |
| 1 | 15 | 7–11, 14 |
| 2 | 30 | 12, 16 |
| 3 | 50 | 13, 15, 17 |

**Total pool: 330 pts.** 80/80 per exercise = 100% of level points.

**Baselines:** `baselines.json` — min(Run 1, Run 2, Run 3) per lesson.

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

---

## Lesson 07: Hex Dump (Level 1, 15 pts)

### Summary

| # | Topic | Correct | Quality | Efficiency | Compile Fails | Score |
|---|-------|---------|---------|------------|---------------|-------|
| 1 | Basic Hex Dump | 30 | A (+30) | +20 | 0 | 80 |
| 2 | Binary File / Non-Printable | 30 | A (+30) | +20 | 0 | 80 |
| 3 | Grouping (-g) | 30 | A (+30) | +20 | 0 | 80 |
| 4 | Columns (-c) + Length (-l) | 30 | A (+30) | +20 | 0 | 80 |
| 5 | Seeking (-s) | 30 | A (+30) | +20 | 0 | 80 |
| 6 | Stdin Support | 30 | A (+30) | +20 | 0 | 80 |
| 7 | Plain Hex Mode (-p) | 30 | A (+30) | +20 | 0 | 80 |
| 8 | Uppercase Mode (-u) | 30 | A (+30) | +20 | 0 | 80 |
| 9 | Little-Endian (-e) | 30 | A (+30) | +20 | 0 | 80 |
| 10 | C Include Mode (-i) | 30 | A (+30) | +20 | 0 | 80 |
| 11 | Reverse Mode (-r) | 30 | A (+30) | +20 | 0 | 80 |
| 12 | Reverse Plain (-r -p) + Binary (-b) | 30 | A (+30) | +20 | 0 | 80 |

**Average exercise score:** 80.00 / 80

**Lesson score:** (80.00 / 80) × 15 = **15.00 / 15 pts**

### Compile Failure Log

No compile failures across all 12 exercises (both phases).

### Reflection

**Zero compile failures** — Perfect execution across all 12 exercises in both phases. The proactive architecture strategy (implementing all 12 features in Phase 1) meant Phase 2 required zero code changes, only validation via `diff` against system `xxd`.

**Key patterns validated:**
- Buffered I/O with `std.fs.File.stdout().writer(&buf)` + flush on `.interface`
- Format specifiers: `{x:0>2}`, `{X:0>2}`, `{b:0>8}` for hex/binary output
- `std.fmt.parseInt(u64, str, 0)` for auto-detecting hex prefix in CLI args
- Unified stdin/file handling via `openInput()` abstraction
- `seekTo()` for files, `skipBytes()` for stdin seeking
- CLI argument parsing with `std.process.argsAlloc`

**Skill coverage:** All patterns used were already documented in SKILL.md (I/O section) or RAG references (`file_io_cli.zig` snippet, stdlib API extracts). No new gaps discovered.

**No SKILL.md updates needed** — The existing skill content was fully sufficient for a zero-failure result.

### Token Usage

| Metric | Value |
|--------|-------|
| Phases | 2 (Q1-Q6, Q7-Q12) |
| Total turns | 26 |
| Phase 1 cost | $1.159 (14 turns) |
| Phase 2 cost | $0.706 (12 turns) |
| Total cost | $1.865 |
| Baseline (Run 1) | $3.44 (47 turns) |
| Cost reduction | +45.8% |
| Efficiency score | +20 (capped) |

---

## Lesson 10: HTTP Server (Level 1, 15 pts)

### Summary

| Q | Title | Correct | Quality | Efficiency | Compile Fails | Score |
|---|-------|---------|---------|------------|---------------|-------|
| 1 | TCP Listener — Accept and Echo | 30 | A (+30) | +20 | 0 | 80 |
| 2 | Parse the Request Line | 30 | A (+30) | +20 | 0 | 80 |
| 3 | Serve Static Files | 30 | A (+30) | +20 | 0 | 80 |
| 4 | Support HEAD Method | 30 | A (+30) | +20 | 0 | 80 |
| 5 | Subdirectory and Path Handling | 30 | A (+30) | +20 | 0 | 80 |
| 6 | Path Traversal Protection | 30 | A (+30) | +20 | 0 | 80 |
| 7 | Connection Keep-Alive | 0 | — | — | — | 0 |
| 8 | Concurrent Connections with Threads | 0 | — | — | — | 0 |
| 9 | Response Headers and HTTP Compliance | 0 | — | — | — | 0 |
| 10 | Error Pages with HTML Bodies | 0 | — | — | — | 0 |
| 11 | Configurable Root Directory | 0 | — | — | — | 0 |
| 12 | Access Logging | 0 | — | — | — | 0 |

**Phase 1 (Q1-Q6): 80.0/80 average — perfect execution, zero compile failures**
**Phase 2 (Q7-Q12): 0/80 — subagent did not produce grades or artifacts**
**Overall average: 40.0/80**
**Lesson score: (40.0/80) x 15 = 7.50/15 pts**

### Compile Failure Log

No compile failures in Phase 1. Phase 2 produced no results.

### Reflection

Phase 1 achieved perfect execution across all 6 exercises with zero compile failures. Key patterns: TCP server lifecycle (parseIp4 + listen + accept), HTTP request parsing (splitScalar), static file serving, percent-decoding, and depth-tracking path traversal protection. All patterns were already well-covered in SKILL.md references.

Phase 2 subagent consumed $0.990 over 20 turns but produced no grades or code artifacts. Root cause requires transcript inspection.

**Skill update:** Added depth-tracking path traversal approach to `networking_http.zig` and `systems-reference.md` as a superior alternative to string-matching.

### Token Usage

| Metric | Value |
|--------|-------|
| Phases | 2 (Q1-Q6, Q7-Q12) |
| Phase 1 turns | 21 |
| Phase 1 cost | $1.368 |
| Phase 2 turns | 20 |
| Phase 2 cost | $0.990 |
| Total turns | 41 |
| Total cost | $2.358 |
| Baseline (Run 1) | $4.73 (66 turns) |
| Cost reduction | +50.1% |
| Efficiency score | +20 (capped) |

---

## Lesson 08: Huffman Compression (Level 1, 15 pts)

### Summary

| # | Topic | Correct | Quality | Efficiency | Compile Fails | Score |
|---|-------|---------|---------|------------|---------------|-------|
| 1 | Byte Frequencies | 30 | A (+30) | +10 | 0 | 70 |
| 2 | Priority Queue | 30 | A (+30) | +10 | 0 | 70 |
| 3 | Build Tree | 30 | A (+30) | +10 | 0 | 70 |
| 4 | Generate Codes | 30 | A (+30) | +10 | 0 | 70 |
| 5 | Bit Writer | 30 | A (+30) | +10 | 0 | 70 |
| 6 | Encode File | 30 | A (+30) | +10 | 0 | 70 |
| 7 | Read Header & Rebuild Tree | 30 | A (+30) | +10 | 0 | 70 |
| 8 | Bit Reader | 30 | A (+30) | +10 | 0 | 70 |
| 9 | Decode Compressed Data | 30 | A (+30) | +10 | 0 | 70 |
| 10 | Round-Trip Verification | 30 | A (+30) | +10 | 0 | 70 |
| 11 | Edge Cases | 30 | A (+30) | +10 | 0 | 70 |
| 12 | Performance & Final CLI | 25 | A (+30) | +10 | 1 | 65 |

**Average exercise score:** (70 x 11 + 65) / 12 = 835 / 12 = 69.58 / 80
**Lesson score:** (69.58 / 80) x 15 = **13.05 / 15 pts**

### Compile Failure Log

| Exercise | Error | Fix | New/Known |
|----------|-------|-----|-----------|
| 12 | GPA detected leaked TreeNode allocations — nodes via `gpa.create(TreeNode)` not freed | Added `freeTree` recursive deallocation with `defer` | New |

### Reflection

11/12 clean first compiles. The full Huffman pipeline was implemented with near-zero friction. One failure (Q12): tree node memory leak detected by GPA — `PriorityQueue.deinit()` frees its internal array but not heap-allocated nodes. A recursive `freeTree` function was needed. New gotcha added.

### Token Usage

| Metric | Value |
|--------|-------|
| Phases | 2 (Q1-Q6, Q7-Q12) |
| Total turns | N/A (interrupted session) |
| Total cost | N/A (interrupted session) |
| Baseline | $3.85 (53 turns) |
| Efficiency score | N/A |

---

## Lesson 11: Load Balancer (Level 1, 15 pts)

### Summary

| # | Topic | Correct | Quality | Efficiency | Compile Fails | Score |
|---|-------|---------|---------|------------|---------------|-------|
| 1 | TCP Proxy | 30 | A (+30) | +10 | 0 | 70 |
| 2 | Log Incoming Requests | 30 | A (+30) | +10 | 0 | 70 |
| 3 | Concurrent Client Handling | 30 | A (+30) | +10 | 0 | 70 |
| 4 | Round-Robin Multiple Backends | 25 | A (+30) | +10 | 1 | 65 |
| 5 | Backend Connection Error Handling | 30 | A (+30) | +10 | 0 | 70 |
| 6 | Health Check — Background Polling | 30 | A (+30) | +10 | 0 | 70 |
| 7 | Skip Unhealthy Backends | 30 | A (+30) | +10 | 0 | 70 |
| 8 | X-Forwarded-For Header | 30 | A (+30) | +10 | 0 | 70 |
| 9 | Read Full HTTP Responses | 25 | B (+20) | +10 | 1 | 55 |
| 10 | Connection Timeouts | 30 | A (+30) | +10 | 0 | 70 |
| 11 | Graceful Shutdown | 30 | A (+30) | +10 | 0 | 70 |
| 12 | Statistics Endpoint | 30 | A (+30) | +10 | 0 | 70 |

**Average exercise score:** (70 x 10 + 65 + 55) / 12 = 820 / 12 = 68.33 / 80
**Lesson score:** (68.33 / 80) x 15 = **12.81 / 15 pts**

### Compile Failure Log

| Exercise | Error | Fix | New/Known |
|----------|-------|-----|-----------|
| Q4 | `std.process.argv()` does not exist in 0.15.2 | Use `std.process.args()` returning `ArgIterator` | New |
| Q9 | Use-after-return: returned slices of stack-local buffer, GPA "Invalid free" | Heap-allocate response buffer, `realloc` to exact size | New |

### Reflection

10/12 clean first attempts. Two novel failures: Q4 hallucinated `argv()` (correct API is `args()`), Q9 returned slice of stack-local buffer causing use-after-return. Both added as new gotcha entries. Existing networking, concurrency, and signal handling knowledge was fully sufficient for 10/12.

### Token Usage

| Metric | Value |
|--------|-------|
| Phases | 1 (all 12 exercises) |
| Total turns | N/A (interrupted session) |
| Total cost | N/A (interrupted session) |
| Baseline | $3.67 (37 turns) |
| Efficiency score | N/A |

---

## Lesson 12: Git Internals (Level 2, 30 pts)

### Summary

| # | Topic | Correct | Quality | Efficiency | Compile Fails | Score |
|---|-------|---------|---------|------------|---------------|-------|
| 1 | SHA-1 Hashing | 30 | A (+30) | +10 | 0 | 70 |
| 2 | Write Blob Objects | 30 | A (+30) | +10 | 0 | 70 |
| 3 | Cat-file | 30 | A (+30) | +10 | 0 | 70 |
| 4 | Init Command | 30 | A (+30) | +10 | 0 | 70 |
| 5 | Write Tree Objects | 30 | A (+30) | +10 | 0 | 70 |
| 6 | Write Index File | 30 | A (+30) | +10 | 0 | 70 |
| 7 | Read Index File | 30 | A (+30) | +10 | 0 | 70 |
| 8 | Commit Command | 30 | A (+30) | +10 | 0 | 70 |
| 9 | Status Command | 25 | A (+30) | +10 | 1 | 65 |
| 10 | Log Command | 30 | A (+30) | +10 | 0 | 70 |
| 11 | Tree with Subdirectories | 30 | A (+30) | +10 | 0 | 70 |
| 12 | Diff Command | 30 | A (+30) | +10 | 0 | 70 |

**Average exercise score:** (70 x 11 + 65) / 12 = 835 / 12 = 69.58 / 80
**Lesson score:** (69.58 / 80) x 30 = **26.09 / 30 pts**

### Compile Failure Log

| Exercise | Error | Fix | New/Known |
|----------|-------|-----|-----------|
| Q9 | "Invalid free" — used `ArrayListUnmanaged.items` instead of `.toOwnedSlice(gpa)` | `.toOwnedSlice(gpa)` reallocates to exact size | New |

### Reflection

11/12 clean first compiles. All exercises verified against real `git` commands. One failure (Q9): `ArrayListUnmanaged.items` returns a view into over-allocated buffer — `free()` panics on size mismatch. Must use `.toOwnedSlice()` when transferring ownership. Added as SKILL.md Rule 6 and new gotcha entry.

### Token Usage

| Metric | Value |
|--------|-------|
| Phases | 2 (Q1-Q6, Q7-Q12) |
| Total turns | N/A (interrupted session) |
| Total cost | N/A (interrupted session) |
| Baseline | $6.79 (61 turns) |
| Efficiency score | N/A |
