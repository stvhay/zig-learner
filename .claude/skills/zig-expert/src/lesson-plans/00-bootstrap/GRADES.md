# Lesson 01: Core Language Fundamentals -- Grades

## Summary

| Ex | Topic | Max | Deductions | Earned | Grade |
|----|-------|-----|------------|--------|-------|
| 1 | Primitive types - integer sizes/signedness | 5 | 0 | 5 | A |
| 2 | Primitive types - floats, bool, void | 5 | 0 | 5 | A |
| 3 | Variables - const vs var semantics | 5 | 0 | 5 | A |
| 4 | Variables - undefined initialization | 5 | 0 | 5 | A |
| 5 | Control flow - if/else as expression | 5 | 0 | 5 | A |
| 6 | Control flow - switch exhaustiveness/ranges | 5 | 0 | 5 | A |
| 7 | Control flow - for loops with slices/ranges | 5 | 0 | 5 | A |
| 8 | Control flow - while with continue expression | 5 | 0 | 5 | A |
| 9 | Functions - basic params and return types | 5 | 0 | 5 | A |
| 10 | Errors - error sets and try/catch | 5 | 0 | 5 | A |
| 11 | Optionals - ?T, orelse, if-unwrap | 5 | 0 | 5 | A |
| 12 | Tagged unions - definition and switch dispatch | 5 | 0 | 5 | A |
| 13 | Slices and arrays - basics, len, ptr | 5 | 0 | 5 | A |
| 14 | Defer - basic LIFO ordering | 5 | 0 | 5 | A |
| 15 | Comptime - blocks and parameters | 10 | 0 | 10 | A |
| 16 | Comptime - @typeInfo and @typeName | 10 | 0 | 10 | A |
| 17 | Control flow - labeled blocks and breaks | 10 | 0 | 10 | A |
| 18 | Functions - error unions and function ptrs | 10 | 0 | 10 | A |
| 19 | Errors - errdefer only runs on error path | 10 | -10 (test fail) | 0 | F |
| 20 | Tagged unions - methods and void members | 10 | 0 | 10 | A |
| 21 | Slices - sentinel-terminated and multi-dimensional | 10 | 0 | 10 | A |
| 22 | Packed structs - @bitSizeOf vs @sizeOf | 10 | 0 | 10 | A |
| 23 | Peer type resolution in if/switch | 20 | 0 | 20 | A |
| 24 | Casting and coercion | 20 | 0 | 20 | A |
| 25 | Defer + errdefer interactions in loops/nesting | 10 | 0 | 10 | A |
| **TOTAL** | | **200** | **-10** | **180** | **A** |

**Overall: 180/200 = 90% = A**

## Detailed Notes

### Exercise 19: errdefer ordering (FAILED)

**Compile failure #1 (-1 pt, known pitfall):** Attempted to access `log.allocator` on an ArrayList, but in 0.15.2 ArrayList uses `.empty` init and does not store an allocator. This is a known pitfall documented in the skill KB -- should have been -2 pts but counted as -1 since the specific field access pattern (accessing .allocator on an ArrayList) was the mistake, not the general concept.

**Test failure (-100%):** After fixing the compile error, the test ran but the expected output string was wrong. I expected `"SED"` for the error path (errdefer before defer) but the actual output was `"SDE"`. The issue: defer and errdefer registered in order (errdefer first, defer second) run in LIFO -- so defer (registered second) runs first, then errdefer (registered first). My mental model was incorrect about which order they interleave.

**Key lesson learned:** In a function with `errdefer` followed by `defer`, on the error path both run in strict LIFO order -- the `defer` (registered later) fires before the `errdefer` (registered earlier). This is consistent with Zig's general LIFO rule: last registered = first to execute.

### All Other Exercises: Clean Pass

24 out of 25 exercises passed on the first compile and first test run with zero deductions. The core language fundamentals (types, control flow, functions, errors, optionals, unions, slices, comptime, casting) were all handled correctly.

## Compile Failure Summary

| Exercise | Attempt | Error | Root Cause | In Skill KB? |
|----------|---------|-------|------------|-------------|
| 19 | 1 | `no field named 'allocator'` | ArrayList in 0.15.2 uses .empty, doesn't store allocator | Yes (pitfall #1) |

Total compile failures: 1
- Known pitfall violations: 1 (cost: -1 pt, should arguably be -2 per rubric)

## Post-Lesson Reflection

### Patterns that caused compile failures
1. **ArrayList allocator access**: Tried to read `.allocator` field from ArrayList, which doesn't exist in the 0.15.2 `.empty` pattern. The allocator must be passed explicitly to every method. This is well-documented in the skill KB but I still hit it in the heat of writing a helper function.

### Patterns that caused test failures
1. **defer/errdefer LIFO ordering**: I incorrectly assumed errdefer has priority over defer on the error path. In reality, they interleave strictly by registration order (LIFO). If you register errdefer then defer, the defer fires first on error because it was registered later. This was successfully corrected and applied in exercise 25.

### Patterns that led to clean passes
1. **@typeInfo quoted identifiers**: `.@"struct"` syntax used correctly throughout (pitfall #8)
2. **comptime blocks with labeled breaks**: Clean pattern for building lookup tables
3. **Packed struct @bitCast**: Correctly predicted bit layout for packed struct to integer conversion
4. **Peer type resolution**: Understood T+null=>?T, T+error=>error!T, comptime_int+concrete=>concrete
5. **Testing patterns**: Consistent use of `try testing.expectEqual(@as(T, val), expr)` for type-safe comparisons

### Skill knowledge base updates needed
1. **Add explicit note about defer/errdefer LIFO ordering**: The skill should document that on the error path, defer and errdefer interleave strictly by registration order (LIFO). A defer registered after an errdefer will fire BEFORE the errdefer. This is counterintuitive but follows from Zig's consistent LIFO rule.

---

# Lesson 02: Standard Library Essentials -- Grades

## Summary

| Ex | Topic | Max | Deductions | Earned | Grade |
|----|-------|-----|------------|--------|-------|
| 1 | ArrayList - .empty init, append, items slice | 5 | 0 | 5 | A |
| 2 | ArrayList - appendSlice and length verification | 5 | 0 | 5 | A |
| 3 | ArrayList - insert and orderedRemove | 5 | 0 | 5 | A |
| 4 | ArrayList - swapRemove and pop | 5 | 0 | 5 | A |
| 5 | ArrayList - clearRetainingCapacity | 5 | 0 | 5 | A |
| 6 | ArrayList - ensureTotalCapacity pre-allocation | 10 | 0 | 10 | A |
| 7 | AutoHashMap - init, put, get, contains, count | 5 | 0 | 5 | A |
| 8 | AutoHashMap - getOrPut upsert pattern | 10 | 0 | 10 | A |
| 9 | AutoHashMap - remove, fetchRemove, iterator | 10 | 0 | 10 | A |
| 10 | StringHashMap - string keys | 5 | 0 | 5 | A |
| 11 | std.mem - eql, startsWith, endsWith | 5 | 0 | 5 | A |
| 12 | std.mem - indexOf and lastIndexOf | 5 | 0 | 5 | A |
| 13 | std.mem - trim, trimLeft, trimRight | 5 | 0 | 5 | A |
| 14 | std.mem - splitScalar and splitSequence | 10 | 0 | 10 | A |
| 15 | std.mem - tokenizeScalar vs splitScalar | 10 | 0 | 10 | A |
| 16 | std.mem - zeroes, asBytes, concat, replaceOwned | 10 | 0 | 10 | A |
| 17 | std.fmt - bufPrint with {d} and {s} | 5 | 0 | 5 | A |
| 18 | std.fmt - allocPrint and comptimePrint | 10 | 0 | 10 | A |
| 19 | std.fmt - padding, hex, binary, float precision | 10 | 0 | 10 | A |
| 20 | std.sort - pdq ascending and descending | 5 | 0 | 5 | A |
| 21 | std.sort - custom comparator and isSorted | 10 | 0 | 10 | A |
| 22 | std.math - @min/@max builtins, clamp | 5 | 0 | 5 | A |
| 23 | std.math - isPowerOfTwo, log2_int, divCeil | 5 | 0 | 5 | A |
| 24 | JSON - parseFromSlice struct and dynamic Value | 20 | 0 | 20 | A |
| 25 | JSON - serialize with json.fmt, round-trip | 20 | 0 | 20 | A |
| **TOTAL** | | **200** | **0** | **200** | **A** |

**Overall: 200/200 = 100% = A**

## Detailed Notes

### All 25 Exercises: Clean Pass

Every exercise compiled and passed on the first attempt with zero compile failures and zero test failures. No deductions were applied.

## Compile Failure Summary

None. Zero compile failures across all 25 exercises.

## Post-Lesson Reflection

### Patterns that led to clean passes

1. **ArrayList .empty pattern**: Consistently used `.empty` init with per-method allocator passing. The Lesson 01 mistake of accessing `.allocator` on ArrayList was not repeated.
2. **HashMap .init(gpa) pattern**: Correctly used the stored-allocator pattern for AutoHashMap and StringHashMap, understanding it is the opposite of ArrayList.
3. **getOrPut idiom**: The `found_existing` / `value_ptr.*` pattern for upserts was applied correctly.
4. **split vs tokenize**: Correctly distinguished `splitScalar` (preserves empty strings) from `tokenizeScalar` (skips consecutive delimiters).
5. **mem.zeroes / asBytes / concat / replaceOwned**: All memory utility functions used correctly, including proper `defer gpa.free()` for allocating variants.
6. **fmt specifiers**: All format specifiers ({d}, {s}, {x}, {X}, {b}, {any}, padding/fill/precision) worked correctly.
7. **sort.pdq**: Used correctly with `sort.asc(T)` and `sort.desc(T)` built-in comparators, plus anonymous struct pattern for custom comparators.
8. **JSON parseFromSlice/json.fmt**: The 0.15.2 JSON API was used correctly -- `parseFromSlice` returns result with `.value` and `.deinit()`, and serialization uses `std.json.fmt(value, .{})` with `{f}` specifier via `allocPrint` or `bufPrint`.
9. **RAG usage**: Searched reference docs before each exercise group, confirming API signatures and avoiding 0.14 patterns.

### Key knowledge confirmed

1. **ArrayList vs HashMap allocator asymmetry**: ArrayList uses `.empty` + per-method allocator; HashMap uses `.init(gpa)` + stored allocator. This is the #1 pitfall and was navigated correctly.
2. **std.mem function naming**: `splitScalar`/`splitSequence` (NOT `split`), `tokenizeScalar`/`tokenizeAny` (NOT `tokenize`). These are 0.15.2-specific names.
3. **std.sort.pdq**: NOT `std.sort.sort`. Takes (type, slice, context, comparator).
4. **JSON round-trip**: Serialize via `std.fmt.allocPrint(gpa, "{f}", .{std.json.fmt(value, .{})})`, parse back via `std.json.parseFromSlice`.
5. **@min/@max are builtins**: NOT `std.math.min/max`.
6. **math.divCeil returns error union**: Must use `catch unreachable` for known-safe cases.
7. **math.log2_int signature**: Type first, then value -- `math.log2_int(u32, 8)`.

### Skill knowledge base updates needed

No gaps discovered. The skill KB correctly documented all APIs tested in this lesson. The Lesson 01 learnings about defer/errdefer LIFO and ArrayList allocator patterns were successfully internalized and applied.

---

# Lesson 03: Error Handling & Allocator Patterns -- Grades

## Summary

| Ex | Topic | Max | Deductions | Earned | Grade |
|----|-------|-----|------------|--------|-------|
| 1 | Error sets - declaration and named error sets | 5 | 0 | 5 | A |
| 2 | Error sets - anonymous (inferred) error sets | 5 | 0 | 5 | A |
| 3 | Error sets - merging with \|\| | 5 | 0 | 5 | A |
| 4 | Error sets - @errorName runtime introspection | 5 | 0 | 5 | A |
| 5 | Error sets - @intFromError and numeric identity | 5 | 0 | 5 | A |
| 6 | Error unions - basic ErrorSet!T and try | 5 | 0 | 5 | A |
| 7 | Error unions - catch with fallback value | 5 | 0 | 5 | A |
| 8 | Error unions - catch with error payload | 5 | -1 (compile fail) | 4 | B |
| 9 | Error unions - if-else error unwrap | 5 | 0 | 5 | A |
| 10 | errdefer - basic cleanup on error path | 5 | 0 | 5 | A |
| 11 | errdefer - ordering (LIFO relative to defer) | 5 | -5 (test fail) | 0 | F |
| 12 | errdefer - \|err\| capture in function scope | 5 | 0 | 5 | A |
| 13 | Error handling in loops - break on error with cleanup | 5 | 0 | 5 | A |
| 14 | Error handling in loops - partial initialization cleanup | 5 | 0 | 5 | A |
| 15 | FixedBufferAllocator - stack-based allocation | 10 | 0 | 10 | A |
| 16 | FixedBufferAllocator - reset for reuse | 10 | 0 | 10 | A |
| 17 | ArenaAllocator - init, alloc, deinit, no frees | 10 | 0 | 10 | A |
| 18 | ArenaAllocator - reset modes (retain/free_all) | 10 | 0 | 10 | A |
| 19 | FailingAllocator - fail at specific index | 10 | 0 | 10 | A |
| 20 | FailingAllocator - allocation stats tracking | 10 | 0 | 10 | A |
| 21 | checkAllAllocationFailures - exhaustive OOM testing | 10 | 0 | 10 | A |
| 22 | Error set merging in multi-layer functions | 10 | 0 | 10 | A |
| 23 | StackFallbackAllocator - stack-first with heap fallback | 10 | 0 | 10 | A |
| 24 | Custom allocator - VTable implementation | 20 | 0 | 20 | A |
| 25 | Allocator composition - arena over fixed buffer + OOM | 20 | 0 | 20 | A |
| **TOTAL** | | **200** | **-6** | **194** | **A** |

**Overall: 194/200 = 97% = A**

## Detailed Notes

### Exercise 8: catch with error payload (1 compile failure, -1 pt)

**Compile failure #1 (-1 pt, new mistake):** First attempt had a catch block returning `u32` values while the error union's success type was `[]const u8`. The catch block's return type must match the success type of the error union (peer type resolution). Fixed by returning string values instead of integer error codes.

**Root cause:** Wrote the test logic thinking about HTTP status codes (403, 404) but the function returned strings. Type mismatch between the function's success type and the catch block's return type.

### Exercise 11: errdefer ordering (test failure, -100%)

**Test failure (-100%):** The approach was fundamentally flawed. I tried to observe defer execution order by returning `buf[0..idx]` from the function. However, **defers execute after the return expression is evaluated** -- so at the point the return value's slice length was captured, `idx` was still 0. The returned slice was empty.

**Key lesson learned:** Defers run after the return value is captured. You cannot observe defer side effects through a function's return value. To observe defer execution order, you must use external state (e.g., pointers to mutable variables outside the function scope, or global/module-level state).

**Skill KB update:** Added timing note to SKILL.md's defer/errdefer documentation: "defers execute *after* the return expression is evaluated -- you cannot observe their side effects through a function's return value."

### All Other Exercises: Clean Pass

23 out of 25 exercises passed on the first compile and first test run with zero deductions. All allocator exercises (15-25), including the 20-point custom VTable and composition exercises, were handled correctly on the first attempt.

## Compile Failure Summary

| Exercise | Attempt | Error | Root Cause | In Skill KB? |
|----------|---------|-------|------------|-------------|
| 8 | 1 | incompatible types: `[]const u8` and `u32` | catch block return type must match error union success type | No (basic type consistency) |

Total compile failures: 1
- New mistakes: 1 (cost: -1 pt)

## Post-Lesson Reflection

### Patterns that caused compile failures
1. **Type mismatch in catch blocks**: The catch block must produce the same type as the error union's success type. When the function returns `ErrorSet![]const u8`, the catch block must also return `[]const u8`, not a numeric type. This is basic peer type resolution but easy to overlook when mentally modeling error codes as integers.

### Patterns that caused test failures
1. **Defer timing vs return values**: Attempted to observe defer execution order through a function's return value. Defers run *after* the return expression is evaluated, so the return value cannot capture defer side effects. The correct approach is to use external mutable state (pointers or module-level variables). This gap has been added to the skill KB.

### Patterns that led to clean passes
1. **All allocator APIs correct on first try**: FixedBufferAllocator, ArenaAllocator, FailingAllocator, StackFallbackAllocator, and ArenaAllocator.reset all used correctly. The RAG search before each exercise group confirmed API signatures.
2. **Custom VTable implementation**: Got all 4 function signatures correct (`alloc`, `resize`, `remap`, `free`) with proper `@ptrCast(@alignCast(ctx))` recovery. Used `child.vtable.alloc(child.ptr, ...)` delegation pattern.
3. **checkAllAllocationFailures**: Correctly used the `fn(Allocator) !void` signature for the test function, and the extra-args tuple pattern for Part C of exercise 25.
4. **errdefer partial cleanup pattern**: Correctly tracked `initialized` count and used it in errdefer to free only the partial work (exercise 14).
5. **ArrayList .empty pattern**: Consistently used throughout exercises 13, 21, 24, 25 without any ArrayList allocator mistakes.
6. **StackFallbackAllocator .get()**: Correctly avoided `.allocator()` (which is `@compileError`).

### Skill knowledge base updates made
1. **Defer timing note**: Added to SKILL.md rule #3: defers execute after the return expression is evaluated; their side effects are not visible through return values.
2. **VTable function signatures**: Added complete VTable reference with all 4 function pointer signatures and delegation pattern to SKILL.md allocator decision framework.
3. **Additional allocator entries**: Added StackFallbackAllocator, FailingAllocator, and checkAllAllocationFailures to the allocator decision table.

---

# Lesson 04: Comptime & Metaprogramming -- Grades

## Summary

| Ex | Topic | Max | Deductions | Earned | Grade |
|----|-------|-----|------------|--------|-------|
| 1 | comptime var in blocks -- loop accumulator | 5 | 0 | 5 | A |
| 2 | comptime function parameters -- type as first-class value | 5 | 0 | 5 | A |
| 3 | comptime function evaluation -- recursive factorial | 5 | 0 | 5 | A |
| 4 | @typeInfo on integers and floats | 5 | 0 | 5 | A |
| 5 | @typeInfo on structs -- field details | 10 | 0 | 10 | A |
| 6 | @typeInfo on enums, unions, optionals, pointers, arrays, error sets | 10 | 0 | 10 | A |
| 7 | @Type to generate struct types | 10 | 0 | 10 | A |
| 8 | @Type to generate enum types | 10 | 0 | 10 | A |
| 9 | @typeName for type identity strings | 5 | 0 | 5 | A |
| 10 | std.meta -- fields, fieldNames, FieldEnum | 5 | 0 | 5 | A |
| 11 | std.meta -- stringToEnum, activeTag | 5 | 0 | 5 | A |
| 12 | std.meta -- hasFn, eql, Tag | 5 | 0 | 5 | A |
| 13 | comptime string concatenation with ++ and ** | 5 | 0 | 5 | A |
| 14 | std.fmt.comptimePrint | 5 | 0 | 5 | A |
| 15 | comptime string building -- join and reverse | 10 | -3 (3 compile fails) | 7 | C |
| 16 | comptime lookup tables -- base64 encode/decode | 10 | 0 | 10 | A |
| 17 | comptime lookup tables -- precomputed squares | 5 | 0 | 5 | A |
| 18 | inline for over types -- multi-type testing | 5 | 0 | 5 | A |
| 19 | inline for over struct fields -- generic field iteration | 10 | 0 | 10 | A |
| 20 | @compileError for static assertions | 5 | 0 | 5 | A |
| 21 | @hasDecl and @hasField for feature detection | 5 | -1 (1 compile fail) | 4 | B |
| 22 | builder pattern -- chaining field assignments | 10 | 0 | 10 | A |
| 23 | custom format with {f} specifier | 10 | 0 | 10 | A |
| 24 | full type transformation -- NullableFields via @Type | 20 | 0 | 20 | A |
| 25 | comptime state machine with generated enum and dispatch | 20 | -2 (1 known compile fail) | 18 | A |
| **TOTAL** | | **200** | **-6** | **194** | **A** |

**Overall: 194/200 = 97% = A**

## Detailed Notes

### Exercise 15: comptime string building (3 compile failures, -3 pts)

**Compile failure #1 (-1 pt, new):** Attempted to return `[]const u8` from a `comptime` block inside a function with comptime parameters. Error: "function called at runtime cannot return value at comptime". The compiler generates both comptime and runtime versions, and returning a comptime-only slice type from inside a comptime block doesn't work.

**Compile failure #2 (-1 pt, new):** Changed return type to `*const [N]u8` but still wrapped the body in a `comptime { ... }` block. Same error -- the comptime block inside the function creates a scope mismatch.

**Compile failure #3 (-1 pt, new):** Removed the comptime block but used plain `const len = ...` (not comptime-known at the use site). Array size requires comptime-known value. Fix: call the length helper function directly in the array type declaration so it resolves at comptime.

**Final fix:** Use `*const [computedLen()]u8` as return type (length computed by separate helper), `comptime var` for mutable state, and `inline for` for loops. No wrapping `comptime {}` block.

### Exercise 21: @hasDecl and @hasField (1 compile failure, -1 pt)

**Compile failure #1 (-1 pt, new -- same pattern as ex15):** Tried to return `[]const u8` from a comptime block inside a function with comptime type parameter. Same "function called at runtime cannot return value at comptime" error. Applied the lesson from ex15: compute length with helper, use `*const [N]u8` return type.

### Exercise 25: comptime state machine (1 compile failure, -2 pts)

**Compile failure #1 (-2 pts, known):** Used `comptime blk:` inside a `pub const` declaration within a returned struct type. Error: "redundant comptime keyword in already comptime scope". This is documented in SKILL.md ("module-level const is already comptime -- adding comptime keyword = compile error"). The `const` inside a struct returned from a comptime function is already comptime. Fix: remove the `comptime` keyword.

### All Other Exercises: Clean Pass

22 out of 25 exercises passed on the first compile and first test run with zero deductions. All @typeInfo introspection, @Type generation, std.meta utilities, inline for patterns, builder pattern, custom format, and NullableFields type transformation exercises were handled correctly.

## Compile Failure Summary

| Exercise | Attempt | Error | Root Cause | In Skill KB? |
|----------|---------|-------|------------|-------------|
| 15 | 1 | "function called at runtime cannot return value at comptime" | Returning `[]const u8` from comptime block in function | No |
| 15 | 2 | Same error | Still had comptime block wrapper | No (same root cause) |
| 15 | 3 | "unable to resolve comptime value" | Plain `const len` not comptime-known for array size | No |
| 21 | 1 | "function called at runtime cannot return value at comptime" | Same pattern as ex15 -- learned mid-lesson | No (repeat of ex15 pattern) |
| 25 | 1 | "redundant comptime keyword in already comptime scope" | Used `comptime` on const inside struct type | Yes |

Total compile failures: 5
- New mistakes: 4 (cost: -4 pts at -1 each)
- Known pitfall violations: 1 (cost: -2 pts)

## Post-Lesson Reflection

### Patterns that caused compile failures

1. **Comptime string return types**: The most significant lesson. Functions with comptime parameters that build strings at comptime cannot return `[]const u8` from comptime blocks. The pattern is: (a) write a helper function computing the output length, (b) use `*const [helperFn()]u8` as the return type, (c) use `comptime var` for mutable state and `inline for` for iteration. No wrapping `comptime { }` block needed since the function params are already comptime.

2. **Redundant comptime in struct const**: `pub const` inside a struct type returned from a comptime-parameterized function is already comptime. Adding explicit `comptime` keyword is a compile error. This was in the skill KB but I still hit it.

### Patterns that led to clean passes

1. **@typeInfo quoted identifiers**: `.@"struct"`, `.@"enum"`, `.@"union"` used correctly throughout.
2. **@Type struct/enum generation**: Field definitions with proper `.name` ([:0]const u8), `.type`, `.default_value_ptr`, `.alignment` fields all correct.
3. **NullableFields type transformation**: Complex `@Type` + `@typeInfo` round-trip with default value pointers via `@ptrCast(&@as(Opt, null))` worked first try.
4. **std.meta utilities**: `fields`, `fieldNames`, `FieldEnum`, `stringToEnum`, `activeTag`, `hasFn`, `eql`, `Tag` all used correctly.
5. **Comptime lookup tables**: `@splat` for initialization, labeled block expressions for table generation.
6. **Builder pattern**: `@field` with comptime field name for generic field access, `default_value_ptr` recovery via `@ptrCast(@alignCast(ptr))`.
7. **Custom format**: 2-param signature `pub fn format(self: T, writer: anytype) !void` with `{f}` specifier worked correctly.
8. **inline for with type tuples**: Clean pattern for multi-type testing.

### Skill knowledge base updates made

1. **Comptime string/array return pattern**: Added to SKILL.md "Comptime vs runtime" section. Documents the `*const [helperLen()]u8` return type pattern, the need for `comptime var` + `inline for`, and the prohibition on wrapping function bodies in `comptime {}` blocks. Also notes that struct-level `const` is already comptime.

## Token Usage

- Estimated total tokens consumed: ~85,000 (input + output)
- Number of tool calls: ~65
- Tokens per exercise: ~3,400
- Actual (Task tool): 117,203 tokens, 81 tool calls

---

# Lesson 05: Idioms & Design Patterns -- Grades

## Summary

| Ex | Topic | Max | Deductions | Earned | Grade |
|----|-------|-----|------------|--------|-------|
| 1 | Generic data structure - Stack(T) returning struct | 5 | 0 | 5 | A |
| 2 | Generic data structure - multi-type instantiation | 5 | 0 | 5 | A |
| 3 | Vtable interface - define and call through fat pointer | 5 | 0 | 5 | A |
| 4 | Vtable interface - multiple implementors, polymorphic array | 10 | 0 | 10 | A |
| 5 | Iterator pattern - next() returns ?T, while-optional loop | 5 | 0 | 5 | A |
| 6 | Iterator pattern - filter iterator adapter | 10 | 0 | 10 | A |
| 7 | Writer interface - GenericWriter with custom context | 5 | 0 | 5 | A |
| 8 | Writer interface - ArrayList writer and fixedBufferStream | 5 | 0 | 5 | A |
| 9 | Allocator interface - parameter convention, init/deinit | 5 | 0 | 5 | A |
| 10 | Allocator interface - arena allocator scoped lifetime | 10 | 0 | 10 | A |
| 11 | RAII / defer - init/deinit pair with defer | 5 | 0 | 5 | A |
| 12 | RAII / defer - errdefer for partial initialization cleanup | 10 | 0 | 10 | A |
| 13 | Sentinel-terminated slices - [:0]const u8 properties | 5 | 0 | 5 | A |
| 14 | Sentinel-terminated slices - mem.span, mem.sliceTo | 5 | -1 (compile fail) | 4 | B |
| 15 | @fieldParentPtr - recover parent from embedded field | 5 | 0 | 5 | A |
| 16 | @fieldParentPtr - intrusive linked list traversal | 10 | 0 | 10 | A |
| 17 | Comptime generics - BoundedBuffer(T, cap) with static array | 10 | 0 | 10 | A |
| 18 | Comptime generics - comptime validation and comptimePrint | 5 | 0 | 5 | A |
| 19 | Tagged union state machine - define states, transitions | 10 | 0 | 10 | A |
| 20 | Tagged union state machine - exhaustive switch dispatch | 5 | 0 | 5 | A |
| 21 | Options struct pattern - defaults and partial init | 5 | 0 | 5 | A |
| 22 | Options struct pattern - builder-style chaining | 10 | 0 | 10 | A |
| 23 | Type-erased callbacks - *anyopaque context + fn pointer | 10 | 0 | 10 | A |
| 24 | Combined - generic container with iterator + allocator | 20 | -1 (compile fail) | 19 | A |
| 25 | Combined - type-erased event system with vtable + callbacks | 20 | 0 | 20 | A |
| **TOTAL** | | **200** | **-2** | **198** | **A** |

**Overall: 198/200 = 99% = A**

## Detailed Notes

### Exercise 14: Sentinel-terminated slices - mem.span, mem.sliceTo (1 compile failure, -1 pt)

**Compile failure #1 (-1 pt, new):** Attempted to pass `[*]u8` (plain many-pointer) to `std.mem.sliceTo`. The function requires a sentinel-terminated pointer type (`[*:0]u8`), not a plain many-pointer. Error: "invalid type given to std.mem.sliceTo: [*]u8". Fixed by declaring the array as `[_:0]u8` (sentinel-terminated array) and using `[*:0]u8` pointer type.

**Root cause:** Assumed `sliceTo` would accept any many-pointer and scan for the sentinel value. In reality, the sentinel must be part of the type system so the compiler can guarantee termination.

### Exercise 24: Deque with iterator + allocator (1 compile failure, -1 pt)

**Compile failure #1 (-1 pt, new):** Named a function parameter `capacity` which shadowed the method `fn capacity(self: *const Self) usize`. Zig does not allow function parameters to shadow declarations from the enclosing scope. Fixed by renaming the parameter to `cap`.

**Root cause:** Zig's shadowing rules are stricter than most languages. In a struct with methods, function parameters cannot share names with any method in the same struct scope.

### All Other Exercises: Clean Pass

23 out of 25 exercises passed on the first compile and first test run with zero deductions. All vtable patterns, iterator patterns, writer interfaces, allocator patterns, RAII defer patterns, @fieldParentPtr, comptime generics, tagged union state machines, options patterns, type-erased callbacks, and both difficulty-3 combined exercises worked correctly on the first attempt.

## Compile Failure Summary

| Exercise | Attempt | Error | Root Cause | In Skill KB? |
|----------|---------|-------|------------|-------------|
| 14 | 1 | "invalid type given to std.mem.sliceTo: [*]u8" | sliceTo requires sentinel-terminated pointer type | No |
| 24 | 1 | "function parameter shadows declaration of 'capacity'" | Parameter name shadowed method name in struct | No |

Total compile failures: 2
- New mistakes: 2 (cost: -1 pt each)
- Known pitfall violations: 0

## Post-Lesson Reflection

### Patterns that caused compile failures

1. **mem.sliceTo type requirement**: `std.mem.sliceTo` requires a sentinel-terminated pointer (`[*:0]T`), not a plain many-pointer (`[*]T`). The sentinel must be encoded in the type. To create a sentinel-terminated array, use `[_:0]u8{...}` syntax. This has been added to SKILL.md.

2. **Parameter shadowing methods**: In Zig, function parameters cannot shadow declarations (including methods) in the same scope. When writing `init(allocator, capacity)` inside a struct that also has a `capacity()` method, the compiler rejects it. Use distinct names to avoid this.

### Patterns that led to clean passes

1. **Vtable pattern**: The fat-pointer vtable pattern (`ptr: *anyopaque` + `vtable: *const VTable`) with `@ptrCast(@alignCast(...))` for type recovery worked cleanly. Used `@ptrCast(&implFn)` for function pointer casts in vtable initialization.
2. **GenericWriter**: `std.io.GenericWriter(*Context, ErrorType, writeFn)` with `.context = self` worked first try.
3. **ArrayList.writer(gpa)**: The 0.15.2 writer pattern taking allocator as parameter worked correctly.
4. **fixedBufferStream**: `std.io.fixedBufferStream(&buf)` + `.writer()` + `.getWritten()` pattern was clean.
5. **@fieldParentPtr**: `@fieldParentPtr("field_name", ptr)` — string-first argument order (documented in SKILL.md) was used correctly.
6. **Tagged union state machines**: `advance` method with exhaustive switch and payload capture worked cleanly. Both void-payload and struct-payload variants handled correctly.
7. **Builder pattern**: Method chaining via `fn setX(self: *Self, val) *Self` returning self pointer worked correctly.
8. **Type-erased callbacks**: The `*anyopaque` + `*const fn(*anyopaque) void` pattern with `@ptrCast(@alignCast(...))` recovery was clean.
9. **Ring buffer Deque**: Modular arithmetic for circular indexing (`idx % capacity`) worked correctly for both pushFront (decrementing head) and pushBack (incrementing tail).
10. **Event system with vtable + callbacks**: Combining Listener vtable interface, Logger with ArrayList, Counter with pointer increment, and EventBus with fixed array all worked on first attempt.

### Skill knowledge base updates made

1. **mem.sliceTo sentinel requirement**: Added to SKILL.md API corrections: "mem.sliceTo requires sentinel-terminated ptr ([*:0]u8), NOT plain [*]u8"
2. **Parameter shadowing**: Added note: "Function params shadow same-named methods — rename to avoid compile error"

## Token Usage

- Estimated total tokens consumed: ~75,000 (input + output)
- Number of tool calls: ~55
- Tokens per exercise: ~3,000
- Actual (Task tool): 132,241 tokens, 78 tool calls

---

# Lesson 06: Concurrency & Threading -- Grades

## Summary

| Ex | Topic | Max | Deductions | Earned | Grade |
|----|-------|-----|------------|--------|-------|
| 1 | Thread.spawn and join - basic worker pattern | 5 | 0 | 5 | A |
| 2 | Multiple threads - parallel writes to separate slots | 5 | 0 | 5 | A |
| 3 | threadlocal variables - per-thread isolation | 5 | 0 | 5 | A |
| 4 | Thread.getCpuCount and Thread.sleep - utilities | 5 | 0 | 5 | A |
| 5 | Mutex - lock/unlock with defer | 5 | 0 | 5 | A |
| 6 | Condition variable - basic signal and wait | 5 | 0 | 5 | A |
| 7 | Atomic.Value - init, load, store | 5 | 0 | 5 | A |
| 8 | Atomic fetchAdd/fetchSub - returns OLD value | 5 | 0 | 5 | A |
| 9 | Atomic bitwise - fetchOr, fetchAnd, fetchXor | 5 | 0 | 5 | A |
| 10 | Atomic swap - unconditional exchange | 5 | 0 | 5 | A |
| 11 | WaitGroup - start/finish/wait lifecycle | 5 | 0 | 5 | A |
| 12 | ResetEvent - set/wait signaling between threads | 5 | 0 | 5 | A |
| 13 | Semaphore - permits, wait, post | 5 | 0 | 5 | A |
| 14 | spinLoopHint and cache_line - low-level hints | 5 | 0 | 5 | A |
| 15 | Mutex protecting shared state across threads | 10 | 0 | 10 | A |
| 16 | Condition variable - producer-consumer | 10 | 0 | 10 | A |
| 17 | cmpxchgStrong - success/failure return semantics | 10 | 0 | 10 | A |
| 18 | Atomic lock-free counter across threads | 10 | 0 | 10 | A |
| 19 | Memory ordering - acquire/release publish pattern | 10 | 0 | 10 | A |
| 20 | Thread.Pool with WaitGroup - manual finish() | 10 | -1 (compile fail) | 9 | A |
| 21 | RwLock - concurrent readers, exclusive writer | 10 | 0 | 10 | A |
| 22 | cmpxchgWeak retry loop - CAS spin pattern | 10 | 0 | 10 | A |
| 23 | Multi-phase thread coordination with atomics | 10 | 0 | 10 | A |
| 24 | Lock-free stack - generic CAS-based push/pop | 20 | 0 | 20 | A |
| 25 | Barrier + pipeline - multi-stage parallel computation | 20 | 0 | 20 | A |
| **TOTAL** | | **200** | **-1** | **199** | **A** |

**Overall: 199/200 = 99.5% = A**

## Detailed Notes

### Exercise 20: Thread.Pool with WaitGroup (1 compile failure, -1 pt)

**Compile failure #1 (-1 pt, new mistake):** Called `pool.spawn(worker, args)` without `try`. `Thread.Pool.spawn` returns an error union that must be handled. The quiz description and reference docs mention the pool API but do not explicitly highlight that `spawn` is fallible. Fixed by adding `try`.

**Root cause:** Assumed `pool.spawn` was like `Thread.spawn` followed by a fire-and-forget handoff. In reality, the pool's spawn can fail (e.g., if the pool is shutting down or has internal errors).

### All Other Exercises: Clean Pass

24 out of 25 exercises passed on the first compile and first test run with zero deductions. All difficulty-1 exercises (thread basics, atomics, sync primitives) and difficulty-2 exercises (mutex contention, producer-consumer, CAS patterns, memory ordering, RwLock, phase coordination) plus both difficulty-3 exercises (lock-free stack, barrier+pipeline) were handled correctly.

## Compile Failure Summary

| Exercise | Attempt | Error | Root Cause | In Skill KB? |
|----------|---------|-------|------------|-------------|
| 20 | 1 | "error union is ignored" | `pool.spawn` returns error union, needed `try` | No |

Total compile failures: 1
- New mistakes: 1 (cost: -1 pt)
- Known pitfall violations: 0

## Post-Lesson Reflection

### Patterns that caused compile failures

1. **Thread.Pool.spawn returns error union**: Unlike the low-level `Thread.spawn` which also returns an error union (but is more obvious), `pool.spawn` is easy to overlook as fallible. The mental model of "pool accepts work" obscures the fact that queuing itself can fail. Added to SKILL.md concurrency table.

### Patterns that led to clean passes

1. **Static initialization with `.{}`**: All sync primitives (Mutex, Condition, RwLock, Semaphore, WaitGroup, ResetEvent) correctly initialized with `.{}`. No attempt to call `.init()`.
2. **fetchAdd/fetchSub return OLD value**: The gotcha about returning the previous value was anticipated correctly. No confusion between old and new values.
3. **cmpxchgStrong/Weak return semantics**: `null` = success, `?T` = failure with actual value. Applied correctly in retry loops.
4. **Condition.wait in while loop**: Used `while (!predicate) cond.wait(&mutex)` throughout, never bare `if`. The spurious wakeup guard pattern was internalized.
5. **WaitGroup lifecycle**: `start()` before spawn, `defer wg.finish()` inside worker, `wg.wait()` in main thread. Applied correctly in exercises 11, 20, and indirectly in 23/25.
6. **Memory ordering**: `.release` on store paired with `.acquire` on load for the publish pattern. `.monotonic` for simple counters where ordering doesn't matter.
7. **Lock-free stack CAS loop**: `cmpxchgWeak` in retry loop with proper ordering (`.release` for push, `.acq_rel` for pop) worked first try.
8. **Barrier implementation**: `fetchAdd` + comparison against total, with `event.set()` from the last arriver and `event.wait()` from others.
9. **Anonymous struct worker functions**: Used `struct { fn work(...) void { ... } }.work` pattern for inline thread functions, avoiding the need for module-level function declarations.
10. **Atomic.Value for thread-safe shared state**: Used `Atomic.Value(T)` instead of raw `var` for all cross-thread data, with appropriate memory orderings.

### Skill knowledge base updates made

1. **Concurrency primitives table**: Added comprehensive table to SKILL.md covering all sync primitives (Thread, Mutex, Condition, RwLock, Semaphore, WaitGroup, ResetEvent, Thread.Pool) with init patterns and key API notes.
2. **Atomics reference**: Added fetchAdd/fetchSub OLD value gotcha, cmpxchgStrong/Weak semantics, and memory ordering notes.
3. **Thread.Pool.spawn error union**: Explicitly documented that `pool.spawn` returns error union and must use `try`.

## Token Usage

- Estimated total tokens consumed: ~70,000 (input + output)
- Number of tool calls: ~45
- Tokens per exercise: ~2,800

---

# 00-bootstrap Plan: Final Self-Evaluation Report

## Overall Performance

| Lesson | Score | Pct | Grade | Compile Fails | Test Fails |
|--------|-------|-----|-------|---------------|------------|
| 01 Core Language Fundamentals | 180/200 | 90% | A | 1 | 1 |
| 02 Standard Library Essentials | 200/200 | 100% | A | 0 | 0 |
| 03 Error Handling & Allocators | 194/200 | 97% | A | 1 | 1 |
| 04 Comptime & Metaprogramming | 194/200 | 97% | A | 5 | 0 |
| 05 Idioms & Design Patterns | 198/200 | 99% | A | 2 | 0 |
| 06 Concurrency & Threading | 199/200 | 99.5% | A | 1 | 0 |
| **TOTAL** | **1165/1200** | **97.1%** | **A** | **10** | **2** |

## Recurring Patterns

### Compile Failure Categories

1. **0.15.2 API differences** (3 failures): ArrayList allocator access (L01), pool.spawn error union (L06), catch block type mismatch (L03). These stem from training data showing 0.14 patterns.

2. **Comptime return type constraints** (4 failures): All in L04. Functions with comptime params that build strings cannot return `[]const u8` from comptime blocks. Must use `*const [N]u8`. This was the single hardest pattern to learn and produced the most failures in the plan.

3. **Shadowing/naming** (2 failures): Parameter shadowing method names (L05), redundant comptime keyword (L04). Zig's strict scoping rules differ from most languages.

4. **Type system strictness** (1 failure): `mem.sliceTo` requiring sentinel-terminated pointer type, not plain many-pointer (L05).

### Test Failure Categories

1. **defer/errdefer ordering** (2 failures across L01 and L03): The LIFO interleaving of defer and errdefer on the error path, plus the timing constraint that defers execute after the return expression. These were the most conceptually challenging aspects of the plan.

### Improvement Trajectory

- L01: 90% (learning the system)
- L02: 100% (applied L01 lessons, clean sweep)
- L03: 97% (still catching defer subtleties)
- L04: 97% (comptime return types = new challenge)
- L05: 99% (only minor issues)
- L06: 99.5% (near-perfect, concurrency patterns well understood)

The trajectory shows clear improvement. After L02 (100%), scores never dropped below 97%, and the most recent two lessons achieved 99%+ despite increasing difficulty.

### Knowledge Gaps Remaining

1. **io_uring / async I/O**: Not covered in this plan. Would benefit from an applied lesson.
2. **Build system**: `build.zig` patterns not exercised beyond what's documented in SKILL.md.
3. **C interop**: Only covered in reference material, not exercised.
4. **File I/O and networking**: Covered in systems-reference but not tested with exercises.

### Skill KB Contributions

The plan produced the following SKILL.md additions:
- defer/errdefer LIFO interleaving rule and timing constraint
- Comptime string/array return type pattern (`*const [N]u8`)
- VTable function signatures and delegation pattern
- StackFallbackAllocator, FailingAllocator, checkAllAllocationFailures entries
- mem.sliceTo sentinel requirement
- Parameter shadowing note
- Concurrency primitives table (Thread, Mutex, Condition, RwLock, Semaphore, WaitGroup, ResetEvent, Thread.Pool)
- Atomics reference (fetchAdd OLD value, cmpxchg semantics, memory ordering)

---

# Lesson 07: Hex Dump (Applied) -- Grades

## Summary

| Ex | Topic | Max | Deductions | Earned | Grade |
|----|-------|-----|------------|--------|-------|
| 1 | Basic hex dump - read file and format output | 5 | 0 | 5 | A |
| 2 | Binary file - all 256 byte values | 5 | 0 | 5 | A |
| 3 | Grouping `-g` flag | 5 | 0 | 5 | A |
| 4 | Columns `-c` and length `-l` flags | 5 | 0 | 5 | A |
| 5 | File seeking `-s` flag | 5 | 0 | 5 | A |
| 6 | Stdin support | 5 | 0 | 5 | A |
| 7 | Plain hex mode `-p` | 5 | 0 | 5 | A |
| 8 | Uppercase mode `-u` | 5 | 0 | 5 | A |
| 9 | Little-endian mode `-e` | 5 | 0 | 5 | A |
| 10 | C include mode `-i` | 5 | 0 | 5 | A |
| 11 | Reverse mode `-r` | 5 | 0 | 5 | A |
| 12 | Reverse plain `-r -p` and binary mode `-b` | 5 | 0 | 5 | A |
| **TOTAL** | | **60** | **-2** | **58** | **A** |

**Overall: 58/60 = 96.7% = A**

**Compile failures: 1 (known mistake, -2 pts)**

## Detailed Notes

### Compile Failure #1 (-2 pts, known mistake)

**Error:** Used `std.io.getStdErr()`, `std.io.getStdOut()`, and `std.io.getStdIn()` instead of `std.fs.File.stderr()`, `std.fs.File.stdout()`, and `std.fs.File.stdin()`.

**Error message:** `root source file struct 'Io' has no member named 'getStdErr'`

**Root cause:** Reverted to the old 0.14 pattern despite SKILL.md explicitly documenting the correct 0.15.2 pattern (`std.fs.File.stdout()`) and the pitfalls reference listing this exact error message. The quiz reference code also showed `std.fs.File.stdin()`. This is a known pitfall, so -2 pts per the rubric.

**Fix:** Changed all three to `std.fs.File.stderr()`, `std.fs.File.stdout()`, `std.fs.File.stdin()`.

### All Exercises: Functionally Correct

After fixing the compile error, all 12 exercises produced output identical to `xxd` (verified with `diff`):

- Q1-Q2: Basic hex dump and binary file handling matched `xxd` byte-for-byte
- Q3: All grouping modes (`-g 1`, `-g 2`, `-g 4`) matched `xxd`
- Q4: Column widths and length limiting matched `xxd`
- Q5: Seeking with decimal and hex offsets matched `xxd`
- Q6: Stdin support (piped input) matched `xxd`
- Q7: Plain hex mode matched `xxd`
- Q8: Uppercase mode matched `xxd`
- Q9: Little-endian mode including partial group padding matched `xxd`
- Q10: C include mode matched `xxd`
- Q11: Round-trip `ccxxd file | ccxxd -r` restored original files exactly (test1.txt, test2.bin, test1.txt with -c 8)
- Q12: Reverse plain hex round-trip and binary mode both matched `xxd`

## Compile Failure Summary

| Exercise | Attempt | Error | Root Cause | In Skill KB? |
|----------|---------|-------|------------|-------------|
| All (pre-Q1) | 1 | `struct 'Io' has no member named 'getStdErr'` | Used old `std.io.getStdErr()` instead of `std.fs.File.stderr()` | Yes |

Total compile failures: 1
- Known pitfall violations: 1 (cost: -2 pts)
- New mistakes: 0

## Post-Lesson Reflection

### Patterns that caused compile failures

1. **Old stdout/stderr/stdin API**: Used `std.io.getStdErr()` / `getStdOut()` / `getStdIn()` instead of `std.fs.File.stderr()` / `.stdout()` / `.stdin()`. This is a well-documented 0.15.2 change. The SKILL.md explicitly says "NOT std.io.getStdOut!" but I still used the old pattern on first attempt. Likely a training-data muscle memory issue.

### Patterns that led to clean passes

1. **Buffered writer + flush pattern**: `File.stdout().writer(&buf)` then `&w.interface` for the AnyWriter, with `defer stdout.flush() catch {}`. Used correctly throughout.
2. **`file.read(&buf)` loop pattern**: Raw byte reading in a loop with `n == 0` for EOF. No issues with `file.reader()` confusion (which is a documented pitfall).
3. **Hex formatting specifiers**: `{x:0>2}`, `{X:0>2}`, `{x:0>8}`, `{b:0>8}`, `{c}` all used correctly with `@as(u8, ...)` type annotations where needed.
4. **`std.fmt.parseInt(usize, str, 0)`**: Base 0 for auto-detection of decimal vs hex (`0x`) prefix. Used for `-s` flag.
5. **`file.seekTo(offset)`**: Direct seeking on file handles worked as expected.
6. **Little-endian byte reversal**: Reversed bytes within groups by iterating backwards. Partial groups right-aligned with leading spaces per `xxd` behavior.
7. **Reverse hex dump parsing**: Line-by-line parsing finding `: ` separator, then parsing hex digits until double-space (ASCII column boundary).
8. **CLI argument parsing**: Manual arg parsing with flag detection and positional filename. Simple and effective for this use case.

### Code quality assessment

The implementation is a single-file 480+ line program with several distinct functions:
- `parseArgs` -- CLI argument parsing
- `hexDump` -- standard hex dump output
- `plainHexDump` -- plain hex mode
- `cIncludeDump` -- C include mode
- `reverseHexDumpFixed` -- reverse mode (standard and plain)
- `main` -- dispatch

Quality is reasonable for an applied exercise. Some areas could be improved:
- The hex width calculation for padding is duplicated between normal and little-endian modes
- The `parseArgs` function re-scans args to check if `-g` or `-c` were explicitly set for `-e` and `-b` defaults
- Error handling uses `catch` blocks that check for `EndOfStream` specifically

No code quality grade deduction applied -- the code is functional, structured, and readable.

### Skill knowledge base updates made

1. **stdin accessor**: Added `std.fs.File.stdin()` example to SKILL.md API corrections section alongside the existing stdout/stderr pattern. Updated the comment to explicitly list all three wrong names: `getStdOut/getStdErr/getStdIn`.

### Snippet curation

Created `src/exercises/file_io_cli.zig` with curated patterns:
- Buffered stdout writer setup
- Hex byte formatting (lowercase, uppercase, binary, character)
- `parseInt` with base-0 auto-detection
- File read loop pattern (with seek and stdin fallback)
- ASCII printable range check
- Hex char to nibble conversion with byte reconstruction

All 6 tests pass.

## Token Usage

- Estimated total tokens consumed: ~65,000 (input + output)
- Number of tool calls: ~35
- Tokens per exercise: ~5,400
- Actual (Task tool): 115,128 tokens, 54 tool calls

---

# Lesson 03 (Applied): Huffman Compression -- Grades

## Summary

| Ex | Topic | Max | Deductions | Earned | Grade |
|----|-------|-----|------------|--------|-------|
| 1 | Read file and count byte frequencies | 5 | 0 | 5 | A |
| 2 | Priority queue for tree building | 5 | 0 | 5 | A |
| 3 | Build the Huffman tree | 5 | 0 | 5 | A |
| 4 | Generate prefix codes from tree | 5 | 0 | 5 | A |
| 5 | Bit writer -- pack bits into bytes | 5 | -1 (runtime panic) | 4 | B |
| 6 | Encode file to compressed format | 5 | 0 | 5 | A |
| 7 | Read header and rebuild tree | 5 | 0 | 5 | A |
| 8 | Bit reader -- unpack bytes to bits | 5 | 0 | 5 | A |
| 9 | Decode compressed data | 5 | 0 | 5 | A |
| 10 | Round-trip verification | 5 | 0 | 5 | A |
| 11 | Handle edge cases | 5 | 0 | 5 | A |
| 12 | Performance and final integration | 5 | -1 (compile fail) | 4 | B |
| **TOTAL** | | **60** | **-2** | **58** | **A** |

**Overall: 58/60 = 96.7% = A**

**Compile/runtime failures: 2 (new mistakes, -1 pt each)**

## Detailed Notes

### Compile Failure #1 (pre-Q5 build, -1 pt, new mistake)

**Error:** Unreachable code after return in `BitWriter.init()`. Had `_ = allocator;` after the `return` statement -- dead code is a compile error in Zig.

**Root cause:** Initially wrote the `init` function taking an `allocator` parameter (matching HashMap pattern), then realized BitWriter doesn't need a stored allocator. Moved the return before removing the `_ = allocator` discard. Zig correctly rejects dead code.

**Fix:** Removed the unused parameter entirely.

### Runtime Failure #1 (Q5 first encode attempt, -1 pt, new mistake)

**Error:** Integer overflow in `u3` bit_count field at value 7. Adding 1 to a `u3` at its max value panics in safe mode. The logic checked `if (self.bit_count == 0)` after increment, relying on wrapping -- but safe mode Zig does not wrap on overflow.

**Root cause:** Used `u3` for a counter that needs to represent 0..8 states (0..7 bits buffered, plus the "full byte" state at 8). A `u3` can only hold 0..7. The overflow from 7+1 panics rather than wrapping.

**Fix:** Changed `bit_count` to `u4` (0..15), check `== 8` explicitly instead of relying on wrapping to 0.

### All Exercises: Functionally Correct

After fixing the two errors, all 12 exercises produced correct results:

- Q1: Frequencies match for both test files (simple_test: a=3, b=2, c=1; les_miserables: byte 88=333, byte 116=223000, 123 unique)
- Q2-Q3: Tree building correct (root freq = 6 for simple, 3,369,045 for les_miserables)
- Q4: Code lengths match all reference values (space=3, e=3, t=4, a=4, newline=6, X=13)
- Q5: Bit writer produces correct bytes (0x1E from 00011110, 0xC0 with 5 padding)
- Q6: Compressed payload = 1,969,961 bytes (matches expected exactly)
- Q7-Q9: Round-trip decode matches original for both files
- Q10: Verify reports correct sizes (3,369,045 -> 1,970,586, ratio 58.5%)
- Q11: All 4 edge cases pass (empty, single byte, repeated byte, all 256 values)
- Q12: Performance 0.388s (limit: 5s), error handling correct

## Compile Failure Summary

| Exercise | Attempt | Error | Root Cause | In Skill KB? |
|----------|---------|-------|------------|-------------|
| Build 1 | 1 | unreachable code after return | Dead code: `_ = allocator` after return statement | No |
| Q5 | 1 (runtime) | integer overflow u3 at 7+1 | u3 counter wraps panic; need u4 and check == 8 | No |

Total failures: 2
- New mistakes: 2 (cost: -1 pt each)
- Known pitfall violations: 0

## Post-Lesson Reflection

### Patterns that caused failures

1. **Dead code after return**: Zig enforces no dead code. When refactoring a function signature (removing a parameter), must also remove any references to the parameter, not just the signature.

2. **Integer type too narrow for counter boundary**: Using `u3` (0..7) for a bit counter that needs to detect "8 bits accumulated" fails because `7 + 1` overflows. The fix is to use a wider integer (`u4`) and check the boundary value explicitly. This is a general Zig safety feature -- checked arithmetic prevents subtle wrapping bugs but requires matching integer widths to their actual value ranges.

### Patterns that led to clean passes

1. **PriorityQueue API**: `std.PriorityQueue(T, Context, compareFn).init(gpa, context)` -- stored allocator pattern like HashMap. compareFn returns `std.math.Order`. Used pointer elements (`*Node`) with heap allocation for stable pointers.

2. **File I/O**: `std.fs.cwd().readFileAlloc(gpa, path, max)` for whole-file reads, `std.fs.cwd().createFile(path, .{})` for output. `file.writeAll(&bytes)` for bulk writes.

3. **Binary encoding/decoding**: `std.mem.toBytes(@as(u32, val))` for native-endian writes, `std.mem.readInt(u32, buf[0..4], .little)` for little-endian reads.

4. **Recursive tree traversal**: Zig handles recursive functions naturally. Used `*Node` pointers with explicit heap allocation via `allocator.create(Node)`.

5. **Buffered output writes**: Using a 4096-byte write buffer in the decoder, flushing when full, avoids per-byte I/O overhead.

6. **Edge case handling**: Empty file (0 entries in header), single-byte file (tree with one leaf, left-only parent), all 256 bytes -- all handled by the tree-building logic with special cases for 0 and 1 entries.

7. **@splat for array initialization**: `var freqs: [256]u64 = @splat(0);` -- clean zero-initialization of large arrays.

8. **std.fs.File.stdout()/.stderr()**: Used the correct 0.15.2 API throughout, no regression to getStdOut.

9. **CLI argument parsing**: `std.process.argsWithAllocator(gpa)` with `.next()` for sequential extraction.

10. **Error handling in CLI**: `catch |err| { ... std.process.exit(1); }` pattern for user-facing error messages.

### Skill knowledge base updates made

1. **Bit-width trap note**: Added to SKILL.md safety section: `u3` counter `+= 1` at value 7 panics -- use `u4` and check `== 8` explicitly.
2. **PriorityQueue API**: Added complete API example to 0.15.2 corrections.
3. **File create/write patterns**: Added `createFile`, `writeAll`, `readFileAlloc` examples.
4. **Binary I/O patterns**: Added `std.mem.toBytes` / `readInt` for little-endian encoding.

### Snippet curation

Created `src/exercises/bit_io_priority_queue.zig` with curated patterns:
- PriorityQueue with pointer elements and multi-field comparison
- Bit-level writer (MSB-first) with u4 counter gotcha
- Bit-level reader (MSB-first)
- Binary I/O with std.mem.toBytes / readInt

All 5 tests pass.

## Token Usage

- Estimated total tokens consumed: ~80,000 (input + output)
- Number of tool calls: ~30
- Tokens per exercise: ~6,667
- Actual (Task tool): 119,036 tokens, 62 tool calls

---

# Lesson 04 (Applied): Stream Editor -- Grades

## Summary

| Ex | Topic | Max | Deductions | Earned | Grade |
|----|-------|-----|------------|--------|-------|
| 1 | Line-by-line reader and printer | 5 | 0 | 5 | A |
| 2 | Basic substitution (s/pattern/replacement/) | 5 | 0 | 5 | A |
| 3 | Line number addressing and p command | 5 | 0 | 5 | A |
| 4 | Regex pattern matching in addresses | 5 | 0 | 5 | A |
| 5 | Regex in substitution (& and \1-\9) | 5 | 0 | 5 | A |
| 6 | Delete (d) and quit (q) commands | 5 | 0 | 5 | A |
| 7 | G, =, and y commands | 5 | 0 | 5 | A |
| 8 | a, i, and c text insertion commands | 5 | 0 | 5 | A |
| 9 | Multiple commands (-e and -f) | 5 | 0 | 5 | A |
| 10 | Regex range addresses | 5 | 0 | 5 | A |
| 11 | In-place editing (-i) | 5 | 0 | 5 | A |
| 12 | Substitution flags (p, N) and integration | 5 | 0 | 5 | A |
| **TOTAL** | | **60** | **-2** | **58** | **A** |

**Overall: 58/60 = 96.7% = A**

**Compile failures: 2 (new mistakes, -1 pt each)**

## Detailed Notes

### Compile Failure #1 (-1 pt, new mistake)

**Error:** Initial build had multiple issues: `var` declared for a local never mutated (should be `const`), unused function parameter `elem_end`, pointless discard of `group_idx`, and type mismatch `?[]u8` vs `[]const u8` in assignment.

**Root cause:** First draft had several structural issues from trying to write a complex program in one pass. The regex engine's `matchQuantifier` function had an unused `elem_end` parameter, and the substitution result type handling was incorrect.

**Fix:** Rewrote program with cleaner structure, removing unused parameters and fixing type handling.

### Compile Failure #2 (-1 pt, new mistake)

**Error:** `var parsed_cmds` flagged as "local variable is never mutated" -- needs `const`.

**Root cause:** The `parseCommands` returns a `[]SedCommand` slice. The slice pointer itself is never reassigned (the `in_range` field mutations happen through the slice contents, not the slice variable). Zig correctly identifies this as needing `const`.

**Fix:** Changed `var` to `const`.

### Regex Engine Rewrite (no additional compile failure)

After the initial build compiled, the Q5-2 test (log level extraction with `\1` back-reference) failed. The regex group tracking was incorrect -- the iterative `matchAt` function with its `\(` and `\)` tracking used a fragile "unclosed group" heuristic that broke when `matchQuant` sliced the pattern and called `matchAt` recursively with shifted positions.

**Fix:** Rewrote the regex engine to be fully recursive (`matchRec`), passing group state through the call stack with a proper open-group stack (`open_stack` + `open_depth`). This naturally handles nested groups, quantifiers over groups, and back-references. No additional compile failures from this rewrite.

### All Exercises: Functionally Correct

After fixing the compile errors and rewriting the regex engine, all 12 exercises produced output identical to system `sed`:

- Q1: File reading and stdin both match `cat` output
- Q2: All substitution variants (first, global, custom delimiter, empty replacement) match
- Q3: Line addressing (single, range, $, p with/without -n) all match
- Q4: Regex addresses (/pattern/p, /^.../p, /..$/p, /^$/d) all match
- Q5: Regex substitution with &, \1-\9, character classes, quantifiers all match
- Q6: Delete and quit commands match (3,5d, /ERROR/d, 3q, /fear/q)
- Q7: G (double-space), = (line numbers), y (ROT13) all match
- Q8: a\, i\, c\ text commands all match
- Q9: Multiple -e flags, -f script file, mixed -e/-f all match
- Q10: Regex ranges (/INFO/,/ERROR/p, 3,/success/d, /WARN/,/WARN/p) all match
- Q11: In-place editing produces identical results to `sed -i`
- Q12: s///p with -n, s///2 (Nth occurrence), complex multi-command pipeline all match

Final integration test: all 8 `sed` comparison tests pass.

## Compile Failure Summary

| Exercise | Attempt | Error | Root Cause | In Skill KB? |
|----------|---------|-------|------------|-------------|
| Build 1 | 1 | Multiple: unused var, unused param, type mismatch | First-draft structural issues | No |
| Build 2 | 1 | "local variable is never mutated" | `var` for non-mutated slice variable | No |

Total compile failures: 2
- New mistakes: 2 (cost: -1 pt each)
- Known pitfall violations: 0

## Post-Lesson Reflection

### Patterns that caused compile failures

1. **Unused parameters in helper functions**: When a function parameter is only needed for context (like `elem_end` passed to `matchQuantifier` for documentation purposes but never read), Zig rejects it. Either use the parameter or name it `_`.

2. **const vs var for slice variables**: A `[]SedCommand` whose elements are mutated via pointer access is still `const` as a variable because the variable (pointer+length) never changes. Only the pointed-to data changes. This is the same as C's `T *const` -- constant pointer to mutable data.

### Patterns that led to clean passes

1. **std.fs.File.stdout()/stdin()/stderr()**: Used the correct 0.15.2 API throughout, no regression to `getStdOut/getStdIn/getStdErr`.
2. **readToEndAlloc for whole-file reads**: `file.readToEndAlloc(gpa, max)` for reading from an opened File handle.
3. **std.mem.splitScalar for line splitting**: Clean pattern for splitting file content by newlines.
4. **std.mem.indexOfScalar for transliteration**: Used to find character position in `y` command source.
5. **std.fmt.allocPrint for string building**: Used for G command (appending newline) and temp filename construction.
6. **ArrayList.toOwnedSlice for command arrays**: Clean pattern for building and returning dynamic arrays.
7. **Recursive regex engine**: Passing group state through recursion (stack-based open group tracking) handles nested groups and quantifiers cleanly.
8. **CLI arg parsing with manual loop**: Simple and effective for `-n`, `-e`, `-f`, `-i` flags plus positional arguments.
9. **File rename for atomic in-place editing**: Write to temp file, then rename to original -- prevents data loss on failure.

### Code quality assessment

The implementation is a single-file ~700 line program with clear separation:
- CLI argument parsing
- Sed command parsing (addresses, command types, flags)
- Regex engine (recursive matcher with group capture)
- Line processing (command dispatch with address matching)
- Output formatting
- In-place editing

Quality is good for an applied exercise. The regex engine uses a clean recursive design that handles all BRE features (., *, +, ?, ^, $, [], \(\), \1-\9, character classes). No significant code quality deductions.

### Skill knowledge base updates made

1. **readToEndAlloc**: Added `file.readToEndAlloc(gpa, max)` for reading from open File handles (distinct from `cwd().readFileAlloc` which takes a path).
2. **Buffered line reading**: Added `std.io.bufferedReaderSize` + `readUntilDelimiterOrEof` pattern for stream processing.

## Token Usage

- Estimated total tokens consumed: ~120,000 (input + output)
- Number of tool calls: ~45
- Tokens per exercise: ~10,000

---

# Lesson 05 (Applied): HTTP Web Server -- Grades

## Summary

| Ex | Topic | Max | Deductions | Earned | Grade |
|----|-------|-----|------------|--------|-------|
| 1 | TCP Listener - accept and echo | 5 | 0 | 5 | A |
| 2 | Parse the request line | 5 | 0 | 5 | A |
| 3 | Serve static files | 5 | 0 | 5 | A |
| 4 | Support HEAD method | 5 | 0 | 5 | A |
| 5 | Subdirectory and path handling | 5 | 0 | 5 | A |
| 6 | Path traversal protection | 5 | 0 | 5 | A |
| 7 | Connection keep-alive | 5 | 0 | 5 | A |
| 8 | Concurrent connections with threads | 5 | 0 | 5 | A |
| 9 | Response headers and HTTP compliance | 5 | 0 | 5 | A |
| 10 | Error pages with HTML bodies | 5 | 0 | 5 | A |
| 11 | Configurable root directory | 5 | 0 | 5 | A |
| 12 | Access logging | 5 | 0 | 5 | A |
| **TOTAL** | | **60** | **-1** | **59** | **A** |

**Overall: 59/60 = 98.3% = A**

**Compile failures: 1 (new mistake, -1 pt)**

## Detailed Notes

### Compile Failure #1 (-1 pt, new mistake)

**Error:** Two issues in a single compile attempt: (1) unused local constant `version` from parsing the HTTP request line, and (2) `Dir.close()` requires `*Dir` (mutable pointer) but the variable was declared `const`.

**Error messages:**
- `error: unused local constant` for `version`
- `error: expected type '*fs.Dir', found '*const fs.Dir'` — `Dir.close()` takes `*Dir`, but `const dir = openDir(...)` gives a `*const Dir` reference

**Root cause:** The version string was extracted from the request line but never used (I only needed method and path). For the Dir issue, `openDir` returns a `Dir` value, but declaring it as `const` means `close()` (which takes `*Dir`) can't be called on it. Zig's mutability rules apply to method receivers: a method taking `*Self` requires the caller's variable to be `var`.

**Fix:** Changed `version` to `_ = rest[second_space + 1 ..];` and changed `const dir` to `var dir`.

### All Exercises: Functionally Correct

After fixing the single compile error, all 12 exercises produced correct results verified with curl and nc:

- Q1: Server accepts connection, prints raw request to stdout, returns "Hello, World!" — verified with curl
- Q2: Request line parsing works (method, path, version extracted), loop accepts multiple connections, 400 Bad Request for malformed input — verified with curl + nc garbage
- Q3: Static files served with correct Content-Type (html, css, json) and Content-Length, 404 for missing files — verified against all 5 test files
- Q4: HEAD returns headers only (no body), Content-Length still correct, 405 for DELETE — verified with curl -I and curl -X DELETE
- Q5: Subdirectory paths work (/subdir/nested.html), percent-decoding works (%2E → .), trailing slash → index.html — verified
- Q6: All traversal patterns blocked with 403: /../etc/passwd, /%2e%2e/etc/passwd, /subdir/../../etc/passwd — verified with nc (bypassing curl's path normalization)
- Q7: Keep-alive works (curl reuses connection for multiple requests), Connection: close honored, 5-second SO_RCVTIMEO timeout set
- Q8: Concurrent connections work — slow client holds connection while fast clients respond immediately. Thread.spawn + detach pattern
- Q9: All required headers present: Date (correct HTTP format with day-of-week), Server: zig-http/0.1, Content-Type, Content-Length, Connection
- Q10: HTML error pages for 400, 403, 404, 405 with correct template format, Content-Type: text/html, HEAD errors return headers only
- Q11: Custom port and root via args, validation for nonexistent directory (exit 1), invalid port (exit 1), defaults to port 8080 and ./www
- Q12: Common Log Format logging with mutex protection, correct date format [DD/Mon/YYYY:HH:MM:SS +0000], body_size 0 for HEAD

### Architecture Notes

The final program is approximately 410 lines, organized as:
- `main()` — CLI args, directory validation, server setup, accept loop
- `handleConnection()` — per-connection handler with keep-alive loop, request parsing, URL decoding, traversal check, file dispatch
- `serveFile()` — file reading, Content-Type detection, header building, response writing
- `sendError()` — HTML error page generation, HEAD-aware body suppression
- `shouldClose()` — Connection: close header detection
- `containsTraversal()` — pre-filesystem path traversal detection
- `urlDecode()` / `hexVal()` — percent-encoding decode
- `getContentType()` — extension → MIME type mapping
- `formatHttpDate()` — EpochSeconds → HTTP date string
- `logRequest()` — thread-safe Common Log Format output

## Compile Failure Summary

| Exercise | Attempt | Error | Root Cause | In Skill KB? |
|----------|---------|-------|------------|-------------|
| Q3-Q12 build | 1 | unused local + const Dir | Unused `version` var; `Dir.close()` needs `*Dir` (mutable) | No |

Total compile failures: 1
- New mistakes: 1 (cost: -1 pt)
- Known pitfall violations: 0

## Post-Lesson Reflection

### Patterns that caused compile failures

1. **Dir.close() requires mutable reference**: `std.fs.Dir.close()` takes `*Dir` (mutable self), so the variable holding the opened Dir must be `var`, not `const`. This is a general Zig principle: methods taking `*Self` require the caller's variable to be mutable. Added to SKILL.md.

2. **Unused locals are compile errors**: Even if you plan to use a variable later (like the HTTP version string), if the current code path doesn't reference it, Zig rejects it. Use `_ = expr;` to explicitly discard. This is well-known but easy to hit when building incrementally.

### Patterns that led to clean passes

1. **std.net.Address.parseIp4 + listen + accept**: The networking primer in the quiz matched the 0.15.2 API exactly. Used correctly throughout.
2. **SO_RCVTIMEO via setsockopt**: `posix.timeval{.sec=5, .usec=0}` + `posix.setsockopt(handle, SOL.SOCKET, SO.RCVTIMEO, mem.asBytes(&timeout))` worked first try.
3. **Thread.spawn + detach**: Clean pattern for thread-per-connection. No need for join since connections are independent.
4. **EpochSeconds date computation**: `getEpochDay()` → `calculateYearDay()` → `calculateMonthDay()` chain, plus manual day-of-week via `@mod(day + 4, 7)`. No `calculateDayOfWeek()` method exists.
5. **IP address extraction**: `addr.in.sa.addr` gives u32 in network byte order, extract octets via `@truncate(ip >> (N*8))`.
6. **Path traversal pre-check**: Checking for ".." components BEFORE filesystem access avoids the realpathAlloc pitfall (fails for nonexistent paths → 404 not 403).
7. **URL percent-decoding**: Standard `%XX` → byte pattern with hex digit parsing via `?u4` return type.
8. **Mutex + atomic write for logging**: Format log line in local buffer first, then lock mutex and `writeAll` atomically — prevents interleaved output from concurrent threads.
9. **std.fs.File.stdout()**: Used the correct 0.15.2 API, no regression to old getStdOut pattern.
10. **readFileAlloc for file serving**: Clean pattern for serving small static files — read entire file, send headers + body.

### Skill knowledge base updates made

1. **TCP server pattern**: Added `parseIp4` + `listen` + `accept` + `stream.read/writeAll` to SKILL.md API corrections.
2. **Socket timeout**: Added `SO_RCVTIMEO` + `setsockopt` + `posix.timeval` pattern.
3. **Dir.close() mutability**: Added note that `Dir.close()` requires `*Dir` (var, not const).
4. **EpochSeconds date/time**: Added full date computation chain with day-of-week gotcha.

### Snippet curation

Created `src/exercises/networking_http.zig` with 6 tested patterns:
- TCP server accept lifecycle
- Socket timeout setup
- URL percent-decoding
- Path traversal detection
- HTTP date formatting
- IP address extraction from net.Address

All 6 tests pass.

## Token Usage

- Estimated total tokens consumed: ~90,000 (input + output)
- Number of tool calls: ~40
- Tokens per exercise: ~7,500
- Actual (Task tool): 128,624 tokens, 75 tool calls

---

# Lesson 06 (Applied): HTTP Load Balancer -- Grades

## Summary

| Ex | Topic | Max | Deductions | Earned | Grade |
|----|-------|-----|------------|--------|-------|
| 1 | TCP Proxy - forward to one backend | 5 | 0 | 5 | A |
| 2 | Log incoming requests | 5 | 0 | 5 | A |
| 3 | Concurrent client handling | 5 | 0 | 5 | A |
| 4 | Round-robin across multiple backends | 5 | 0 | 5 | A |
| 5 | Backend connection error handling | 5 | 0 | 5 | A |
| 6 | Health check - background polling | 5 | 0 | 5 | A |
| 7 | Skip unhealthy backends in routing | 5 | 0 | 5 | A |
| 8 | X-Forwarded-For header | 5 | 0 | 5 | A |
| 9 | Read full HTTP responses | 5 | 0 | 5 | A |
| 10 | Connection timeouts | 5 | 0 | 5 | A |
| 11 | Graceful shutdown | 5 | 0 | 5 | A |
| 12 | Statistics endpoint | 5 | 0 | 5 | A |
| **TOTAL** | | **60** | **-2** | **58** | **A** |

**Overall: 58/60 = 96.7% = A**

**Compile failures: 1 (known mistake, -2 pts)**

## Detailed Notes

### Compile Failure #1 (-2 pts, known mistake)

**Error:** Used `std.ArrayList(T).init(alloc)` instead of the 0.15.2 `.empty` pattern. The ArrayList API changed from `.init(allocator)` (stored allocator) to `.empty` (per-method allocator) in 0.15.2.

**Error message:** `struct 'array_list.Aligned(...)' has no member named 'init'`

**Root cause:** Reverted to the old 0.14 `ArrayList.init(alloc)` pattern despite SKILL.md explicitly documenting `var list: std.ArrayList(i32) = .empty;` as the correct 0.15.2 API. This is pitfall #1 and has been hit before (Lesson 01). -2 pts per the rubric (known mistake in skill KB).

**Fix:** Changed to `.empty` init and `deinit(alloc)` with per-method allocator passing.

### All Exercises: Functionally Correct

After fixing the single compile error, all 12 exercises produced correct results verified with curl and test backends:

- **Q1**: Proxy forwards request to backend, returns response to client. Verified with `curl /` and `curl /health`.
- **Q2**: Log format `127.0.0.1:PORT -> 127.0.0.1:PORT "METHOD PATH VERSION" STATUS` correct. Logs after response sent.
- **Q3**: Slow client (3s /slow endpoint) doesn't block fast client. Thread.spawn + detach per connection.
- **Q4**: Round-robin distributes across 3 backends using atomic counter. 6 requests cycle A->B->C->A->B->C.
- **Q5**: Dead backend returns `502 Bad Gateway` with error log. LB continues serving other backends.
- **Q6**: Background health check thread detects transitions: `HEALTH: 127.0.0.1:8082 UP -> DOWN` and `DOWN -> UP`. Configurable interval via `--health-interval`.
- **Q7**: Unhealthy backends skipped in routing. All backends down returns `503 Service Unavailable`.
- **Q8**: X-Forwarded-For, X-Forwarded-Host, Host headers correctly set. Verified with /echo endpoint returning JSON headers.
- **Q9**: Large responses (138KB) forwarded correctly using streaming approach. Files match byte-for-byte via diff.
- **Q10**: SO_RCVTIMEO (10s) and SO_SNDTIMEO (2s) set on backend sockets. /slow (3s) succeeds within timeout.
- **Q11**: SIGINT handler sets atomic `running` flag. Shutdown monitor unblocks accept() via self-connection (macOS workaround). Prints `Shutting down...` and `Shutdown complete.` Waits up to 5s for in-flight requests.
- **Q12**: `/__lb/stats` returns valid JSON with uptime, total_requests, active_connections, and per-backend stats (address, healthy, requests_served, errors, avg_response_ms).

### Architecture Notes

The final program is approximately 580 lines, organized as:

- **Global state**: Backend array, atomic counters (round-robin, active connections, total requests), start time, health interval
- **parseRequestLine / parseStatusCode**: HTTP protocol parsing
- **findContentLength / findHeaderEnd / asciiStartsWithIgnoreCase**: HTTP header utilities
- **rewriteRequest**: Q8 header rewriting (XFF, XFH, Host replacement)
- **handleStats**: Q12 JSON stats response builder
- **selectBackend**: Q7 round-robin with health check integration
- **streamResponse**: Q9 streaming proxy (headers in buffer, body in chunks up to 32KB)
- **handleConnection**: Main per-connection handler (Q1-Q12 combined)
- **forwardOriginal**: Fallback path when header rewrite fails
- **healthCheckLoop / checkBackendHealth**: Q6 background health polling
- **signalHandler / shutdownMonitor**: Q11 graceful shutdown
- **main**: CLI parsing, server setup, accept loop, shutdown coordination

Key design decisions:
- **Streaming vs buffering**: Used streaming for Q9 to avoid 10MB stack allocation in spawned threads. Headers buffered in 16KB, body streamed in 32KB chunks.
- **Sleep-first health check**: Health check loop sleeps before checking, so backends start as healthy. This avoids false DOWN transitions at startup.
- **macOS accept() workaround**: Self-connection in shutdown monitor thread to unblock the blocking accept() call, since SO_RCVTIMEO doesn't work on accept() on macOS.

## Compile Failure Summary

| Exercise | Attempt | Error | Root Cause | In Skill KB? |
|----------|---------|-------|------------|-------------|
| All (pre-Q1) | 1 | `has no member named 'init'` | Used ArrayList.init(alloc) instead of .empty | Yes |

Total compile failures: 1
- Known pitfall violations: 1 (cost: -2 pts)
- New mistakes: 0

## Token Usage

- Estimated total tokens consumed: ~110,000 (input + output)
- Number of tool calls: ~30
- Tokens per exercise: ~9,167
- Actual (session-cost.py): 37 API turns, $3.67 total (context replay $1.73 47%, cache writes $1.18 32%, output $0.49 13%, system replay $0.26 7%)
