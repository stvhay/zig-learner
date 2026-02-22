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
