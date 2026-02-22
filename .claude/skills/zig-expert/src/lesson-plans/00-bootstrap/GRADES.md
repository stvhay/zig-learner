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
