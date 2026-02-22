# 00-bootstrap: Run 2 — Efficiency Run

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

**Run 1 baselines:** See `baselines.json` for per-lesson cost targets.

**Run 1 grades:** See `GRADES-run1.md` for full Run 1 record.

---

<!-- Lesson sections appended below as Run 2 progresses -->

## Lesson 01: Core Language Fundamentals

### Summary

| Metric | Value |
|--------|-------|
| Exercises | 25 |
| Max points | 200 |
| Compile failures | 2 (Ex 23) |
| Test failures | 0 |

### Grade Table

| # | Topic | Diff | Pts | Correctness (30) | Quality | Efficiency | Score |
|---|-------|------|-----|-------------------|---------|------------|-------|
| 1 | Primitive types — integer sizes | 1 | 5 | 30 | A (+30) | — | 60 |
| 2 | Primitive types — floats, bool, void | 1 | 5 | 30 | A (+30) | — | 60 |
| 3 | Variables — const vs var | 1 | 5 | 30 | A (+30) | — | 60 |
| 4 | Variables — undefined init | 1 | 5 | 30 | A (+30) | — | 60 |
| 5 | Control flow — if/else expression | 1 | 5 | 30 | A (+30) | — | 60 |
| 6 | Control flow — switch ranges | 1 | 5 | 30 | A (+30) | — | 60 |
| 7 | Control flow — for loops | 1 | 5 | 30 | A (+30) | — | 60 |
| 8 | Control flow — while continue | 1 | 5 | 30 | A (+30) | — | 60 |
| 9 | Functions — basics | 1 | 5 | 30 | A (+30) | — | 60 |
| 10 | Errors — error sets, try/catch | 1 | 5 | 30 | A (+30) | — | 60 |
| 11 | Optionals — ?T, orelse, if-unwrap | 1 | 5 | 30 | A (+30) | — | 60 |
| 12 | Tagged unions — switch dispatch | 1 | 5 | 30 | A (+30) | — | 60 |
| 13 | Slices and arrays — basics | 1 | 5 | 30 | A (+30) | — | 60 |
| 14 | Defer — LIFO ordering | 1 | 5 | 30 | A (+30) | — | 60 |
| 15 | Comptime — blocks and params | 2 | 10 | 30 | A (+30) | — | 60 |
| 16 | Comptime — @typeInfo/@typeName | 2 | 10 | 30 | A (+30) | — | 60 |
| 17 | Labeled blocks and breaks | 2 | 10 | 30 | A (+30) | — | 60 |
| 18 | Functions — error unions, fn ptrs | 2 | 10 | 30 | A (+30) | — | 60 |
| 19 | Errors — errdefer only on error | 2 | 10 | 30 | A (+30) | — | 60 |
| 20 | Tagged unions — methods, void | 2 | 10 | 30 | A (+30) | — | 60 |
| 21 | Slices — sentinel, multi-dim | 2 | 10 | 30 | A (+30) | — | 60 |
| 22 | Packed structs — bitSizeOf/sizeOf | 2 | 10 | 30 | A (+30) | — | 60 |
| 23 | Peer type resolution | 3 | 20 | 20 (-5 -5) | A (+30) | — | 50 |
| 24 | Casting and coercion | 3 | 20 | 30 | A (+30) | — | 60 |
| 25 | Defer + errdefer in loops | 2 | 10 | 30 | A (+30) | — | 60 |

### Per-Exercise Scoring Detail

**Exercises 1-22, 24-25: Perfect (60/60 each)**
- All compiled and passed tests on first attempt
- Code quality: clean, well-commented, demonstrates all required concepts

**Exercise 23: 50/60 (-10 from correctness)**
- **Compile failure 1 (-5, new mistake):** Used `const cond = true` which made the if/else evaluate at comptime, so `result` was `u32` not `?u32`. Fixed by using `var cond = true; _ = &cond;` to force runtime evaluation.
- **Compile failure 2 (-5, new mistake):** Used `anyerror!u32` as the expected type for peer resolution of `u32` and `error.Fail`. The actual peer type is `error{Fail}!u32` (specific error set, not anyerror). Fixed the type check.
- Lesson: When testing peer type resolution, conditions must be runtime-evaluated to trigger actual peer resolution. Comptime-known conditions cause the compiler to eliminate the dead branch. Also, peer resolution between a value and a specific error produces a specific error set, not anyerror.

### Compile Failure Summary

| Exercise | Failures | Points Lost | Type | Description |
|----------|----------|-------------|------|-------------|
| 23 | 2 | -10 | New | comptime condition eliminated dead branch; anyerror vs specific error set |

**Total correctness deductions:** -10 (on exercise 23)

## Token Usage

| Metric | Value |
|--------|-------|
| Run 2 cost | $1.04 (16 turns) |
| Run 1 baseline | $2.91 (60 turns) |
| Cost reduction | 64.3% |
| Efficiency score | 105 (capped from +74.3 raw) |
| **Lesson score** | **5.25/5 pts** (Level 0, 5 pt pool) |

## Lesson 02: Standard Library Essentials

### Summary

| Metric | Value |
|--------|-------|
| Exercises | 25 |
| Max points | 200 |
| Compile failures | 0 |
| Test failures | 0 |

### Grade Table

| # | Topic | Diff | Pts | Correctness (30) | Quality | Efficiency | Score |
|---|-------|------|-----|-------------------|---------|------------|-------|
| 1 | ArrayList — .empty init, append, items slice | 1 | 5 | 30 | A (+30) | — | 60 |
| 2 | ArrayList — appendSlice and length verification | 1 | 5 | 30 | A (+30) | — | 60 |
| 3 | ArrayList — insert and orderedRemove | 1 | 5 | 30 | A (+30) | — | 60 |
| 4 | ArrayList — swapRemove and pop | 1 | 5 | 30 | A (+30) | — | 60 |
| 5 | ArrayList — clearRetainingCapacity preserves memory | 1 | 5 | 30 | A (+30) | — | 60 |
| 6 | ArrayList — ensureTotalCapacity pre-allocation | 2 | 10 | 30 | A (+30) | — | 60 |
| 7 | AutoHashMap — init, put, get, contains, count | 1 | 5 | 30 | A (+30) | — | 60 |
| 8 | AutoHashMap — getOrPut upsert pattern | 2 | 10 | 30 | A (+30) | — | 60 |
| 9 | AutoHashMap — remove, fetchRemove, iterator | 2 | 10 | 30 | A (+30) | — | 60 |
| 10 | StringHashMap — string keys | 1 | 5 | 30 | A (+30) | — | 60 |
| 11 | std.mem — eql, startsWith, endsWith | 1 | 5 | 30 | A (+30) | — | 60 |
| 12 | std.mem — indexOf and lastIndexOf | 1 | 5 | 30 | A (+30) | — | 60 |
| 13 | std.mem — trim, trimLeft, trimRight | 1 | 5 | 30 | A (+30) | — | 60 |
| 14 | std.mem — splitScalar and splitSequence | 2 | 10 | 30 | A (+30) | — | 60 |
| 15 | std.mem — tokenizeScalar vs splitScalar | 2 | 10 | 30 | A (+30) | — | 60 |
| 16 | std.mem — zeroes, asBytes, concat | 2 | 10 | 30 | A (+30) | — | 60 |
| 17 | std.fmt — bufPrint with {d} and {s} specifiers | 1 | 5 | 30 | A (+30) | — | 60 |
| 18 | std.fmt — allocPrint and comptimePrint | 2 | 10 | 30 | A (+30) | — | 60 |
| 19 | std.fmt — padding, hex, binary, float precision | 2 | 10 | 30 | A (+30) | — | 60 |
| 20 | std.sort — pdq ascending and descending | 1 | 5 | 30 | A (+30) | — | 60 |
| 21 | std.sort — custom comparator and isSorted | 2 | 10 | 30 | A (+30) | — | 60 |
| 22 | std.math — @min/@max builtins, clamp | 1 | 5 | 30 | A (+30) | — | 60 |
| 23 | std.math — isPowerOfTwo, log2_int, divCeil, maxInt | 1 | 5 | 30 | A (+30) | — | 60 |
| 24 | JSON — parseFromSlice into struct and dynamic Value | 3 | 20 | 30 | A (+30) | — | 60 |
| 25 | JSON — serialize with json.fmt, round-trip, parse options | 3 | 20 | 30 | A (+30) | — | 60 |

### Per-Exercise Scoring Detail

**Exercises 1-25: Perfect (60/60 each)**
- All 25 exercises compiled and passed tests on first attempt
- Zero compile failures, zero test failures
- Code quality: clean, well-structured, uses proper 0.15.2 APIs throughout
- Key patterns demonstrated correctly:
  - ArrayList `.empty` init with per-method allocator passing
  - AutoHashMap/StringHashMap `.init(gpa)` with stored allocator
  - `getOrPut` upsert pattern with `found_existing` / `value_ptr.*`
  - Iterator pattern: `while (it.next()) |entry|` with `key_ptr.*` / `value_ptr.*`
  - `mem.splitScalar` / `mem.splitSequence` / `mem.tokenizeScalar` / `mem.tokenizeAny`
  - `fmt.bufPrint` / `fmt.allocPrint` / `fmt.comptimePrint`
  - `sort.pdq` with `sort.asc(T)` / `sort.desc(T)` and custom comparators
  - JSON `parseFromSlice` into structs and dynamic `Value`
  - JSON serialization via `json.fmt` + `{f}` specifier with `allocPrint`/`bufPrint`

### Compile Failure Summary

| Exercise | Failures | Points Lost | Type | Description |
|----------|----------|-------------|------|-------------|
| (none) | 0 | 0 | — | — |

**Total correctness deductions:** 0

## Token Usage

| Metric | Value |
|--------|-------|
| Run 2 cost | $1.70 (11 turns) |
| Run 1 baseline | $3.06 (34 turns) |
| Cost reduction | 44.4% |
| Efficiency score | 105 (capped from +54.4 raw) |
| **Lesson score** | **5.25/5 pts** (Level 0, 5 pt pool) |
