# Lesson 01: Core Language Fundamentals — Quiz

| # | Topic | Diff | Pts |
|---|-------|------|-----|
| 1 | Primitive types — integer sizes and signedness | 1 | 5 |
| 2 | Primitive types — floats, bool, void | 1 | 5 |
| 3 | Variables — const vs var semantics | 1 | 5 |
| 4 | Variables — undefined initialization | 1 | 5 |
| 5 | Control flow — if/else as expression | 1 | 5 |
| 6 | Control flow — switch exhaustiveness and ranges | 1 | 5 |
| 7 | Control flow — for loops with slices and ranges | 1 | 5 |
| 8 | Control flow — while with continue expression | 1 | 5 |
| 9 | Functions — basic parameters and return types | 1 | 5 |
| 10 | Errors — error sets and try/catch | 1 | 5 |
| 11 | Optionals — ?T, orelse, if-unwrap | 1 | 5 |
| 12 | Tagged unions — definition and switch dispatch | 1 | 5 |
| 13 | Slices and arrays — basics, len, ptr | 1 | 5 |
| 14 | Defer — basic ordering (LIFO) | 1 | 5 |
| 15 | Comptime — comptime blocks and parameters | 2 | 10 |
| 16 | Comptime — @typeInfo and @typeName | 2 | 10 |
| 17 | Control flow — labeled blocks and breaks | 2 | 10 |
| 18 | Functions — error unions as returns and function ptrs | 2 | 10 |
| 19 | Errors — errdefer only runs on error path | 2 | 10 |
| 20 | Tagged unions — methods and void members | 2 | 10 |
| 21 | Slices — sentinel-terminated and multi-dimensional | 2 | 10 |
| 22 | Packed structs — @bitSizeOf vs @sizeOf | 2 | 10 |
| 23 | Peer type resolution in if/switch expressions | 3 | 20 |
| 24 | Casting and coercion — @intCast, @truncate, conversions | 3 | 20 |
| 25 | Defer + errdefer interactions in loops and nesting | 2 | 10 |
| **TOTAL** | | | **200** |

## Exercise 1: Primitive types — integer sizes and signedness (5pts)
Verify bit widths via @typeInfo(.int.bits), signedness, and max/min values using std.math.maxInt/minInt. Show comptime_int arbitrary precision with 1 << 256.

## Exercise 2: Primitive types — floats, bool, void (5pts)
Verify @sizeOf for f16/f32/f64. Show bool is 1 byte, @intFromBool conversions. Show void has size 0.

## Exercise 3: Variables — const vs var semantics (5pts)
Demonstrate const immutability vs var mutability. Show const slice prevents element modification.

## Exercise 4: Variables — undefined initialization (5pts)
Use `undefined` for array initialization, write-before-read pattern. Show `**` array fill operator.

## Exercise 5: Control flow — if/else as expression (5pts)
Use if/else as an expression returning a value. Show ternary-style with string selection.

## Exercise 6: Control flow — switch exhaustiveness and ranges (5pts)
Switch on u8 with ranges (1...9, 10...99, etc). Switch on enum showing exhaustiveness requirement.

## Exercise 7: Control flow — for loops with slices and ranges (5pts)
Iterate over slice with index capture. Show range-based for (0..5).

## Exercise 8: Control flow — while with continue expression (5pts)
While loop with continue expression `(i += 1)`. While with optional unwrapping pattern.

## Exercise 9: Functions — basic parameters and return types (5pts)
Simple function calls. Function returning a struct.

## Exercise 10: Errors — error sets and try/catch (5pts)
Define error set, function returning error union. Use catch with payload, expectError.

## Exercise 11: Optionals — ?T, orelse, if-unwrap (5pts)
Optional declaration, orelse for defaults, if-unwrap pattern, .? unwrap-or-panic.

## Exercise 12: Tagged unions — definition and switch dispatch (5pts)
Define union(enum), switch dispatch with payload capture, convert between types.

## Exercise 13: Slices and arrays — basics, len, ptr (5pts)
Fixed array, slice from array, subslice, ptr field access. Modify via slice updates original.

## Exercise 14: Defer — basic LIFO ordering (5pts)
Multiple defers in same scope showing reverse (LIFO) execution order.

## Exercise 15: Comptime — comptime blocks and parameters (10pts)
Comptime block building lookup table. Comptime function parameter with `type`.

## Exercise 16: Comptime — @typeInfo and @typeName (10pts)
@typeName for type names. @typeInfo on integer, optional (child type), struct (fields with .@"struct").

## Exercise 17: Control flow — labeled blocks and breaks (10pts)
Labeled block returning value via break. Nested labeled loop with break :outer.

## Exercise 18: Functions — error unions as returns and function ptrs (10pts)
Error union return type. Function pointers, runtime function selection.

## Exercise 19: Errors — errdefer only runs on error path (10pts)
Demonstrate errdefer fires only on error return, not success. Use ArrayList to log behavior.

## Exercise 20: Tagged unions — methods and void members (10pts)
Methods on union using @This(). Void members. std.meta.activeTag / std.meta.Tag.

## Exercise 21: Slices — sentinel-terminated and multi-dimensional (10pts)
[:0]const u8 string literals, sentinel accessible past len. [_:0]u8 arrays. Multi-dimensional arrays.

## Exercise 22: Packed structs — @bitSizeOf vs @sizeOf (10pts)
Packed struct with bit fields. @bitSizeOf vs @sizeOf. @bitCast to backing integer.

## Exercise 23: Peer type resolution in if/switch expressions (20pts)
comptime_int + concrete => concrete. T and null => ?T. T and error => error!T. *[N]T to []T coercion. Enum switch.

## Exercise 24: Casting and coercion — @intCast, @truncate, conversions (20pts)
@as, @intCast, @truncate, @intFromFloat (truncation toward zero), @floatFromInt, @intFromBool, @intFromEnum/@enumFromInt, @floatCast, *[N]T to []T.

## Exercise 25: Defer + errdefer interactions in loops and nesting (10pts)
Defer in loop iterations. Nested scope defers (inner before outer). errdefer fires on error, not success.

---

# Lesson 02: Standard Library Essentials — Quiz

| # | Topic | Diff | Pts |
|---|-------|------|-----|
| 1 | ArrayList — .empty init, append, items slice | 1 | 5 |
| 2 | ArrayList — appendSlice and length verification | 1 | 5 |
| 3 | ArrayList — insert and orderedRemove | 1 | 5 |
| 4 | ArrayList — swapRemove and pop | 1 | 5 |
| 5 | ArrayList — clearRetainingCapacity preserves memory | 1 | 5 |
| 6 | ArrayList — ensureTotalCapacity pre-allocation | 2 | 10 |
| 7 | AutoHashMap — init, put, get, contains, count | 1 | 5 |
| 8 | AutoHashMap — getOrPut upsert pattern | 2 | 10 |
| 9 | AutoHashMap — remove, fetchRemove, iterator | 2 | 10 |
| 10 | StringHashMap — string keys | 1 | 5 |
| 11 | std.mem — eql, startsWith, endsWith | 1 | 5 |
| 12 | std.mem — indexOf and lastIndexOf | 1 | 5 |
| 13 | std.mem — trim, trimLeft, trimRight | 1 | 5 |
| 14 | std.mem — splitScalar and splitSequence | 2 | 10 |
| 15 | std.mem — tokenizeScalar vs splitScalar | 2 | 10 |
| 16 | std.mem — zeroes, asBytes, concat | 2 | 10 |
| 17 | std.fmt — bufPrint with {d} and {s} specifiers | 1 | 5 |
| 18 | std.fmt — allocPrint and comptimePrint | 2 | 10 |
| 19 | std.fmt — padding, hex, binary, float precision | 2 | 10 |
| 20 | std.sort — pdq ascending and descending | 1 | 5 |
| 21 | std.sort — custom comparator and isSorted | 2 | 10 |
| 22 | std.math — @min/@max builtins, clamp | 1 | 5 |
| 23 | std.math — isPowerOfTwo, log2_int, divCeil, maxInt | 1 | 5 |
| 24 | JSON — parseFromSlice into struct and dynamic Value | 3 | 20 |
| 25 | JSON — serialize with json.fmt, round-trip, parse options | 3 | 20 |
| | **TOTAL** | | **200** |

Difficulty distribution: 14x5=70 + 9x10=90 + 2x20=40 = 200

---

## Exercise 1: ArrayList — .empty init, append, items slice (5pts)

Create an `ArrayList(u32)` using the `.empty` initialization pattern (NOT `.init(allocator)`). Use `testing.allocator` and `defer` for cleanup. Append three values (10, 20, 30) to the list, passing the allocator to each `append` call. Verify the `.items` slice has length 3 and contains the expected values at each index.

**Key 0.15.2 concept:** ArrayList uses `.empty` init and takes allocator per-method. This is the opposite of HashMap.

---

## Exercise 2: ArrayList — appendSlice and length verification (5pts)

Create an `ArrayList(u8)`, use `appendSlice` to add the string `"hello"`, and verify the items match. Then `appendSlice` the string `" world"` and verify the combined items equal `"hello world"` with length 11.

**Key concept:** `appendSlice` takes an allocator and a slice, adding all elements at once.

---

## Exercise 3: ArrayList — insert and orderedRemove (5pts)

Create an `ArrayList(i32)` with initial elements `{1, 3, 4}` via `appendSlice`. Use `insert(gpa, 1, 2)` to insert value 2 at index 1, shifting elements right. Verify the list is `{1, 2, 3, 4}`. Then use `orderedRemove(2)` to remove the element at index 2, verify it returns the removed value (3), and verify the resulting list is `{1, 2, 4}`.

**Key concept:** `insert` takes allocator, index, value. `orderedRemove` preserves order and returns the removed element.

---

## Exercise 4: ArrayList — swapRemove and pop (5pts)

Create an `ArrayList(i32)` with elements `{10, 20, 30, 40}`. Use `swapRemove(1)` to remove index 1 — verify it returns 20, the length is 3, and index 1 now holds 40 (the former last element). Then use `pop()` to remove the last element — verify it returns 30 and the length is 2.

**Key concept:** `swapRemove` is O(1) but breaks order by replacing the removed element with the last. `pop` removes and returns the last element.

---

## Exercise 5: ArrayList — clearRetainingCapacity preserves memory (5pts)

Create an `ArrayList(i32)`, append 5 elements, record the capacity. Call `clearRetainingCapacity()` and verify the length is 0 but the capacity is unchanged from before the clear.

**Key concept:** `clearRetainingCapacity` resets length without freeing memory — useful for reusing a list in a loop.

---

## Exercise 6: ArrayList — ensureTotalCapacity pre-allocation (10pts)

Create an `ArrayList(u8)`, call `ensureTotalCapacity(gpa, 256)`, and verify capacity >= 256 while length is still 0. Record the capacity, then append 10 elements in a loop using `@intCast` for the index. Verify the capacity has NOT changed (no reallocation). Then sort the items in descending order using `std.sort.pdq` with `sort.desc(u8)` and verify the first and last elements.

**Key concept:** Pre-allocation avoids repeated reallocations. Combines ArrayList with sort.pdq.

---

## Exercise 7: AutoHashMap — init, put, get, contains, count (5pts)

Create an `AutoHashMap(u32, []const u8)` using `.init(gpa)` — note this is the opposite of ArrayList's `.empty` pattern. Put three key-value pairs. Verify `get(2)` returns the expected string via `.?` unwrap, `get(99)` returns null, `contains(1)` is true, `contains(42)` is false, and `count()` is 3.

**Key 0.15.2 concept:** HashMap stores the allocator at init; put/get do NOT take an allocator argument.

---

## Exercise 8: AutoHashMap — getOrPut upsert pattern (10pts)

Create an `AutoHashMap(u8, u32)`. Iterate over the string `"abracadabra"` and use `getOrPut` to count character frequencies. For each character: call `getOrPut(ch)`, check `found_existing` — if false, initialize `value_ptr.*` to 0 — then increment `value_ptr.*`. Verify: 'a' appears 5 times, 'b' appears 2, 'c' appears 1, 'd' appears 1, 'r' appears 2.

**Key concept:** `getOrPut` returns a struct with `.found_existing` (bool) and `.value_ptr` (*V). It avoids the double-lookup of separate get-then-put.

---

## Exercise 9: AutoHashMap — remove, fetchRemove, iterator (10pts)

Create an `AutoHashMap(u8, u8)` with three entries `{1:10, 2:20, 3:30}`. Use `remove(2)` and verify it returns true, then verify `get(2)` is null and `remove(99)` returns false. Re-add key 2. Then iterate all entries using `.iterator()` and `while (it.next())`, summing keys and values via `entry.key_ptr.*` and `entry.value_ptr.*`. Verify the sums are 6 and 60 respectively.

**Key concept:** `remove` returns bool. Iterator uses `key_ptr.*` / `value_ptr.*` pattern. Order is not guaranteed.

---

## Exercise 10: StringHashMap — string keys (5pts)

Create a `StringHashMap(i32)` using `.init(gpa)`. Put three string-keyed entries ("alpha":1, "beta":2, "gamma":3). Verify `get("beta")` returns 2, `contains("gamma")` is true, `contains("delta")` is false, and `count()` is 3.

**Key concept:** `StringHashMap` is a convenience type specialized for `[]const u8` keys.

---

## Exercise 11: mem.eql, startsWith, endsWith (5pts)

Demonstrate `std.mem.eql(u8, ...)` for equality comparison: equal strings return true, different content returns false, different lengths return false. Then demonstrate `startsWith` and `endsWith` with both matching and non-matching cases.

**Key concept:** Strings in Zig are `[]const u8`; use `mem.eql` for comparison (not `==`).

---

## Exercise 12: mem.indexOf and lastIndexOf (5pts)

Given the haystack `"abcabc"`, use `mem.indexOf` to find the first occurrence of `"abc"` (index 0), `mem.lastIndexOf` to find the last occurrence of `"abc"` (index 3), and verify that searching for `"xyz"` returns null.

**Key concept:** Both return `?usize` — null when not found.

---

## Exercise 13: mem.trim, trimLeft, trimRight (5pts)

Trim the string `"  hello  "` using `mem.trim(u8, ..., " ")` to get `"hello"`, `mem.trimLeft` to get `"hello  "`, and `mem.trimRight` to get `"  hello"`. Also demonstrate trimming a different character set: trim `"---hello---"` with `"-"` to get `"hello"`.

**Key concept:** `trim` takes a set of characters to strip, not a substring. It removes all leading/trailing characters that appear in the set.

---

## Exercise 14: mem.splitScalar and splitSequence (10pts)

Use `mem.splitScalar(u8, "a,b,,c", ',')` and iterate all results: expect "a", "b", "" (empty between consecutive delimiters), "c", then null. Then use `mem.splitSequence(u8, "one=>two=>three", "=>")` and iterate: expect "one", "two", "three", then null.

**Key 0.15.2 concept:** The functions are `splitScalar` (single char) and `splitSequence` (multi-char), NOT `split`. Consecutive delimiters produce empty strings.

---

## Exercise 15: mem.tokenizeScalar vs splitScalar (10pts)

Demonstrate the difference between `tokenizeScalar` and `splitScalar`. Use `tokenizeScalar(u8, "  hello   world  ", ' ')` — should yield only "hello" and "world" (skips consecutive delimiters). Use `splitScalar(u8, "a::b", ':')` — should yield "a", "" (empty), "b". Also demonstrate `tokenizeAny(u8, "hello, world; foo", ", ;")` which treats any character in the set as a delimiter.

**Key concept:** `tokenize*` skips consecutive delimiters; `split*` preserves them as empty strings. `tokenizeAny` takes a set of delimiter characters.

---

## Exercise 16: mem.zeroes, asBytes, concat (10pts)

Create a zero-initialized `[8]u8` array using `mem.zeroes` and verify all bytes are 0. Use `mem.asBytes` to reinterpret a `u32` value `0x04030201` as a byte slice — verify length is 4, and on little-endian check that `bytes[0]` is `0x01` and `bytes[3]` is `0x04`. Use `mem.concat` to join `{"Hello", ", ", "World!"}` into `"Hello, World!"` (allocates, must free). Also use `mem.replaceOwned` to replace `"-"` with `"_"` in `"a-b-c"`.

**Key concept:** `zeroes` works for any type. `asBytes` is a pointer reinterpretation. `concat` and `replaceOwned` both allocate and require cleanup.

---

## Exercise 17: fmt.bufPrint with {d} and {s} specifiers (5pts)

Use `std.fmt.bufPrint` with a stack-allocated `[64]u8` buffer. Format `"Name: {s}, Age: {d}"` with "Zig" and 15, verify the result. Format a `?u32` value of 42 with `{any}` — expect `"42"`. Format a null `?u32` with `{any}` — expect `"null"`.

**Key concept:** `{s}` for strings, `{d}` for integers, `{any}` for debug representation of any type. `bufPrint` returns a slice into the provided buffer.

---

## Exercise 18: fmt.allocPrint and comptimePrint (10pts)

Use `std.fmt.allocPrint(gpa, ...)` to format `"3 + 4 = 7"` — remember to `defer gpa.free(result)`. Use `std.fmt.comptimePrint("field_{d}", .{42})` to produce the comptime string literal `"field_42"`. Also demonstrate `comptimePrint` with two `{s}` arguments.

**Key concept:** `allocPrint` heap-allocates the result (must free). `comptimePrint` produces a comptime-known string literal with zero runtime cost.

---

## Exercise 19: fmt — padding, hex, binary, float precision (10pts)

Using `bufPrint`, demonstrate: (1) zero-padded decimal with `{d:0>8}` formatting 42 as `"00000042"`, (2) hex uppercase `0x{X}` formatting 255 as `"0xFF"`, (3) hex lowercase `0x{x}` as `"0xff"`, (4) binary `0b{b}` formatting 10 as `"0b1010"`, (5) float precision `{d:.3}` formatting 3.14159 as `"3.142"`, (6) left-align with fill `{s:_<10}` formatting "zig" as `"zig_______"`.

**Key concept:** Format spec syntax is `{specifier:fill<alignment>width.precision}`. Zig uses `{d}` for both integers and floats.

---

## Exercise 20: sort.pdq — ascending and descending (5pts)

Sort `[_]i32{5, 1, 4, 2, 3}` ascending using `sort.pdq(i32, ..., {}, sort.asc(i32))` and verify the result is `{1, 2, 3, 4, 5}`. Sort another array descending with `sort.desc(i32)` and verify `{5, 4, 3, 2, 1}`.

**Key 0.15.2 concept:** The sort function is `std.sort.pdq` (NOT `std.sort.sort`). It takes type, slice, context, and comparator.

---

## Exercise 21: sort.pdq — custom comparator and isSorted (10pts)

Sort an array of `[]const u8` strings by length using a custom comparator via anonymous struct: `struct { fn lessThan(_: void, a: []const u8, b: []const u8) bool { return a.len < b.len; } }.lessThan`. Verify the shortest string is first and the longest is last. Then use `sort.isSorted` to verify a sorted array returns true and an unsorted array returns false. Finally, sort an array of structs by a `.priority` field using a custom comparator.

**Key concept:** Custom comparators use the anonymous struct pattern. The comparator signature is `fn(context, T, T) bool`. `isSorted` uses the same comparator interface.

---

## Exercise 22: math — @min/@max builtins, clamp (5pts)

Use `@min(3, 7)` and `@max(3, 7)` to verify they return 3 and 7 respectively. Use `std.math.clamp` with value 5 in range [0, 10] (returns 5), value -5 (clamped to 0), and value 15 (clamped to 10). Also test `isPowerOfTwo` for 1 (true), 64 (true), and 63 (false).

**Key 0.15.2 concept:** `@min` and `@max` are builtins, NOT `std.math.min/max`. GOTCHA: `isPowerOfTwo(0)` panics because it asserts n > 0.

---

## Exercise 23: math — isPowerOfTwo, log2_int, divCeil, maxInt (5pts)

Use `math.log2_int(u32, 8)` to get 3, `log2_int(u32, 16)` to get 4, and `log2_int(u32, 1)` to get 0. Use `math.divCeil(u32, 10, 3)` with `catch unreachable` to get 4, `divCeil(u32, 9, 3)` to get 3, `divCeil(u32, 1, 3)` to get 1. Verify `maxInt(u8)` is 255, `minInt(i8)` is -128, and `maxInt(u16)` is 65535.

**Key concept:** `log2_int` returns floor(log2). `divCeil` returns an error union (use `catch unreachable` for known-safe cases). `maxInt`/`minInt` are comptime functions.

---

## Exercise 24: JSON — parseFromSlice into struct and dynamic Value (20pts)

**Part 1:** Define a struct `Config{host: []const u8, port: u16, debug: bool}`. Parse `{"host":"localhost","port":8080,"debug":true}` using `std.json.parseFromSlice(Config, gpa, json_str, .{})`. Verify `.value.host`, `.value.port`, and `.value.debug`. Remember `defer parsed.deinit()`.

**Part 2:** Parse `{"name":"Zig","version":15,"tags":["fast","safe"]}` into `std.json.Value`. Access fields via `.value.object.get(...)` — string fields via `.?.string`, integer via `.?.integer`, array via `.?.array.items`.

**Part 3:** Parse JSON with extra fields into a smaller struct using `.ignore_unknown_fields = true` in the options.

**Key 0.15.2 concept:** `parseFromSlice` returns a result with `.value` and requires `.deinit()`. Dynamic parsing uses `std.json.Value` with `.object`, `.string`, `.integer`, `.array` variants.

---

## Exercise 25: JSON — serialize with json.fmt, round-trip, parse options (20pts)

**Part 1:** Serialize a `Point{x: i32, y: i32}` struct using `std.fmt.allocPrint(gpa, "{f}", .{std.json.fmt(original, .{})})`. Verify the JSON string contains the expected values. Remember to free the result.

**Part 2:** Round-trip the serialized JSON by parsing it back with `parseFromSlice` and verifying the fields match.

**Part 3:** Demonstrate the `bufPrint` variant for stack-allocated JSON serialization.

**Part 4:** Serialize a struct with a `[]const u8` string field and round-trip it, verifying string equality.

**Key 0.15.2 concept:** There is NO `std.json.stringify` in 0.15.2. The pattern is `std.json.fmt(value, .{})` used with the `{f}` format specifier via `allocPrint` or `bufPrint`.

---

# Lesson 03: Error Handling & Allocator Patterns — Quiz Specification

Answer key: `src/exercises/lesson03_error_handling.zig` (25 tests, all must compile and pass)

## Point Distribution

| #  | Topic                                                    | Diff | Pts |
|----|----------------------------------------------------------|------|-----|
|  1 | Error sets — declaration and named error sets             |  1   |   5 |
|  2 | Error sets — anonymous (inferred) error sets              |  1   |   5 |
|  3 | Error sets — merging with `\|\|`                          |  1   |   5 |
|  4 | Error sets — `@errorName` runtime introspection           |  1   |   5 |
|  5 | Error sets — `@intFromError` and numeric identity         |  1   |   5 |
|  6 | Error unions — basic `ErrorSet!T` and `try`               |  1   |   5 |
|  7 | Error unions — `catch` with fallback value                |  1   |   5 |
|  8 | Error unions — `catch` with error payload                 |  1   |   5 |
|  9 | Error unions — if-else error unwrap                       |  1   |   5 |
| 10 | errdefer — basic cleanup on error path                    |  1   |   5 |
| 11 | errdefer — ordering (LIFO relative to defer)              |  1   |   5 |
| 12 | errdefer — `\|err\|` capture in function scope            |  1   |   5 |
| 13 | Error handling in loops — break on error with cleanup     |  1   |   5 |
| 14 | Error handling in loops — partial initialization cleanup  |  1   |   5 |
| 15 | FixedBufferAllocator — stack-based allocation             |  2   |  10 |
| 16 | FixedBufferAllocator — reset for reuse                    |  2   |  10 |
| 17 | ArenaAllocator — init, alloc, deinit, no frees needed    |  2   |  10 |
| 18 | ArenaAllocator — reset modes (retain/free_all)           |  2   |  10 |
| 19 | FailingAllocator — fail at specific index                 |  2   |  10 |
| 20 | FailingAllocator — allocation stats tracking              |  2   |  10 |
| 21 | checkAllAllocationFailures — exhaustive OOM testing      |  2   |  10 |
| 22 | Error set merging in multi-layer functions                |  2   |  10 |
| 23 | StackFallbackAllocator — stack-first with heap fallback  |  2   |  10 |
| 24 | Custom allocator — VTable implementation                  |  3   |  20 |
| 25 | Allocator composition — arena over fixed buffer + OOM    |  3   |  20 |
|    | **TOTAL**                                                |      | **200** |

Difficulty 1: 14 exercises = 70 pts
Difficulty 2: 9 exercises = 90 pts
Difficulty 3: 2 exercises = 40 pts

---

## Exercise Descriptions

### Exercise 1: Error sets — declaration and named error sets
**Difficulty 1 (5pts)**

Declare two named error sets (`FileError` with 3 variants, `NetworkError` with 3 variants). Demonstrate:
- Creating a variable of a named error set type
- Comparing error values with `==` and `!=`
- Using `@typeInfo` on the error set to verify it is `.error_set` and count the number of errors
- Assigning error values from different named sets to `anyerror` and confirming they differ

### Exercise 2: Error sets — anonymous (inferred) error sets
**Difficulty 1 (5pts)**

Write a function with return type `!u32` (inferred error set) that returns two different errors depending on the input. Demonstrate:
- Successful call with `try`
- `expectError` for each error variant
- Capturing the error with `if-else` and using `@errorName` on the inferred error

### Exercise 3: Error sets — merging with `||`
**Difficulty 1 (5pts)**

Merge two named error sets with `||` to create a combined set. Demonstrate:
- Assigning errors from either source set to the merged type
- Using `@typeInfo` to verify the merged set has the union of all errors (6 total)
- Implicit coercion from a specific error set to the merged superset

### Exercise 4: Error sets — `@errorName` runtime introspection
**Difficulty 1 (5pts)**

Use `@errorName` to get the string name of error values at runtime. Demonstrate:
- Converting `anyerror` to its name string
- Getting error name through an error union via `catch` capture
- Verifying the returned `[]const u8` has the expected length

### Exercise 5: Error sets — `@intFromError` and numeric identity
**Difficulty 1 (5pts)**

Convert errors to their integer representation with `@intFromError`. Demonstrate:
- Same error => same integer, different errors => different integers
- The integer type is `u16`
- Using `@intFromError` result as a key in `AutoHashMap(u16, u32)`

### Exercise 6: Error unions — basic `ErrorSet!T` and `try`
**Difficulty 1 (5pts)**

Write a function returning `error{DivisionByZero}!i32` and a chained function that calls it twice with `try`. Demonstrate:
- `try` unwraps success values
- `try` propagates errors through a call chain
- `expectError` on multiple failure paths (first call vs second call fails)

### Exercise 7: Error unions — `catch` with fallback value
**Difficulty 1 (5pts)**

Use `catch` to provide fallback values when errors occur. Demonstrate:
- Bare `catch` with a default value (NOT `catch |_|` which is a compile error in 0.15.2)
- `catch` with a labeled block for complex fallback logic
- `catch` not executing on the success path

### Exercise 8: Error unions — `catch` with error payload
**Difficulty 1 (5pts)**

Use `catch |err|` to capture the error value and branch on it. Demonstrate:
- `catch |err|` capturing the specific error for comparison
- `switch` on the captured error inside the catch block to return different fallback values per error variant

### Exercise 9: Error unions — if-else error unwrap
**Difficulty 1 (5pts)**

Use `if (error_union) |val| ... else |err| ...` to destructure error unions. Demonstrate:
- Success branch unwrapping the payload
- Error branch capturing the error
- Error union of optional (`anyerror!?u32`): show that `null` and `error` are distinct outcomes

### Exercise 10: errdefer — basic cleanup on error path
**Difficulty 1 (5pts)**

Write a struct with an `init` function that allocates memory, uses `errdefer` to free it if initialization fails. Demonstrate:
- Success path: `errdefer` does NOT run, caller owns the allocation
- Error path: `errdefer` runs and frees the allocation (no leak detected by testing.allocator)

### Exercise 11: errdefer — ordering (LIFO relative to defer)
**Difficulty 1 (5pts)**

Write a function that logs characters via `defer` and `errdefer` to demonstrate execution order. Demonstrate:
- Success path: only `defer` statements run in LIFO order
- Error path: both `errdefer` and `defer` run interleaved in LIFO order (most recent first, regardless of type)
- Verify the exact character sequences for both paths

### Exercise 12: errdefer — `|err|` capture in function scope
**Difficulty 1 (5pts)**

Write functions that use `errdefer |err|` to capture the error being returned. Demonstrate:
- `errdefer |err|` captures the actual error value for logging/diagnostics
- Using `@errorName(err)` inside the errdefer to record which error occurred
- Works with merged error sets (the captured error's name matches the specific variant)
- Note: `errdefer |err|` only works in function scope, NOT in block scope

### Exercise 13: Error handling in loops — break on error with cleanup
**Difficulty 1 (5pts)**

Write a function that iterates over a slice, appending to an ArrayList, but may encounter an error mid-loop. Demonstrate:
- `errdefer` on the ArrayList to clean up partial results on error
- Success: returns owned slice from the list
- Error: the errdefer cleans up, no leak

### Exercise 14: Error handling in loops — partial initialization cleanup
**Difficulty 1 (5pts)**

Write a struct that allocates a slice of allocated strings. If allocation fails partway, `errdefer` must free both the already-initialized individual strings and the outer slice. Demonstrate:
- Tracking `initialized` count and using it in errdefer to free partial work
- Multiple errdefer layers (one for the outer slice, one for the elements)
- Success with small count, failure with large count

### Exercise 15: FixedBufferAllocator — stack-based allocation
**Difficulty 2 (10pts)**

Create a `FixedBufferAllocator` from a stack-allocated `[256]u8` buffer. Demonstrate:
- Allocating `u8` slices and typed (`u32`) slices from the fixed buffer
- Multiple allocations succeeding
- `error.OutOfMemory` when the buffer is exhausted

### Exercise 16: FixedBufferAllocator — reset for reuse
**Difficulty 2 (10pts)**

Use `FixedBufferAllocator.reset()` to reclaim memory. Demonstrate:
- Exhaust the buffer, then `reset()`, then allocate again
- After reset, the new allocation occupies the same underlying memory (`ptr` equality)

### Exercise 17: ArenaAllocator — init, alloc, deinit, no frees needed
**Difficulty 2 (10pts)**

Create an `ArenaAllocator` backed by `testing.allocator`. Demonstrate:
- Allocating multiple things (strings via `allocPrint`, typed slices) without ever freeing them individually
- `arena.queryCapacity()` reports positive capacity
- Single `arena.deinit()` (via `defer`) frees everything

### Exercise 18: ArenaAllocator — reset modes (retain/free_all)
**Difficulty 2 (10pts)**

Use arena reset modes to manage memory lifecycle. Demonstrate:
- `.retain_capacity`: capacity preserved after reset, can allocate again
- `.free_all`: capacity returns to 0, pages released to backing allocator
- Allocating after `free_all` still works (gets new pages)

### Exercise 19: FailingAllocator — fail at specific index
**Difficulty 2 (10pts)**

Use `std.testing.FailingAllocator` to simulate OOM at specific allocation points. Demonstrate:
- `fail_index = 0`: first allocation fails => `error.OutOfMemory`
- `fail_index = 1`: second allocation attempt may fail
- Default config (no failure): function succeeds normally

### Exercise 20: FailingAllocator — allocation stats tracking
**Difficulty 2 (10pts)**

Use `FailingAllocator` fields to track allocation statistics. Demonstrate:
- `.allocations` count increments with each alloc
- `.deallocations` count increments with each free
- `.allocated_bytes` and `.freed_bytes` track byte totals

### Exercise 21: checkAllAllocationFailures — exhaustive OOM testing
**Difficulty 2 (10pts)**

Use `std.testing.checkAllAllocationFailures` for exhaustive OOM testing. Demonstrate:
- Writing a test function with signature `fn(alloc: Allocator) !void` (first param = Allocator, return = `!void`)
- The framework automatically tests every possible failure point
- Building a string with ArrayList, verifying the result inside the test function

### Exercise 22: Error set merging in multi-layer functions
**Difficulty 2 (10pts)**

Write a validation function returning `ValidationError` and a save function returning `(ValidationError || Allocator.Error)`. Demonstrate:
- Validation errors propagate through the merged set
- Allocation errors are also possible
- `switch` on the merged error set is exhaustive (must handle all variants)

### Exercise 23: StackFallbackAllocator — stack-first with heap fallback
**Difficulty 2 (10pts)**

Use `std.heap.stackFallback(size, fallback)` to create a stack-first allocator. Demonstrate:
- The API returns a `StackFallbackAllocator` — use `.get()` NOT `.allocator()` (the latter is a `@compileError` in 0.15.2)
- Small allocations fit in the stack buffer
- Works with stdlib types like `ArrayList`

### Exercise 24: Custom allocator — VTable implementation
**Difficulty 3 (20pts)**

Implement a counting allocator wrapper with the full `Allocator.VTable` interface (4 function pointers: alloc, resize, remap, free). Demonstrate:
- The vtable pattern: struct with child allocator, returns `Allocator{ .ptr = self, .vtable = &vtable }`
- Each VTable function signature: `fn(ctx: *anyopaque, ...) -> ...` with `@ptrCast(@alignCast(ctx))` to recover `*Self`
- Delegating to child via `rawAlloc`, `rawResize`, `rawRemap`, `rawFree`
- Tracking alloc/free counts and total bytes
- Using the custom allocator with stdlib types (ArrayList)

### Exercise 25: Allocator composition — arena over fixed buffer + OOM testing
**Difficulty 3 (20pts)**

Combine multiple allocator patterns in a single exercise. Three parts:

**Part A:** Arena over FixedBufferAllocator — zero syscall allocation from a stack buffer, building a multi-line report string without individual frees.

**Part B:** Scoped arena per request — loop creating a fresh arena per iteration, demonstrating the request-scoped allocation pattern.

**Part C:** `checkAllAllocationFailures` with the report builder — exhaustive OOM testing of a function that takes extra arguments beyond the allocator. Demonstrates passing extra args as a tuple to `checkAllAllocationFailures`.

---

## Key 0.15.2 Gotchas Covered

1. `catch |_|` is a compile error — use bare `catch` (Exercise 7)
2. `errdefer |err|` capture only works in function scope, not block scope (Exercise 12)
3. `std.mem.Alignment` is a public type (log2-based enum), used in VTable signatures (Exercise 24)
4. `StackFallbackAllocator` uses `.get()` not `.allocator()` — the latter is `@compileError` (Exercise 23)
5. `FailingAllocator.init(backing, .{ .fail_index = N })` then `.allocator()` (Exercise 19-20)
6. `ArenaAllocator.init(backing)` then `.allocator()` (Exercise 17-18)
7. `FixedBufferAllocator.init(&buf)` then `.allocator()` (Exercise 15-16)
8. `checkAllAllocationFailures`: first param must be `Allocator`, return must be `!void` (Exercise 21, 25C)
9. VTable has 4 fields: alloc, resize, remap, free (Exercise 24)
10. ArrayList uses `.empty` init + allocator-per-method pattern (Exercises 11, 13, 19-21, 24-25)

---

# Lesson 04: Comptime & Metaprogramming -- Quiz

| # | Topic | Diff | Pts |
|---|-------|------|-----|
| 1 | comptime var in blocks -- loop accumulator | 1 | 5 |
| 2 | comptime function parameters -- type as first-class value | 1 | 5 |
| 3 | comptime function evaluation -- recursive factorial | 1 | 5 |
| 4 | @typeInfo on integers and floats -- bits, signedness | 1 | 5 |
| 5 | @typeInfo on structs -- field details, defaults, quoted identifiers | 2 | 10 |
| 6 | @typeInfo on enums, unions, optionals, pointers, arrays, error sets | 2 | 10 |
| 7 | @Type to generate struct types at comptime | 2 | 10 |
| 8 | @Type to generate enum types at comptime | 2 | 10 |
| 9 | @typeName for type identity strings | 1 | 5 |
| 10 | std.meta -- fields, fieldNames, FieldEnum | 1 | 5 |
| 11 | std.meta -- stringToEnum, activeTag | 1 | 5 |
| 12 | std.meta -- hasFn, eql, Tag | 1 | 5 |
| 13 | comptime string concatenation with ++ and ** | 1 | 5 |
| 14 | std.fmt.comptimePrint for compile-time formatting | 1 | 5 |
| 15 | comptime string building -- join and reverse | 2 | 10 |
| 16 | comptime lookup tables -- base64 encode/decode pair | 2 | 10 |
| 17 | comptime lookup tables -- precomputed squares | 1 | 5 |
| 18 | inline for over types -- multi-type testing | 1 | 5 |
| 19 | inline for over struct fields -- generic field iteration | 2 | 10 |
| 20 | @compileError for static assertions and validation | 1 | 5 |
| 21 | @hasDecl and @hasField for feature detection | 1 | 5 |
| 22 | builder pattern -- chaining field assignments at comptime | 2 | 10 |
| 23 | custom format function -- {f} specifier (2-param) | 2 | 10 |
| 24 | full type transformation -- Nullable<T> via @Type | 3 | 20 |
| 25 | comptime state machine with generated enum and dispatch | 3 | 20 |
| **TOTAL** | | | **200** |

## Exercise 1: comptime var in blocks (5pts)
Use a `comptime` labeled block with a mutable `var` to compute the sum of 1..10. Verify the result equals 55. Prove it is truly comptime by using the result as an array size.

## Exercise 2: comptime function parameters -- type as first-class value (5pts)
Write a function that takes `comptime T: type` and returns `std.math.maxInt(T)`. Call it with u8, u16, and i8 and verify expected max values.

## Exercise 3: comptime function evaluation (5pts)
Write a recursive factorial function that works at both comptime and runtime. Call it with `comptime` to produce a compile-time constant. Use the result as an array size to prove it is comptime.

## Exercise 4: @typeInfo on integers and floats (5pts)
Introspect u32, i16, and f64 via `@typeInfo`. Verify `.int.bits` returns `u16` values (32, 16). Verify `.int.signedness` for signed vs unsigned. Verify `.float.bits` for f64.

## Exercise 5: @typeInfo on structs -- field details (10pts)
Define a struct with 4 fields including some with default values. Use `@typeInfo(T).@"struct"` (quoted identifier in 0.15.2). Verify field count, names, types, and which fields have non-null `default_value_ptr`.

## Exercise 6: @typeInfo on enums, unions, optionals, pointers, arrays, error sets (10pts)
Introspect six different type categories in one test. For enum: verify fields, tag_type, is_exhaustive. For union: verify tagged (tag_type != null). For optional: verify child type. For pointer: verify is_const, size, child. For array: verify len and child. For error set: verify it is non-null and has correct count.

## Exercise 7: @Type to generate struct types (10pts)
Write a function that accepts an array of field definitions (name + type) and returns a new struct type via `@Type(.{ .@"struct" = ... })`. Field names must be `[:0]const u8`. Instantiate the generated type and verify fields work. Round-trip with @typeInfo.

## Exercise 8: @Type to generate enum types (10pts)
Write a function that accepts `[:0]const u8` names and generates an enum type via `@Type(.{ .@"enum" = ... })`. Use `std.math.IntFittingRange` for the tag_type. Verify @tagName, @intFromEnum, and @enumFromInt round-trip.

## Exercise 9: @typeName for type identity strings (5pts)
Use `@typeName` on primitive types (u32, f64, bool) and verify exact string equality. For user-defined types, verify the name contains the type identifier. For pointer types, verify decoration is included (e.g., `*const u8`).

## Exercise 10: std.meta -- fields, fieldNames, FieldEnum (5pts)
Use `meta.fields` to get struct field info and verify count/names. Use `meta.fieldNames` to get just the name strings. Use `meta.FieldEnum` to get a compile-time enum of field names and switch on it.

## Exercise 11: std.meta -- stringToEnum and activeTag (5pts)
Use `meta.stringToEnum` to convert strings to enum values, showing both successful and null (unknown string) cases. Use `meta.activeTag` on tagged union values to identify the active variant.

## Exercise 12: std.meta -- hasFn, eql, Tag (5pts)
Use `meta.hasFn` to check for method existence vs constants vs non-existent names. Use `meta.eql` for deep value comparison of struct instances. Use `meta.Tag` to extract the tag type of a tagged union.

## Exercise 13: comptime string concatenation with ++ and ** (5pts)
Demonstrate `++` for multi-segment string concatenation at comptime. Demonstrate `**` for string repetition. Verify results with `expectEqualStrings`.

## Exercise 14: std.fmt.comptimePrint (5pts)
Use `std.fmt.comptimePrint` with format specifiers (`{d}`, `{s}`) to produce compile-time strings. Show it being used for a computed field name pattern.

## Exercise 15: comptime string building -- join and reverse (10pts)
Build a comptime join function using `++` in a loop within a `comptime` block to concatenate an array of strings with a separator. Write a comptime reverse function using `*const [s.len]u8` return type and a `comptime` block that fills a buffer in reverse order. Call reverse with `comptime` at the call site.

## Exercise 16: comptime lookup tables -- base64 encode/decode (10pts)
Build two comptime lookup tables: an encode table mapping 0-63 to base64 characters, and a decode table mapping characters back to 0-63 (0xFF for invalid). Use `@splat` for initialization. Verify the decode table is the inverse of encode. Verify invalid characters decode to 0xFF.

## Exercise 17: comptime lookup tables -- precomputed squares (5pts)
Build a comptime array of squares (0..15) using a `for` loop in a block expression. Verify specific entries (0, 1, 9, 100, 225).

## Exercise 18: inline for over types (5pts)
Use `inline for` to iterate over a tuple of types (u8, u16, u32) paired with their expected max values. Call a generic function for each type and verify the result matches.

## Exercise 19: inline for over struct fields -- generic field iteration (10pts)
Write a generic `sumFields` function that uses `inline for` over `@typeInfo(T).@"struct".fields` to sum all numeric (f32/f64) fields, skipping non-numeric fields. Test with two different struct types to prove generality.

## Exercise 20: @compileError for static assertions (5pts)
Write a generic `SafeArray(T, size)` type that uses `@compileError` to reject size=0, size>65536, and zero-sized element types at compile time. Demonstrate valid usage with push/pop operations. Comment out the invalid usages showing what compile errors they would produce.

## Exercise 21: @hasDecl and @hasField for feature detection (5pts)
Demonstrate `@hasDecl` for methods and constants, `@hasField` for data fields. Show that methods are not fields and vice versa. Write a comptime function that uses `@hasDecl` for conditional string building based on available declarations.

## Exercise 22: builder pattern -- chaining field assignments (10pts)
Write a generic `StructBuilder(T)` that initializes all fields to defaults (or zeroes). Provide a `set` method returning `*Self` for chaining. Use `@field` and inline for to read default_value_ptr. Demonstrate method chaining: `builder.set("host", "...").set("port", 443).build()`.

## Exercise 23: custom format with {f} specifier (10pts)
Define a struct with a `pub fn format(self: @This(), writer: anytype) !void` method (2-param signature for 0.15.2). Use `{f}` specifier in `bufPrint` and `allocPrint`. Verify formatted output. Note: `{any}` skips custom format; `{}` is an ambiguous compile error.

## Exercise 24: full type transformation -- Nullable<T> via @Type (20pts)
Write `NullableFields(T)` that transforms every struct field from type `F` to `?F` with a default of null. Use `@Type` to construct the new struct. Verify all fields default to null. Verify partial initialization. Verify field count and names are preserved via `inline for` comparison of original and nullable field arrays.

## Exercise 25: comptime state machine with generated enum and dispatch (20pts)
Write `ComptimeStateMachine(state_names)` that generates a state enum via `MakeEnumType` and returns a struct with: init (first state), transition, isIn, stateName, stateIndex, numStates, and a comptime `all_states_desc` string built by joining state names. Demonstrate full lifecycle: init, transitions, state queries, cancel path, and verify the comptime metadata string.

---

# Lesson 05: Idioms & Design Patterns — Quiz Specification

## Point Distribution

| #  | Topic                                                        | Diff | Pts |
|----|--------------------------------------------------------------|------|-----|
|  1 | Generic data structure — Stack(T) returning struct           |  1   |   5 |
|  2 | Generic data structure — multi-type instantiation            |  1   |   5 |
|  3 | Vtable interface — define and call through fat pointer       |  1   |   5 |
|  4 | Vtable interface — multiple implementors, polymorphic array  |  2   |  10 |
|  5 | Iterator pattern — next() returns ?T, while-optional loop   |  1   |   5 |
|  6 | Iterator pattern — filter iterator adapter                   |  2   |  10 |
|  7 | Writer interface — GenericWriter with custom context         |  1   |   5 |
|  8 | Writer interface — ArrayList writer and fixedBufferStream    |  1   |   5 |
|  9 | Allocator interface — parameter convention, init/deinit      |  1   |   5 |
| 10 | Allocator interface — arena allocator scoped lifetime        |  2   |  10 |
| 11 | RAII / defer — init/deinit pair with defer                   |  1   |   5 |
| 12 | RAII / defer — errdefer for partial initialization cleanup   |  2   |  10 |
| 13 | Sentinel-terminated slices — [:0]const u8 properties         |  1   |   5 |
| 14 | Sentinel-terminated slices — mem.span, mem.sliceTo           |  1   |   5 |
| 15 | @fieldParentPtr — recover parent from embedded field         |  1   |   5 |
| 16 | @fieldParentPtr — intrusive linked list traversal            |  2   |  10 |
| 17 | Comptime generics — BoundedBuffer(T, cap) with static array |  2   |  10 |
| 18 | Comptime generics — comptime validation and comptimePrint    |  1   |   5 |
| 19 | Tagged union state machine — define states, transitions      |  2   |  10 |
| 20 | Tagged union state machine — exhaustive switch dispatch      |  1   |   5 |
| 21 | Options struct pattern — defaults and partial init            |  1   |   5 |
| 22 | Options struct pattern — builder-style chaining              |  2   |  10 |
| 23 | Type-erased callbacks — *anyopaque context + fn pointer      |  2   |  10 |
| 24 | Combined: generic container with iterator + allocator        |  3   |  20 |
| 25 | Combined: type-erased event system with vtable + callbacks   |  3   |  20 |
|    | **TOTAL**                                                    |      |**200**|

Difficulty 1: 14 exercises x 5 pts  = 70 pts
Difficulty 2:  9 exercises x 10 pts = 90 pts
Difficulty 3:  2 exercises x 20 pts = 40 pts
Total: 25 exercises = 200 pts

---

## Exercise Descriptions

### 01: Generic data structure — Stack(T) returning struct (Diff 1, 5pts)
Define a function `fn GenericStack(comptime T: type) type` that returns a struct with a fixed-size backing array (`[16]T`), a `len` field, `push` and `pop` methods. `push` returns `error.Overflow` when full. `pop` returns `?T` (null when empty). Create a `GenericStack(u32)`, push three values, verify pop returns them in LIFO order, and verify popping an empty stack returns null.

### 02: Generic data structure — multi-type instantiation (Diff 1, 5pts)
Using the same `GenericStack` from exercise 01, instantiate stacks for `u8`, `f64`, and `bool`. Push type-specific values to each (e.g., `'Z'` for u8, `3.14` for f64, `true` for bool), pop them, and verify correctness. Demonstrates that the same generic produces distinct types.

### 03: Vtable interface — define and call through fat pointer (Diff 1, 5pts)
Define a `Stringable` interface struct with a `ptr: *anyopaque` and a `vtable` containing a single method `toString: *const fn(*anyopaque) []const u8`. Add a convenience method on `Stringable` that delegates to the vtable. Create a simple struct that implements this interface, wrap it, and verify calling `toString()` through the interface returns the expected string.

### 04: Vtable interface — multiple implementors, polymorphic array (Diff 2, 10pts)
Extend the vtable pattern with a `Measurable` interface that has both `name` and `value` vtable entries (returning `[]const u8` and `f64` respectively). Implement it for two different structs (e.g., `Temperature` with a degrees field, `Distance` with a meters field). Store both in a `[2]Measurable` array and iterate to verify each returns its correct name and value, demonstrating runtime polymorphism.

### 05: Iterator pattern — next() returns ?T, while-optional loop (Diff 1, 5pts)
Define a `Countdown` iterator struct with a `remaining: u32` field and a `next` method returning `?u32` that decrements and returns the value, or null when done. Use `while (iter.next()) |val|` to collect results into a sum and verify the total.

### 06: Iterator pattern — filter iterator adapter (Diff 2, 10pts)
Define a `FilterIterator` that wraps a slice and a predicate function pointer (`*const fn(u32) bool`). Its `next` method skips elements that do not satisfy the predicate. Use it to filter even numbers from `[_]u32{1,2,3,4,5,6,7,8}` and verify the filtered results are `{2,4,6,8}`.

### 07: Writer interface — GenericWriter with custom context (Diff 1, 5pts)
Create an `UppercaseWriter` struct that wraps a `[]u8` buffer and a write position. Implement the write function that converts all lowercase ASCII to uppercase before storing. Construct a `GenericWriter` from it, write `"hello world"`, and verify the buffer contains `"HELLO WORLD"`.

### 08: Writer interface — ArrayList writer and fixedBufferStream (Diff 1, 5pts)
Use `ArrayList(u8).writer(allocator)` to print formatted text (`"x={d}, y={d}"`) into the list. Separately, use `std.io.fixedBufferStream(&buf)` + `.writer()` to print the same format into a stack buffer. Verify both contain identical output using `expectEqualStrings`.

### 09: Allocator interface — parameter convention, init/deinit (Diff 1, 5pts)
Define a `DynamicString` struct that holds a `[]u8` slice. Implement `init(allocator, text)` that allocates and copies, and `deinit(self, allocator)` that frees. Use `testing.allocator` to create one, verify the content matches, and deinit (leak detection confirms correctness).

### 10: Allocator interface — arena allocator scoped lifetime (Diff 2, 10pts)
Create an `ArenaAllocator` backed by `page_allocator`. Allocate multiple items of different sizes (e.g., several `[]u8` buffers and a `[]u32` buffer) from the arena. Write data to each, verify correctness, then deinit the arena (all freed at once). Demonstrate that no individual `free` calls are needed.

### 11: RAII / defer — init/deinit pair with defer (Diff 1, 5pts)
Define a `Counter` struct that increments a shared `*u32` on init and decrements it on deinit. Create two counters in a nested scope using `defer counter.deinit()`. After the inner scope exits, verify the shared count decremented back, demonstrating automatic cleanup via defer.

### 12: RAII / defer — errdefer for partial initialization cleanup (Diff 2, 10pts)
Define a `TwoBuffers` struct holding two `[]u8` slices. In its `init` function, allocate the first buffer, then use `errdefer` to free it before attempting the second allocation. Simulate failure of the second allocation (e.g., with `FailingAllocator` or by returning an error). Verify that the first buffer is cleaned up on error (no leaks) and that success path works correctly.

### 13: Sentinel-terminated slices — [:0]const u8 properties (Diff 1, 5pts)
Given a string literal (which is `[:0]const u8`), verify: (a) `.len` does not include the null terminator, (b) the byte at index `[len]` is zero, (c) it coerces to `[]const u8`, and (d) it coerces to `[*:0]const u8`. Also demonstrate `allocSentinel` to create a heap-allocated sentinel slice, verify the sentinel byte.

### 14: Sentinel-terminated slices — mem.span, mem.sliceTo (Diff 1, 5pts)
Given a `[*:0]const u8` pointer (from a string literal), use `std.mem.span` to convert it to a `[]const u8` slice and verify contents. Separately, given a `[_]u8` array containing embedded zero bytes, use `std.mem.sliceTo` with sentinel `0` to extract the prefix before the first zero. Verify length and content.

### 15: @fieldParentPtr — recover parent from embedded field (Diff 1, 5pts)
Define a `Task` struct with a `priority: u32` field and an embedded `Hook` struct field (containing `next: ?*Hook`). Write a `fromHook` function using `@fieldParentPtr("hook", hook_ptr)` to recover the `*Task` from a `*Hook`. Create a Task, obtain a pointer to its hook, recover the Task pointer, and verify the priority field matches.

### 16: @fieldParentPtr — intrusive linked list traversal (Diff 2, 10pts)
Define a `Job` struct with a `name: []const u8` and an embedded `node: Node` field where `Node` has `prev: ?*Node` and `next: ?*Node`. Manually link three Jobs into a doubly-linked list through their `node` fields. Traverse the list via `node.next` pointers, using `@fieldParentPtr` to recover each `Job`, and collect the names. Verify the traversal order matches insertion order.

### 17: Comptime generics — BoundedBuffer(T, cap) with static array (Diff 2, 10pts)
Define `fn BoundedBuffer(comptime T: type, comptime cap: usize) type` returning a struct with a `[cap]T` array, `len: usize`, and `push`/`pop`/`isFull`/`isEmpty` methods. Instantiate `BoundedBuffer(u8, 4)`, push until full, verify `isFull()` returns true and push returns an error, pop all items verifying LIFO order, verify `isEmpty()`.

### 18: Comptime generics — comptime validation and comptimePrint (Diff 1, 5pts)
Define a `fn Matrix(comptime rows: usize, comptime cols: usize) type` that produces a compile error (via `@compileError`) if rows or cols is 0. Verify a valid instantiation (`Matrix(2,3)`) works by storing and retrieving a value. Use `std.fmt.comptimePrint` to generate a comptime description string like `"Matrix(2x3)"` and verify it.

### 19: Tagged union state machine — define states, transitions (Diff 2, 10pts)
Model a `Connection` state machine with states: `.idle`, `.connecting{ .attempt: u8 }`, `.connected{ .fd: i32 }`, `.disconnected{ .reason: []const u8 }`. Implement an `advance` method that transitions: idle->connecting(attempt=1), connecting->connected or connecting(attempt+1) based on a `success: bool` param (max 3 attempts, then disconnected with reason "max retries"). Drive the machine through a full connect scenario and a full failure scenario, verifying state at each step.

### 20: Tagged union state machine — exhaustive switch dispatch (Diff 1, 5pts)
Define a `TrafficLight` union(enum) with `.red`, `.yellow`, `.green` variants (all void payloads). Implement a `next` method using an exhaustive switch that cycles red->green->yellow->red. Call `next` three times starting from `.red` and verify the sequence.

### 21: Options struct pattern — defaults and partial init (Diff 1, 5pts)
Define a `ServerConfig` struct with fields `host: []const u8 = "localhost"`, `port: u16 = 8080`, `max_connections: u32 = 100`, `tls: bool = false`. Create three instances: one with all defaults, one overriding only `port`, one overriding all fields. Verify each field has the expected value.

### 22: Options struct pattern — builder-style chaining (Diff 2, 10pts)
Define a `QueryBuilder` struct with optional fields (`table: ?[]const u8`, `limit: ?u32`, `offset: ?u32`, `where_clause: ?[]const u8`) all defaulting to null. Implement `setTable`, `setLimit`, `setOffset`, `setWhere` methods that each return `*QueryBuilder` for chaining. Implement a `build` method that uses `std.io.fixedBufferStream` + writer to format a query string like `"SELECT * FROM users WHERE active=1 LIMIT 10 OFFSET 20"`. Verify the built string is correct.

### 23: Type-erased callbacks — *anyopaque context + fn pointer (Diff 2, 10pts)
Define a `Callback` struct with `context: *anyopaque` and `func: *const fn(*anyopaque) void`. Define an `Accumulator` struct with a `total: *u32` field. Implement a function matching the callback signature that adds 1 to the accumulator's total via `@ptrCast(@alignCast(...))`. Create the callback, invoke it three times, and verify total equals 3.

### 24: Combined — generic container with iterator + allocator (Diff 3, 20pts)
Define `fn Deque(comptime T: type) type` returning a struct implementing a double-ended queue backed by an allocator-managed slice (ring buffer). Must support: `init(allocator, capacity)`, `deinit()`, `pushFront(T)`, `pushBack(T)`, `popFront() ?T`, `popBack() ?T`, `len() usize`. Also implement an `iterator()` method returning an iterator struct with `next() ?T` that yields elements front-to-back. Test: push items from both ends, verify len, iterate and verify order, pop from both ends.

### 25: Combined — type-erased event system with vtable + callbacks (Diff 3, 20pts)
Build a simple event system. Define a `Listener` interface (vtable pattern) with a single `onEvent: *const fn(*anyopaque, []const u8) void` method. Define a `Logger` struct that appends event names to an `ArrayList(u8)`. Define a `Counter` struct that increments a count per event. Both implement `Listener`. Create an `EventBus` struct holding a fixed array of up to 8 `Listener` entries with `subscribe` and `emit` methods. Subscribe both a Logger and Counter, emit two events, verify the Logger captured both event names and the Counter recorded 2 events.

---

# Lesson 06: Concurrency & Threading — Quiz Specification

## Point Distribution

| #  | Topic                                                              | Diff | Pts |
|----|--------------------------------------------------------------------|------|-----|
|  1 | Thread.spawn and join — basic worker pattern                       |  1   |   5 |
|  2 | Multiple threads — parallel writes to separate result slots        |  1   |   5 |
|  3 | threadlocal variables — per-thread isolation                       |  1   |   5 |
|  4 | Thread.getCpuCount and Thread.sleep — utility functions            |  1   |   5 |
|  5 | Mutex — lock/unlock with defer                                     |  1   |   5 |
|  6 | Condition variable — basic signal and wait                         |  1   |   5 |
|  7 | Atomic.Value — init, load, store                                   |  1   |   5 |
|  8 | Atomic fetchAdd/fetchSub — returns the OLD value                   |  1   |   5 |
|  9 | Atomic bitwise — fetchOr, fetchAnd, fetchXor                       |  1   |   5 |
| 10 | Atomic swap — unconditional exchange                               |  1   |   5 |
| 11 | WaitGroup — start/finish/wait lifecycle                            |  1   |   5 |
| 12 | ResetEvent — set/wait signaling between threads                    |  1   |   5 |
| 13 | Semaphore — permits, wait, post                                    |  1   |   5 |
| 14 | spinLoopHint and cache_line — low-level hints                      |  1   |   5 |
| 15 | Mutex protecting shared state across threads                       |  2   |  10 |
| 16 | Condition variable — producer-consumer with spurious wakeup guard  |  2   |  10 |
| 17 | cmpxchgStrong — success/failure return semantics                   |  2   |  10 |
| 18 | Atomic lock-free counter across threads                            |  2   |  10 |
| 19 | Memory ordering — acquire/release publish pattern                  |  2   |  10 |
| 20 | Thread.Pool with WaitGroup — manual finish() obligation            |  2   |  10 |
| 21 | RwLock — concurrent readers, exclusive writer                      |  2   |  10 |
| 22 | cmpxchgWeak retry loop — CAS spin pattern                          |  2   |  10 |
| 23 | Multi-phase thread coordination with atomics                       |  2   |  10 |
| 24 | Lock-free stack — generic CAS-based push/pop                       |  3   |  20 |
| 25 | Barrier + pipeline — multi-stage parallel computation              |  3   |  20 |
|    | **TOTAL**                                                          |      |**200**|

Difficulty 1: 14 exercises x 5 pts  = 70 pts
Difficulty 2:  9 exercises x 10 pts = 90 pts
Difficulty 3:  2 exercises x 20 pts = 40 pts
Total: 25 exercises = 200 pts

---

## Exercise Descriptions

### 01: Thread.spawn and join — basic worker pattern (Diff 1, 5pts)

Write a function `fn setAnswer(ptr: *i32) void` that sets `ptr.*` to 42. In a test:
- Declare `var result: i32 = 0`
- Spawn a thread with `Thread.spawn(.{}, setAnswer, .{&result})`
- Call `.join()` on the returned handle
- Verify `result == 42`

This tests the fundamental spawn/join lifecycle. Key detail: `Thread.spawn` takes `(SpawnConfig, comptime fn, args_tuple)`. The handle **must** be joined or detached — failure to do so is a resource leak.

### 02: Multiple threads — parallel writes to separate result slots (Diff 1, 5pts)

Write a function `fn writeSquare(results: []i64, idx: usize) void` that writes `idx * idx` to `results[idx]`. In a test:
- Create a `[4]i64` array initialized to zeros
- Spawn 4 threads, each targeting a different index
- Join all 4 threads
- Verify `results[i] == i * i` for each index

Tests spawning multiple threads and passing slice + index arguments. No synchronization needed because each thread writes to a disjoint slot.

### 03: threadlocal variables — per-thread isolation (Diff 1, 5pts)

Declare a module-level `threadlocal var tls_value: u32 = 0`. Write a worker function that:
1. Sets `tls_value` to 0 (reset for determinism)
2. Increments `tls_value` exactly 50 times in a loop
3. Writes the final `tls_value` to a result pointer

Spawn 2 threads with this worker. After joining both, verify each result is exactly 50. This proves threads do not share `threadlocal` storage — if they did, you'd see interference.

### 04: Thread.getCpuCount and Thread.sleep — utility functions (Diff 1, 5pts)

In a single test:
- Call `Thread.getCpuCount()` (returns `!usize`), unwrap with `try`, verify `>= 1`
- Record `std.time.nanoTimestamp()` before and after `Thread.sleep(1_000_000)` (1ms)
- Verify elapsed time is `>= 500_000` nanoseconds (allowing scheduler slack)

Tests that these utility functions exist and have the expected signatures. `getCpuCount` returns an error union. `sleep` takes nanoseconds as a `u64`.

### 05: Mutex — lock/unlock with defer (Diff 1, 5pts)

Create a `Mutex` with `var mutex: Mutex = .{}` (static initialization — no init function). In a test:
- Lock the mutex
- Use `defer mutex.unlock()` for exception-safe release
- Inside the locked region, modify a variable
- After the scope exits, verify the variable was modified

Key detail: All Zig sync primitives use static initialization with `.{}`. There is no `.init()` function.

### 06: Condition variable — basic signal and wait (Diff 1, 5pts)

Demonstrate the fundamental Condition API in a single-threaded scenario:
- Create a `Condition` with `.{}` and a `Mutex` with `.{}`
- Spawn a thread that: locks the mutex, sets a `ready` flag to true, calls `cond.signal()`, unlocks
- In the main thread: lock the mutex, wait for `ready` with `while (!ready) cond.wait(&mutex)`, unlock
- Verify `ready == true`

Key detail: `Condition.wait(&mutex)` atomically releases the mutex and blocks. The condition variable itself is initialized with `.{}`.

### 07: Atomic.Value — init, load, store (Diff 1, 5pts)

Demonstrate the basic `std.atomic.Value(T)` API:
- `var counter = Atomic.Value(u32).init(0)` — initial value
- `counter.store(42, .seq_cst)` — atomic store
- `counter.load(.seq_cst)` returns `u32` — atomic load, verify equals 42
- Also demonstrate with `bool` type: init `false`, store `true`, load and verify

Tests that `Atomic.Value` is parameterized on type, and load/store take an `AtomicOrder` argument.

### 08: Atomic fetchAdd/fetchSub — returns the OLD value (Diff 1, 5pts)

**This is a gotcha exercise.** Demonstrate that fetch-modify operations return the **previous** value, not the new value:
- Init `Atomic.Value(i32)` to 10
- `fetchAdd(5, .seq_cst)` returns **10** (old), new value is 15
- `fetchSub(3, .seq_cst)` returns **15** (old), new value is 12
- Verify both the return values (old) and the final loaded value (12)

Common mistake: assuming fetchAdd returns the new value. It returns the value *before* the operation.

### 09: Atomic bitwise — fetchOr, fetchAnd, fetchXor (Diff 1, 5pts)

Demonstrate atomic bitwise operations on `Atomic.Value(u8)`:
- Init to `0b0000_0000`
- `fetchOr(0b0000_0011, .seq_cst)` — sets bits 0,1. Verify old was `0b0000_0000`, new is `0b0000_0011`
- `fetchAnd(0b1111_1110, .seq_cst)` — clears bit 0. Verify old was `0b0000_0011`, new is `0b0000_0010`
- `fetchXor(0b0000_1111, .seq_cst)` — toggles bits 0-3. Verify old was `0b0000_0010`, new is `0b0000_1101`

All fetch-bitwise ops also return the OLD value (same pattern as fetchAdd).

### 10: Atomic swap — unconditional exchange (Diff 1, 5pts)

Demonstrate `Atomic.Value.swap`:
- Init `Atomic.Value(u32)` to 10
- `swap(20, .seq_cst)` returns **10** (old value), atomically sets to 20
- `swap(30, .seq_cst)` returns **20**, atomically sets to 30
- Final `load(.seq_cst)` returns 30

Unlike `cmpxchg`, `swap` is unconditional — it always succeeds. Useful for replacing a value when you don't care about the current one (or only need to read it).

### 11: WaitGroup — start/finish/wait lifecycle (Diff 1, 5pts)

Write a worker `fn wgWorker(wg: *Thread.WaitGroup, slot: *Atomic.Value(u32), val: u32) void` that stores `val` into `slot` and calls `defer wg.finish()`. In a test:
- Create `var wg: Thread.WaitGroup = .{}`
- Create 4 `Atomic.Value(u32)` slots initialized to 0
- For each slot: call `wg.start()`, then `Thread.spawn` the worker
- Call `wg.wait()` to block until all finish
- Verify each slot has the expected value

Key lifecycle: `start()` before spawn, `finish()` inside worker (via defer), `wait()` in main thread.

### 12: ResetEvent — set/wait signaling between threads (Diff 1, 5pts)

Demonstrate `Thread.ResetEvent` for one-shot signaling:
- Create `var event: Thread.ResetEvent = .{}`
- Create an `Atomic.Value(bool)` flag initialized to false
- Spawn a thread that calls `event.wait()`, then sets flag to true
- In the main thread, sleep briefly (1ms), verify flag is still false, then call `event.set()`
- Join the thread, verify flag is now true

This shows that `wait()` blocks until `set()` is called from another thread.

### 13: Semaphore — permits, wait, post (Diff 1, 5pts)

Demonstrate `Thread.Semaphore` for limiting concurrent access:
- Create `var sem: Thread.Semaphore = .{ .permits = 3 }`
- Call `sem.wait()` three times (acquires all 3 permits)
- Call `sem.post()` once (releases 1 permit)
- Call `sem.wait()` once more (acquires the released permit)
- Call `sem.post()` three times to release all

Key detail: `.permits` is the initial count. `wait()` decrements (blocks if 0). `post()` increments.

### 14: spinLoopHint and cache_line — low-level hints (Diff 1, 5pts)

In a test:
- Call `std.atomic.spinLoopHint()` — emits a CPU-specific hint (PAUSE on x86, YIELD on ARM). Verify it compiles and runs without error
- Read `std.atomic.cache_line` — verify it is `>= 32` and `<= 256` (typical values)
- Demonstrate the concept: define a struct with padding to cache_line size (using `[Atomic.cache_line]u8` or similar). Verify `@sizeOf` is at least `cache_line`

These primitives are used for spin-wait loops and preventing false sharing.

### 15: Mutex protecting shared state across threads (Diff 2, 10pts)

Define a `SharedCounter` struct with a `Mutex` and `count: i64`, both default-initialized. Implement an `increment(self: *SharedCounter) void` method that locks, increments, unlocks (using defer). Write a worker function that calls `increment` 1000 times in a loop.

In a test:
- Create a `SharedCounter{}`
- Spawn 4 threads, each running the worker with 1000 iterations
- Join all threads
- Verify `count == 4000` exactly

Without the mutex, this would race. The test proves correctness under contention.

### 16: Condition variable — producer-consumer with spurious wakeup guard (Diff 2, 10pts)

**GOTCHA: Condition.wait MUST be in a while loop, never a bare if.**

Implement a `BoundedQueue` struct with:
- `mutex: Mutex = .{}`, `not_empty: Condition = .{}`, `not_full: Condition = .{}`
- `buf: [4]i32 = undefined`, `head: usize = 0`, `tail: usize = 0`, `count: usize = 0`

`push(val)`: lock, **while** `count == buf.len` → `not_full.wait(&mutex)`, insert at tail, increment count, `not_empty.signal()`, unlock.
`pop()`: lock, **while** `count == 0` → `not_empty.wait(&mutex)`, read from head, decrement count, `not_full.signal()`, unlock.

Write a producer thread that pushes 0..9 and a consumer that pops 10 values. Verify the consumer received values 0 through 9 in order.

The while-loop around wait is critical — using `if` instead would cause bugs due to spurious wakeups. The exercise description **must** use `while`, not `if`.

### 17: cmpxchgStrong — success/failure return semantics (Diff 2, 10pts)

Demonstrate the compare-and-swap API in detail:
- Init `Atomic.Value(u32)` to 100
- **Successful CAS**: `cmpxchgStrong(100, 200, .seq_cst, .seq_cst)` — expected matches, returns `null` (success), value becomes 200
- **Failed CAS**: `cmpxchgStrong(100, 300, .seq_cst, .seq_cst)` — expected is 100 but actual is 200, returns `@as(?u32, 200)` (the current value)
- Value is still 200 (unchanged by failed CAS)
- Demonstrate a retry loop: use `cmpxchgStrong` to atomically double the value. Read current, attempt CAS with `current * 2`, retry if it fails. Verify final value is 400.

Key detail: return type is `?T`. `null` = success, `T` = failure (returns the actual value that prevented the swap).

### 18: Atomic lock-free counter across threads (Diff 2, 10pts)

Write a worker `fn atomicIncrement(counter: *Atomic.Value(u64), n: u32) void` that calls `fetchAdd(1, .monotonic)` in a loop `n` times.

In a test:
- Init counter to 0
- Spawn 4 threads, each incrementing 5000 times
- Join all
- Load with `.seq_cst`, verify equals 20000

This demonstrates that atomics provide correctness without a mutex. Use `.monotonic` for the fetchAdd (sufficient for a counter) and `.seq_cst` for the final verification load.

### 19: Memory ordering — acquire/release publish pattern (Diff 2, 10pts)

Implement the "publish" pattern:
- Shared state: `var data = Atomic.Value(u32).init(0)` and `var ready = Atomic.Value(bool).init(false)`
- **Writer thread**: store `data` with `.monotonic`, then store `ready` with `.release`
- **Reader thread**: spin-load `ready` with `.acquire` until true, then load `data` with `.monotonic`

The acquire-load of `ready` synchronizes with the release-store, guaranteeing the reader sees the writer's data store. Verify the reader sees the correct data value.

Key subtlety: `.release` on the store creates a "happens-before" edge. The `.acquire` load observes it. `.monotonic` alone would NOT guarantee visibility of `data`.

### 20: Thread.Pool with WaitGroup — manual finish() obligation (Diff 2, 10pts)

**GOTCHA: Thread.Pool does NOT call wg.finish() for you. The worker must do it manually.**

In a test:
- Create `Thread.Pool` with `pool.init(.{ .allocator = allocator, .n_jobs = 2 })`
- Use `defer pool.deinit()`
- Create 8 `Atomic.Value(u32)` result slots
- Create a `WaitGroup`
- For each slot: `wg.start()`, then `pool.spawn(worker, .{ &wg, &results, i })`
- The worker function **must** have `defer wg.finish()` — without it, `wg.wait()` would hang forever
- Call `wg.wait()`, verify all results

If the student forgets `wg.finish()` in the worker, the test deadlocks. This is one of the most common concurrency bugs in Zig.

### 21: RwLock — concurrent readers, exclusive writer (Diff 2, 10pts)

Define a `SharedData` struct with:
- `rwlock: Thread.RwLock = .{}`
- `value: i64 = 0`
- `fn read(self: *SharedData) i64` — `lockShared()`, defer `unlockShared()`, return value
- `fn write(self: *SharedData, val: i64) void` — `lock()`, defer `unlock()`, set value

Write a writer thread that writes values 1..100 sequentially. Write 3 reader threads that each read 100 times, tracking the maximum value seen (using an `Atomic.Value(i64)` with a CAS-max loop). After joining all:
- Verify `data.read() == 100`
- Verify max_seen is >= some reasonable value (readers observed writes)

Key API: `lockShared/unlockShared` for readers (concurrent), `lock/unlock` for writers (exclusive).

### 22: cmpxchgWeak retry loop — CAS spin pattern (Diff 2, 10pts)

**cmpxchgWeak may fail spuriously** (unlike Strong). It must always be used in a retry loop.

Implement `fn atomicMax(atom: *Atomic.Value(i32), new_val: i32) void`:
1. Load current value with `.monotonic`
2. If `new_val <= current`, return (nothing to do)
3. Attempt `cmpxchgWeak(current, new_val, .release, .monotonic)`
4. If CAS returns non-null (failure), update `current` to the returned value and retry from step 2

Test in single-threaded mode:
- Init to 0, call atomicMax with 10, verify 10
- Call atomicMax with 5, verify still 10 (no change)
- Call atomicMax with 20, verify 20

Then test with 4 threads each calling atomicMax with their thread index × 100. After join, verify the value equals the maximum thread contribution.

### 23: Multi-phase thread coordination with atomics (Diff 2, 10pts)

Implement a two-phase computation:
- **Phase 1**: Each of N threads computes a partial result and writes it to its slot
- **Phase 2**: Each thread reads ALL slots and computes the global sum

Use a shared `Atomic.Value(u32)` as a phase counter:
- Each thread does phase 1, then `fetchAdd(1, .acq_rel)` on the counter
- Each thread spins with `spinLoopHint()` until `counter.load(.acquire) == N` (all arrived)
- Each thread then does phase 2

Verify that every thread computed the same global sum. This is a manual barrier implementation using only atomics.

### 24: Lock-free stack — generic CAS-based push/pop (Diff 3, 20pts)

Implement `fn LockFreeStack(comptime T: type) type` returning a struct with:
- `const Node = struct { value: T, next: ?*Node }`
- `head: Atomic.Value(?*Node)` initialized to `null`
- `allocator: std.mem.Allocator`

**push(value: T) !void**:
1. Allocate a `Node` with `self.allocator.create(Node)`
2. Set `node.value = value`
3. CAS loop: load current head, set `node.next = current_head`, attempt `cmpxchgWeak(current_head, node, .release, .monotonic)`. On failure, update current_head and retry.

**pop() ?T**:
1. CAS loop: load head with `.acquire`. If null, return null.
2. Attempt `cmpxchgWeak(current_head, node.next, .acq_rel, .acquire)`. On failure, update current_head and retry.
3. On success, save `node.value`, `self.allocator.destroy(node)`, return value.

**deinit()**: Pop all remaining nodes to free them.

Test single-threaded: push 1, 2, 3, verify pop returns 3, 2, 1 (LIFO), then null. Use `testing.allocator` for leak detection.

### 25: Barrier + pipeline — multi-stage parallel computation (Diff 3, 20pts)

Build a reusable `Barrier` struct:
- `count: Atomic.Value(u32)` — number of threads that have arrived
- `total: u32` — number of threads expected
- `event: Thread.ResetEvent = .{}` — signals when all have arrived

`fn init(total: u32) Barrier` — sets count to 0, stores total.
`fn arrive(self: *Barrier) void` — `fetchAdd(1, .acq_rel)` on count; if `prev + 1 == total`, call `event.set()`; otherwise call `event.wait()`.

Then implement a 2-stage pipeline with 4 worker threads:
- **Stage 1**: Thread `i` writes `(i + 1) * 10` to `results[i]`
- **Barrier**: All threads synchronize
- **Stage 2**: Thread `i` reads ALL results and writes their sum to `sums[i]`

After joining all threads, verify:
- Each `results[i] == (i + 1) * 10` (stage 1 correct)
- Each `sums[i] == 10 + 20 + 30 + 40 == 100` (stage 2 saw all stage 1 results)

This tests the barrier ensuring no thread enters stage 2 before all complete stage 1.

---

## Key 0.15.2 Gotchas Tested

1. **All sync primitives use `.{}` static init** — no `.init()` function for Mutex, Condition, RwLock, Semaphore, WaitGroup, ResetEvent (Exercises 5, 6, 11-13, 15-16, 21)
2. **fetchAdd/fetchSub/fetchOr/etc. return the OLD value** — common mistake to expect new value (Exercises 8-9)
3. **cmpxchgStrong returns `?T`** — null on success, actual value on failure (Exercise 17)
4. **cmpxchgWeak can spuriously fail** — must always be in a retry loop (Exercise 22)
5. **Condition.wait MUST be in a while loop** — spurious wakeups are possible (Exercise 16)
6. **Thread.Pool.spawn: worker must call `wg.finish()`** — the pool does NOT do it for you (Exercise 20)
7. **Thread handles must be joined or detached** — leaking a handle is a resource leak (Exercise 1)
8. **Thread.Pool.init takes `.{ .allocator, .n_jobs }`** and must be `.deinit()`'d (Exercise 20)
9. **Memory ordering**: `.release` on store pairs with `.acquire` on load for happens-before (Exercise 19)
10. **ResetEvent.reset() while threads are waiting is undefined behavior** — never tested, but noted (Exercise 12)
