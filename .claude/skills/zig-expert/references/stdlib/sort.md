// Zig 0.15.2 std.sort — API signatures + doc comments

pub const Mode = enum { stable, unstable };

/// Stable in-place sort. O(n) best case, O(pow(n, 2)) worst case.
/// O(1) memory (no allocator required).
/// Sorts in ascending order with respect to the given `lessThan` function.
pub fn insertion(

pub fn lessThan(ctx: @This(), a: usize, b: usize) bool

pub fn swap(ctx: @This(), a: usize, b: usize) void

/// Stable in-place sort. O(n) best case, O(pow(n, 2)) worst case.
/// O(1) memory (no allocator required).
/// `context` must have methods `swap` and `lessThan`,
/// which each take 2 `usize` parameters indicating the index of an item.
/// Sorts in ascending order with respect to `lessThan`.
pub fn insertionContext(a: usize, b: usize, context: anytype) void

/// Unstable in-place sort. O(n*log(n)) best case, worst case and average case.
/// O(1) memory (no allocator required).
/// Sorts in ascending order with respect to the given `lessThan` function.
pub fn heap(

pub fn lessThan(ctx: @This(), a: usize, b: usize) bool

pub fn swap(ctx: @This(), a: usize, b: usize) void

/// Unstable in-place sort. O(n*log(n)) best case, worst case and average case.
/// O(1) memory (no allocator required).
/// `context` must have methods `swap` and `lessThan`,
/// which each take 2 `usize` parameters indicating the index of an item.
/// Sorts in ascending order with respect to `lessThan`.
pub fn heapContext(a: usize, b: usize, context: anytype) void

/// Use to generate a comparator function for a given type. e.g. `sort(u8, slice, {}, asc(u8))`.
pub fn asc(comptime T: type) fn (void, T, T) bool

pub fn inner(_: void, a: T, b: T) bool

/// Use to generate a comparator function for a given type. e.g. `sort(u8, slice, {}, desc(u8))`.
pub fn desc(comptime T: type) fn (void, T, T) bool

pub fn inner(_: void, a: T, b: T) bool

/// Returns the index of an element in `items` returning `.eq` when given to `compareFn`.
/// - If there are multiple such elements, returns the index of any one of them.
/// - If there are no such elements, returns `null`.
///
/// `items` must be sorted in ascending order with respect to `compareFn`:
/// ```
/// [0]                                                   [len]
/// ┌───┬───┬─/ /─┬───┬───┬───┬─/ /─┬───┬───┬───┬─/ /─┬───┐
/// │.lt│.lt│ \ \ │.lt│.eq│.eq│ \ \ │.eq│.gt│.gt│ \ \ │.gt│
/// └───┴───┴─/ /─┴───┴───┴───┴─/ /─┴───┴───┴───┴─/ /─┴───┘
/// ├─────────────────┼─────────────────┼─────────────────┤
///  ↳ zero or more    ↳ zero or more    ↳ zero or more
///                   ├─────────────────┤
///                    ↳ if not null, returned
///                      index is in this range
/// ```
///
/// `O(log n)` time complexity.
///
/// See also: `lowerBound, `upperBound`, `partitionPoint`, `equalRange`.
pub fn binarySearch(

/// Returns the index of the first element in `items` that is greater than or equal to `context`,
/// as determined by `compareFn`. If no such element exists, returns `items.len`.
///
/// `items` must be sorted in ascending order with respect to `compareFn`:
/// ```
/// [0]                                                   [len]
/// ┌───┬───┬─/ /─┬───┬───┬───┬─/ /─┬───┬───┬───┬─/ /─┬───┐
/// │.lt│.lt│ \ \ │.lt│.eq│.eq│ \ \ │.eq│.gt│.gt│ \ \ │.gt│
/// └───┴───┴─/ /─┴───┴───┴───┴─/ /─┴───┴───┴───┴─/ /─┴───┘
/// ├─────────────────┼─────────────────┼─────────────────┤
///  ↳ zero or more    ↳ zero or more    ↳ zero or more
///                   ├───┤
///                    ↳ returned index
/// ```
///
/// `O(log n)` time complexity.
///
/// See also: `binarySearch`, `upperBound`, `partitionPoint`, `equalRange`.
pub fn lowerBound(

/// Returns the index of the first element in `items` that is greater than `context`, as determined
/// by `compareFn`. If no such element exists, returns `items.len`.
///
/// `items` must be sorted in ascending order with respect to `compareFn`:
/// ```
/// [0]                                                   [len]
/// ┌───┬───┬─/ /─┬───┬───┬───┬─/ /─┬───┬───┬───┬─/ /─┬───┐
/// │.lt│.lt│ \ \ │.lt│.eq│.eq│ \ \ │.eq│.gt│.gt│ \ \ │.gt│
/// └───┴───┴─/ /─┴───┴───┴───┴─/ /─┴───┴───┴───┴─/ /─┴───┘
/// ├─────────────────┼─────────────────┼─────────────────┤
///  ↳ zero or more    ↳ zero or more    ↳ zero or more
///                                     ├───┤
///                                      ↳ returned index
/// ```
///
/// `O(log n)` time complexity.
///
/// See also: `binarySearch`, `lowerBound`, `partitionPoint`, `equalRange`.
pub fn upperBound(

/// Returns the index of the partition point of `items` in relation to the given predicate.
/// - If all elements of `items` satisfy the predicate the returned value is `items.len`.
///
/// `items` must contain a prefix for which all elements satisfy the predicate,
/// and beyond which none of the elements satisfy the predicate:
/// ```
/// [0]                                          [len]
/// ┌────┬────┬─/ /─┬────┬─────┬─────┬─/ /─┬─────┐
/// │true│true│ \ \ │true│false│false│ \ \ │false│
/// └────┴────┴─/ /─┴────┴─────┴─────┴─/ /─┴─────┘
/// ├────────────────────┼───────────────────────┤
///  ↳ zero or more       ↳ zero or more
///                      ├─────┤
///                       ↳ returned index
/// ```
///
/// `O(log n)` time complexity.
///
/// See also: `binarySearch`, `lowerBound, `upperBound`, `equalRange`.
pub fn partitionPoint(

/// Returns a tuple of the lower and upper indices in `items` between which all
/// elements return `.eq` when given to `compareFn`.
/// - If no element in `items` returns `.eq`, both indices are the
/// index of the first element in `items` returning `.gt`.
/// - If no element in `items` returns `.gt`, both indices equal `items.len`.
///
/// `items` must be sorted in ascending order with respect to `compareFn`:
/// ```
/// [0]                                                   [len]
/// ┌───┬───┬─/ /─┬───┬───┬───┬─/ /─┬───┬───┬───┬─/ /─┬───┐
/// │.lt│.lt│ \ \ │.lt│.eq│.eq│ \ \ │.eq│.gt│.gt│ \ \ │.gt│
/// └───┴───┴─/ /─┴───┴───┴───┴─/ /─┴───┴───┴───┴─/ /─┴───┘
/// ├─────────────────┼─────────────────┼─────────────────┤
///  ↳ zero or more    ↳ zero or more    ↳ zero or more
///                   ├─────────────────┤
///                    ↳ returned range
/// ```
///
/// `O(log n)` time complexity.
///
/// See also: `binarySearch`, `lowerBound, `upperBound`, `partitionPoint`.
pub fn equalRange(

pub fn argMin(

pub fn min(

pub fn argMax(

pub fn max(

pub fn isSorted(
