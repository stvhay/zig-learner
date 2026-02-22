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

## Lesson 03: Error Handling & Allocator Patterns

### Summary

| Metric | Value |
|--------|-------|
| Exercises | 25 |
| Max points | 200 |
| Compile failures | 1 (Ex 9: runtime integer overflow) |
| Test failures | 0 |

### Grade Table

| # | Topic | Diff | Pts | Correctness (30) | Quality | Efficiency | Score |
|---|-------|------|-----|-------------------|---------|------------|-------|
| 1 | Error sets — declaration and named error sets | 1 | 5 | 30 | A (+30) | — | 60 |
| 2 | Error sets — anonymous (inferred) error sets | 1 | 5 | 30 | A (+30) | — | 60 |
| 3 | Error sets — merging with `\|\|` | 1 | 5 | 30 | A (+30) | — | 60 |
| 4 | Error sets — `@errorName` runtime introspection | 1 | 5 | 30 | A (+30) | — | 60 |
| 5 | Error sets — `@intFromError` and numeric identity | 1 | 5 | 30 | A (+30) | — | 60 |
| 6 | Error unions — basic `ErrorSet!T` and `try` | 1 | 5 | 30 | A (+30) | — | 60 |
| 7 | Error unions — `catch` with fallback value | 1 | 5 | 30 | A (+30) | — | 60 |
| 8 | Error unions — `catch` with error payload | 1 | 5 | 30 | A (+30) | — | 60 |
| 9 | Error unions — if-else error unwrap | 1 | 5 | 25 (-5) | A (+30) | — | 55 |
| 10 | errdefer — basic cleanup on error path | 1 | 5 | 30 | A (+30) | — | 60 |
| 11 | errdefer — ordering (LIFO relative to defer) | 1 | 5 | 30 | A (+30) | — | 60 |
| 12 | errdefer — `\|err\|` capture in function scope | 1 | 5 | 30 | A (+30) | — | 60 |
| 13 | Error handling in loops — break on error with cleanup | 1 | 5 | 30 | A (+30) | — | 60 |
| 14 | Error handling in loops — partial initialization cleanup | 1 | 5 | 30 | A (+30) | — | 60 |
| 15 | FixedBufferAllocator — stack-based allocation | 2 | 10 | 30 | A (+30) | — | 60 |
| 16 | FixedBufferAllocator — reset for reuse | 2 | 10 | 30 | A (+30) | — | 60 |
| 17 | ArenaAllocator — init, alloc, deinit, no frees needed | 2 | 10 | 30 | A (+30) | — | 60 |
| 18 | ArenaAllocator — reset modes (retain/free_all) | 2 | 10 | 30 | A (+30) | — | 60 |
| 19 | FailingAllocator — fail at specific index | 2 | 10 | 30 | A (+30) | — | 60 |
| 20 | FailingAllocator — allocation stats tracking | 2 | 10 | 30 | A (+30) | — | 60 |
| 21 | checkAllAllocationFailures — exhaustive OOM testing | 2 | 10 | 30 | A (+30) | — | 60 |
| 22 | Error set merging in multi-layer functions | 2 | 10 | 30 | A (+30) | — | 60 |
| 23 | StackFallbackAllocator — stack-first with heap fallback | 2 | 10 | 30 | A (+30) | — | 60 |
| 24 | Custom allocator — VTable implementation | 3 | 20 | 30 | A (+30) | — | 60 |
| 25 | Allocator composition — arena over fixed buffer + OOM | 3 | 20 | 30 | A (+30) | — | 60 |

### Per-Exercise Scoring Detail

**Exercises 1-8, 10-25: Perfect (60/60 each)**
- All compiled and passed tests on first attempt
- Code quality: clean, well-commented, demonstrates all required concepts
- Key patterns demonstrated correctly:
  - Named error sets with `@typeInfo`, `@errorName`, `@intFromError`
  - Error unions with `try`, bare `catch`, `catch |err|`, if-else unwrap
  - `errdefer` basic, LIFO ordering with `defer`, `|err|` capture in function scope
  - Partial initialization cleanup with tracked count
  - All allocator types: FixedBufferAllocator, ArenaAllocator, FailingAllocator, StackFallbackAllocator
  - Custom VTable allocator with 4 function pointers
  - `checkAllAllocationFailures` with extra args tuple

**Exercise 9: 55/60 (-5 from correctness)**
- **Compile failure 1 (-5, new mistake):** Runtime integer overflow in `findValue` — `key * 100` with `key: u8` overflowed when key=5 (500 > 255). Fixed by widening to `@as(u32, key) * 100`.
- Lesson: Always widen narrow integer types before arithmetic that may exceed their range. `u8 * u8` stays `u8` and panics on overflow.

### Compile Failure Summary

| Exercise | Failures | Points Lost | Type | Description |
|----------|----------|-------------|------|-------------|
| 9 | 1 | -5 | New | u8 integer overflow in multiplication (5*100 > 255) |

**Total correctness deductions:** -5 (on exercise 9)

## Token Usage

| Metric | Value |
|--------|-------|
| Run 2 cost | $3.24 (23 turns) |
| Run 1 baseline | $4.57 (49 turns) |
| Cost reduction | 29.1% |
| Efficiency score | +39.1 |
| **Lesson score** | **4.95/5 pts** (Level 0, 5 pt pool) |

## Lesson 04: Comptime & Metaprogramming

### Summary

| Metric | Value |
|--------|-------|
| Exercises | 25 |
| Max points | 200 |
| Compile failures | 6 (Ex 15: 2, Ex 16: 1, Ex 17: 1, Ex 21: 1, Ex 25: 1) |
| Test failures | 0 |

### Grade Table

| # | Topic | Diff | Pts | Correctness (30) | Quality | Efficiency (56.6) | Score |
|---|-------|------|-----|-------------------|---------|-------------------|-------|
| 1 | comptime var in blocks -- loop accumulator | 1 | 5 | 30 | A (+30) | +56.6 | 105 |
| 2 | comptime function parameters -- type as first-class value | 1 | 5 | 30 | A (+30) | +56.6 | 105 |
| 3 | comptime function evaluation -- recursive factorial | 1 | 5 | 30 | A (+30) | +56.6 | 105 |
| 4 | @typeInfo on integers and floats -- bits, signedness | 1 | 5 | 30 | A (+30) | +56.6 | 105 |
| 5 | @typeInfo on structs -- field details, defaults, quoted identifiers | 2 | 10 | 30 | A (+30) | +56.6 | 105 |
| 6 | @typeInfo on enums, unions, optionals, pointers, arrays, error sets | 2 | 10 | 30 | A (+30) | +56.6 | 105 |
| 7 | @Type to generate struct types at comptime | 2 | 10 | 30 | A (+30) | +56.6 | 105 |
| 8 | @Type to generate enum types at comptime | 2 | 10 | 30 | A (+30) | +56.6 | 105 |
| 9 | @typeName for type identity strings | 1 | 5 | 30 | A (+30) | +56.6 | 105 |
| 10 | std.meta -- fields, fieldNames, FieldEnum | 1 | 5 | 30 | A (+30) | +56.6 | 105 |
| 11 | std.meta -- stringToEnum, activeTag | 1 | 5 | 30 | A (+30) | +56.6 | 105 |
| 12 | std.meta -- hasFn, eql, Tag | 1 | 5 | 30 | A (+30) | +56.6 | 105 |
| 13 | comptime string concatenation with ++ and ** | 1 | 5 | 30 | A (+30) | +56.6 | 105 |
| 14 | std.fmt.comptimePrint for compile-time formatting | 1 | 5 | 30 | A (+30) | +56.6 | 105 |
| 15 | comptime string building -- join and reverse | 2 | 10 | 15 (-10 -5) | A (+30) | +56.6 | 101.6 |
| 16 | comptime lookup tables -- base64 encode/decode pair | 2 | 10 | 20 (-10) | A (+30) | +56.6 | 105 |
| 17 | comptime lookup tables -- precomputed squares | 1 | 5 | 20 (-10) | A (+30) | +56.6 | 105 |
| 18 | inline for over types -- multi-type testing | 1 | 5 | 30 | A (+30) | +56.6 | 105 |
| 19 | inline for over struct fields -- generic field iteration | 2 | 10 | 30 | A (+30) | +56.6 | 105 |
| 20 | @compileError for static assertions and validation | 1 | 5 | 30 | A (+30) | +56.6 | 105 |
| 21 | @hasDecl and @hasField for feature detection | 1 | 5 | 20 (-10) | A (+30) | +56.6 | 105 |
| 22 | builder pattern -- chaining field assignments at comptime | 2 | 10 | 30 | A (+30) | +56.6 | 105 |
| 23 | custom format function -- {f} specifier (2-param) | 2 | 10 | 30 | A (+30) | +56.6 | 105 |
| 24 | full type transformation -- Nullable<T> via @Type | 3 | 20 | 30 | A (+30) | +56.6 | 105 |
| 25 | comptime state machine with generated enum and dispatch | 3 | 20 | 20 (-10) | A (+30) | +56.6 | 105 |

### Per-Exercise Scoring Detail

**Exercises 1-14, 18-20, 22-24: Perfect (60/60 each)**
- All compiled and passed tests on first attempt
- Code quality: clean, well-commented, demonstrates all required concepts
- Key patterns demonstrated correctly:
  - Comptime blocks with `var` and labeled `break`
  - Type-as-first-class-value with `comptime T: type`
  - Recursive comptime function evaluation
  - `@typeInfo` with quoted identifiers (.@"struct", .@"enum")
  - `@Type` for struct and enum generation with proper StructField/EnumField
  - `@typeName` for type identity
  - `std.meta` utilities: fields, fieldNames, FieldEnum, stringToEnum, activeTag, hasFn, eql, Tag
  - String concatenation `++` and repetition `**`
  - `std.fmt.comptimePrint` with format specifiers
  - `inline for` over types and struct fields
  - `@compileError` for static assertions
  - `@hasDecl` and `@hasField` for feature detection
  - Builder pattern with `@field` and `@FieldType`
  - Custom format with 2-param signature and `{f}` specifier
  - Full type transformation with NullableFields

**Exercise 15: 45/60 (-15 from correctness)**
- **Compile failure 1 (-10, repeated mistake):** Used `return &final` from within a `comptime {}` block inside a function with comptime params. SKILL.md documents: "Returning `[]const u8` from a comptime block inside such a function fails with 'function called at runtime cannot return value at comptime'." Fixed by using `const result = comptime blk: { ... break :blk &final; }; return result;` pattern.
- **Compile failure 2 (-5, new mistake):** Used a local `const total_len = ...` as array size inside `comptime blk:` — the variable was not recognized as comptime-known within the block scope. Fixed by calling the length function directly inside the comptime block.

**Exercise 16: 50/60 (-10 from correctness)**
- **Compile failure 1 (-10, repeated mistake):** Used `comptime blk:` for module-level `const` initialization. SKILL.md documents: "Module-level `const` is already comptime — don't add `comptime` keyword." Fixed by removing `comptime` and using plain `blk:`.

**Exercise 17: 50/60 (-10 from correctness)**
- **Compile failure 1 (-10, repeated mistake):** Same redundant `comptime` keyword on module-level `const` as ex16. Fixed by using plain `blk:`.

**Exercise 21: 50/60 (-10 from correctness)**
- **Compile failure 1 (-10, repeated mistake):** `describeType` function returned `[]const u8` from a function with comptime params — "function called at runtime cannot return value at comptime." SKILL.md documents this pattern. Fixed by returning `*const [N]u8` using a helper length function.

**Exercise 25: 50/60 (-10 from correctness)**
- **Compile failure 1 (-10, repeated mistake):** Used `comptime blk:` for a `const` inside a returned struct type. SKILL.md documents: "omit redundant `comptime` keyword since struct-level `const` is already comptime." Fixed by removing `comptime` keyword.

### Compile Failure Summary

| Exercise | Failures | Points Lost | Type | Description |
|----------|----------|-------------|------|-------------|
| 15 | 2 | -15 | 1 repeated, 1 new | comptime return pattern; variable not comptime-known in block |
| 16 | 1 | -10 | Repeated | redundant `comptime` on module-level const |
| 17 | 1 | -10 | Repeated | redundant `comptime` on module-level const |
| 21 | 1 | -10 | Repeated | comptime return from runtime-callable function |
| 25 | 1 | -10 | Repeated | redundant `comptime` inside struct-level const |

**Total correctness deductions:** -55 across 5 exercises (5 repeated mistakes, 1 new mistake)

## Token Usage

| Metric | Value |
|--------|-------|
| Run 2 cost | $2.11 (21 turns) |
| Run 1 baseline | $3.95 (56 turns) |
| Cost reduction | 46.6% |
| Efficiency score | 56.6 (raw: 40 + 16.6) |
| Avg exercise score | 100.66 |
| **Lesson score** | **5.03/5 pts** (Level 0, 5 pt pool) |

## Lesson 05: Idioms & Design Patterns

### Summary

| Metric | Value |
|--------|-------|
| Exercises | 25 |
| Max points | 200 |
| Compile failures | 1 (Ex 24: parameter shadows method) |
| Test failures | 0 |

### Grade Table

| # | Topic | Diff | Pts | Correctness (30) | Quality | Efficiency (67.6) | Score |
|---|-------|------|-----|-------------------|---------|-------------------|-------|
| 1 | Generic data structure — Stack(T) returning struct | 1 | 5 | 30 | A (+30) | +67.6 | 105 |
| 2 | Generic data structure — multi-type instantiation | 1 | 5 | 30 | A (+30) | +67.6 | 105 |
| 3 | Vtable interface — define and call through fat pointer | 1 | 5 | 30 | A (+30) | +67.6 | 105 |
| 4 | Vtable interface — multiple implementors, polymorphic array | 2 | 10 | 30 | A (+30) | +67.6 | 105 |
| 5 | Iterator pattern — next() returns ?T, while-optional loop | 1 | 5 | 30 | A (+30) | +67.6 | 105 |
| 6 | Iterator pattern — filter iterator adapter | 2 | 10 | 30 | A (+30) | +67.6 | 105 |
| 7 | Writer interface — GenericWriter with custom context | 1 | 5 | 30 | A (+30) | +67.6 | 105 |
| 8 | Writer interface — ArrayList writer and fixedBufferStream | 1 | 5 | 30 | A (+30) | +67.6 | 105 |
| 9 | Allocator interface — parameter convention, init/deinit | 1 | 5 | 30 | A (+30) | +67.6 | 105 |
| 10 | Allocator interface — arena allocator scoped lifetime | 2 | 10 | 30 | A (+30) | +67.6 | 105 |
| 11 | RAII / defer — init/deinit pair with defer | 1 | 5 | 30 | A (+30) | +67.6 | 105 |
| 12 | RAII / defer — errdefer for partial initialization cleanup | 2 | 10 | 30 | A (+30) | +67.6 | 105 |
| 13 | Sentinel-terminated slices — [:0]const u8 properties | 1 | 5 | 30 | A (+30) | +67.6 | 105 |
| 14 | Sentinel-terminated slices — mem.span, mem.sliceTo | 1 | 5 | 30 | A (+30) | +67.6 | 105 |
| 15 | @fieldParentPtr — recover parent from embedded field | 1 | 5 | 30 | A (+30) | +67.6 | 105 |
| 16 | @fieldParentPtr — intrusive linked list traversal | 2 | 10 | 30 | A (+30) | +67.6 | 105 |
| 17 | Comptime generics — BoundedBuffer(T, cap) with static array | 2 | 10 | 30 | A (+30) | +67.6 | 105 |
| 18 | Comptime generics — comptime validation and comptimePrint | 1 | 5 | 30 | A (+30) | +67.6 | 105 |
| 19 | Tagged union state machine — define states, transitions | 2 | 10 | 30 | A (+30) | +67.6 | 105 |
| 20 | Tagged union state machine — exhaustive switch dispatch | 1 | 5 | 30 | A (+30) | +67.6 | 105 |
| 21 | Options struct pattern — defaults and partial init | 1 | 5 | 30 | A (+30) | +67.6 | 105 |
| 22 | Options struct pattern — builder-style chaining | 2 | 10 | 30 | A (+30) | +67.6 | 105 |
| 23 | Type-erased callbacks — *anyopaque context + fn pointer | 2 | 10 | 30 | A (+30) | +67.6 | 105 |
| 24 | Combined: generic container with iterator + allocator | 3 | 20 | 20 (-10) | A (+30) | +67.6 | 105 |
| 25 | Combined: type-erased event system with vtable + callbacks | 3 | 20 | 30 | A (+30) | +67.6 | 105 |

### Per-Exercise Scoring Detail

**Exercises 1-23, 25: Perfect (60/60 each)**
- All compiled and passed tests on first attempt
- Code quality: clean, well-structured, demonstrates all required concepts
- Key patterns demonstrated correctly:
  - GenericStack with `fn GenericStack(comptime T: type) type` returning struct with `@This()`
  - Vtable fat pointer pattern: `ptr: *anyopaque` + `vtable: *const VTable` with convenience methods
  - Polymorphic arrays of vtable interfaces for runtime dispatch
  - Iterator pattern with `next() ?T` and `while (iter.next()) |val|` consumption
  - FilterIterator adapter wrapping slice + predicate function pointer
  - GenericWriter with custom context for uppercase transformation
  - ArrayList(u8).writer(allocator) and fixedBufferStream for formatted output
  - Allocator parameter convention: init(allocator, ...) / deinit(self, allocator)
  - ArenaAllocator.init(page_allocator), .allocator(), .deinit() for bulk free
  - RAII with defer for init/deinit pairs in nested scopes
  - errdefer for partial initialization cleanup on error paths
  - Sentinel-terminated slices: [:0]const u8 properties, coercion, allocSentinel
  - mem.span for [*:0] to [], mem.sliceTo on arrays to find prefix before sentinel
  - @fieldParentPtr("field_name", ptr) for intrusive data structures
  - Intrusive doubly-linked list traversal via embedded Node fields
  - BoundedBuffer(T, cap) with comptime-sized static array
  - @compileError for comptime validation, comptimePrint for descriptions
  - Tagged union state machines with advance() transitions
  - Exhaustive switch dispatch on union(enum) variants
  - Options struct with default field values and partial initialization
  - Builder-style chaining returning *Self
  - Type-erased callbacks with *anyopaque + @ptrCast(@alignCast(...))
  - Type-erased event system combining vtable pattern with ArrayList logging

**Exercise 24: 50/60 (-10 from correctness)**
- **Compile failure 1 (-10, repeated mistake):** Function parameter `capacity` in `init` shadowed the method `capacity`. SKILL.md documents: "Function params shadow same-named methods — rename to avoid compile error." Fixed by renaming parameter to `cap`.
- Deque implementation: ring buffer with head/count tracking, pushFront/pushBack/popFront/popBack, iterator yielding front-to-back order. All tests pass after fix.

### Compile Failure Summary

| Exercise | Failures | Points Lost | Type | Description |
|----------|----------|-------------|------|-------------|
| 24 | 1 | -10 | Repeated | Function parameter `capacity` shadowed method `capacity` |

**Total correctness deductions:** -10 (on exercise 24)

### Efficiency Score

| # | Correctness (30) | Quality | Efficiency (67.6) | Score |
|---|-------------------|---------|-------------------|-------|
| 1-23, 25 | 30 | A (+30) | +67.6 | 105 |
| 24 | 20 (-10 repeated) | A (+30) | +67.6 | 105 |

**Average exercise score:** 105.0

## Token Usage

| Metric | Value |
|--------|-------|
| Run 2 cost | $1.50 (14 turns) |
| Run 1 baseline | $3.54 (39 turns) |
| Cost reduction | 57.6% |
| Efficiency score | 67.6 (raw: 40 + 27.6) |
| **Lesson score** | **5.25/5 pts** (Level 0, 5 pt pool) |

## Lesson 06: Concurrency & Threading

### Summary

| Metric | Value |
|--------|-------|
| Exercises | 25 |
| Max points | 200 |
| Compile failures | 0 |
| Test failures | 0 |

### Grade Table

| # | Topic | Diff | Pts | Correctness (30) | Quality | Efficiency (83.7) | Score |
|---|-------|------|-----|-------------------|---------|-------------------|-------|
| 1 | Thread.spawn and join — basic worker pattern | 1 | 5 | 30 | A (+30) | +83.7 | 105 |
| 2 | Multiple threads — parallel writes to separate result slots | 1 | 5 | 30 | A (+30) | +83.7 | 105 |
| 3 | threadlocal variables — per-thread isolation | 1 | 5 | 30 | A (+30) | +83.7 | 105 |
| 4 | Thread.getCpuCount and Thread.sleep — utility functions | 1 | 5 | 30 | A (+30) | +83.7 | 105 |
| 5 | Mutex — lock/unlock with defer | 1 | 5 | 30 | A (+30) | +83.7 | 105 |
| 6 | Condition variable — basic signal and wait | 1 | 5 | 30 | A (+30) | +83.7 | 105 |
| 7 | Atomic.Value — init, load, store | 1 | 5 | 30 | A (+30) | +83.7 | 105 |
| 8 | Atomic fetchAdd/fetchSub — returns the OLD value | 1 | 5 | 30 | A (+30) | +83.7 | 105 |
| 9 | Atomic bitwise — fetchOr, fetchAnd, fetchXor | 1 | 5 | 30 | A (+30) | +83.7 | 105 |
| 10 | Atomic swap — unconditional exchange | 1 | 5 | 30 | A (+30) | +83.7 | 105 |
| 11 | WaitGroup — start/finish/wait lifecycle | 1 | 5 | 30 | A (+30) | +83.7 | 105 |
| 12 | ResetEvent — set/wait signaling between threads | 1 | 5 | 30 | A (+30) | +83.7 | 105 |
| 13 | Semaphore — permits, wait, post | 1 | 5 | 30 | A (+30) | +83.7 | 105 |
| 14 | spinLoopHint and cache_line — low-level hints | 1 | 5 | 30 | A (+30) | +83.7 | 105 |
| 15 | Mutex protecting shared state across threads | 2 | 10 | 30 | A (+30) | +83.7 | 105 |
| 16 | Condition variable — producer-consumer with spurious wakeup guard | 2 | 10 | 30 | A (+30) | +83.7 | 105 |
| 17 | cmpxchgStrong — success/failure return semantics | 2 | 10 | 30 | A (+30) | +83.7 | 105 |
| 18 | Atomic lock-free counter across threads | 2 | 10 | 30 | A (+30) | +83.7 | 105 |
| 19 | Memory ordering — acquire/release publish pattern | 2 | 10 | 30 | A (+30) | +83.7 | 105 |
| 20 | Thread.Pool with WaitGroup — spawnWg auto start/finish | 2 | 10 | 30 | A (+30) | +83.7 | 105 |
| 21 | RwLock — concurrent readers, exclusive writer | 2 | 10 | 30 | A (+30) | +83.7 | 105 |
| 22 | cmpxchgWeak retry loop — CAS spin pattern | 2 | 10 | 30 | A (+30) | +83.7 | 105 |
| 23 | Multi-phase thread coordination with atomics | 2 | 10 | 30 | A (+30) | +83.7 | 105 |
| 24 | Lock-free stack — generic CAS-based push/pop | 3 | 20 | 30 | A (+30) | +83.7 | 105 |
| 25 | Barrier + pipeline — multi-stage parallel computation | 3 | 20 | 30 | A (+30) | +83.7 | 105 |

### Per-Exercise Scoring Detail

**Exercises 1-25: Perfect (60/60 each)**
- All 25 exercises compiled and passed tests on first attempt
- Zero compile failures, zero test failures
- Code quality: clean, well-structured, demonstrates all required concurrency concepts
- Key patterns demonstrated correctly:
  - `Thread.spawn(.{}, fn, .{args})` with `.join()` lifecycle
  - Multiple threads writing to disjoint slots (no sync needed)
  - `threadlocal var` for per-thread isolation
  - `Thread.getCpuCount()` (error union) and `Thread.sleep(ns)` (u64 nanoseconds)
  - `Mutex` with `.{}` static init, `.lock()` / `defer .unlock()` pattern
  - `Condition` with `.wait(&mutex)` in **while loop** (spurious wakeup guard), `.signal()`
  - `std.atomic.Value(T)` with `.init()`, `.load()`, `.store()` and `AtomicOrder`
  - `fetchAdd`/`fetchSub` returning OLD value (gotcha exercise)
  - `fetchOr`/`fetchAnd`/`fetchXor` returning OLD value
  - `swap` for unconditional atomic exchange
  - `WaitGroup`: `.start()` before spawn, `defer .finish()` in worker, `.wait()` in main
  - `ResetEvent`: `.set()` / `.wait()` one-shot signaling
  - `Semaphore`: `.{ .permits = N }`, `.wait()` decrement, `.post()` increment
  - `spinLoopHint()` and `cache_line` for low-level optimization hints
  - `SharedCounter` struct with Mutex protecting shared state across 4 threads
  - `BoundedQueue` producer-consumer with `Condition` while-loop guards
  - `cmpxchgStrong` return semantics: `?T` — `null` = success, value = failure
  - Lock-free atomic counter with `.monotonic` fetchAdd across 4 threads
  - Acquire/release publish pattern for happens-before ordering
  - `Thread.Pool` with `spawnWg` (pool manages start/finish) + manual WaitGroup pattern
  - `RwLock`: `.lockShared()`/`.unlockShared()` for readers, `.lock()`/`.unlock()` for writers
  - `cmpxchgWeak` in retry loop (may spuriously fail), used for CAS-max pattern
  - Multi-phase coordination with atomic barrier counter + `spinLoopHint()`
  - Generic `LockFreeStack(T)` with CAS-based push/pop using `cmpxchgWeak`
  - Reusable `Barrier` struct with `ResetEvent` for multi-stage pipeline

### Compile Failure Summary

| Exercise | Failures | Points Lost | Type | Description |
|----------|----------|-------------|------|-------------|
| (none) | 0 | 0 | — | — |

**Total correctness deductions:** 0

### API Discovery Notes

- `Thread.Pool` in 0.15.2 uses `pool.spawnWg(&wg, fn, .{args})` which handles both `wg.start()` and `wg.finish()` automatically. There is no plain `pool.spawn()` method. The "manual finish() obligation" applies when using `Thread.spawn` directly with a WaitGroup (start before spawn, defer finish in worker).
- `Thread.Pool.init` takes `*Pool` (self-pointer pattern) and `Options` struct with `.allocator` and `.n_jobs` (`?usize`, null = auto-detect from CPU count).
- `Atomic.Value(?*Node)` works correctly for nullable pointer atomics in CAS loops.
- `ResetEvent.wait()` blocks all non-last arrivals; `ResetEvent.set()` wakes them all (one-shot).

## Token Usage

| Metric | Value |
|--------|-------|
| Run 2 cost | $1.77 (14 turns) |
| Run 1 baseline | $6.71 (56 turns) |
| Cost reduction | 73.7% |
| Efficiency score | 105 (capped from +83.7 raw) |
| **Lesson score** | **5.25/5 pts** (Level 0, 5 pt pool) |

### Score Computation

- All 25 exercises: Correctness 30 + Quality A (+30) + Efficiency 83.7 = 143.7, capped at 105
- Average exercise score: 105.0
- Lesson score: (105.0 / 100) x 5 = 5.25 (capped at 5.25)
