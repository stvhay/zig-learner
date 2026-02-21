// Zig 0.15.2 std.array_list — API signatures + doc comments

/// Deprecated.
pub fn Managed(comptime T: type) type

/// Deprecated.
pub fn AlignedManaged(comptime T: type, comptime alignment: ?mem.Alignment) type

pub fn SentinelSlice(comptime s: T) type

        /// Deinitialize with `deinit` or use `toOwnedSlice`.
pub fn init(gpa: Allocator) Self

        /// Initialize with capacity to hold `num` elements.
        /// The resulting capacity will equal `num` exactly.
        /// Deinitialize with `deinit` or use `toOwnedSlice`.
pub fn initCapacity(gpa: Allocator, num: usize) Allocator.Error!Self

        /// Release all allocated memory.
pub fn deinit(self: Self) void

        /// ArrayList takes ownership of the passed in slice. The slice must have been
        /// allocated with `gpa`.
        /// Deinitialize with `deinit` or use `toOwnedSlice`.
pub fn fromOwnedSlice(gpa: Allocator, slice: Slice) Self

        /// ArrayList takes ownership of the passed in slice. The slice must have been
        /// allocated with `gpa`.
        /// Deinitialize with `deinit` or use `toOwnedSlice`.
pub fn fromOwnedSliceSentinel(gpa: Allocator, comptime sentinel: T, slice: [:sentinel]T) Self

        /// Initializes an ArrayList with the `items` and `capacity` fields
        /// of this ArrayList. Empties this ArrayList.
pub fn moveToUnmanaged(self: *Self) Aligned(T, alignment)

        /// The caller owns the returned memory. Empties this ArrayList.
        /// Its capacity is cleared, making `deinit` safe but unnecessary to call.
pub fn toOwnedSlice(self: *Self) Allocator.Error!Slice

        /// The caller owns the returned memory. Empties this ArrayList.
pub fn toOwnedSliceSentinel(self: *Self, comptime sentinel: T) Allocator.Error!SentinelSlice(sentinel)

        /// Creates a copy of this ArrayList, using the same allocator.
pub fn clone(self: Self) Allocator.Error!Self

        /// Insert `item` at index `i`. Moves `list[i .. list.len]` to higher indices to make room.
        /// If `i` is equal to the length of the list this operation is equivalent to append.
        /// This operation is O(N).
        /// Invalidates element pointers if additional memory is needed.
        /// Asserts that the index is in bounds or equal to the length.
pub fn insert(self: *Self, i: usize, item: T) Allocator.Error!void

        /// Insert `item` at index `i`. Moves `list[i .. list.len]` to higher indices to make room.
        /// If `i` is equal to the length of the list this operation is
        /// equivalent to appendAssumeCapacity.
        /// This operation is O(N).
        /// Asserts that there is enough capacity for the new item.
        /// Asserts that the index is in bounds or equal to the length.
pub fn insertAssumeCapacity(self: *Self, i: usize, item: T) void

        /// Add `count` new elements at position `index`, which have
        /// `undefined` values. Returns a slice pointing to the newly allocated
        /// elements, which becomes invalid after various `ArrayList`
        /// operations.
        /// Invalidates pre-existing pointers to elements at and after `index`.
        /// Invalidates all pre-existing element pointers if capacity must be
        /// increased to accommodate the new elements.
        /// Asserts that the index is in bounds or equal to the length.
pub fn addManyAt(self: *Self, index: usize, count: usize) Allocator.Error![]T

        /// Add `count` new elements at position `index`, which have
        /// `undefined` values. Returns a slice pointing to the newly allocated
        /// elements, which becomes invalid after various `ArrayList`
        /// operations.
        /// Asserts that there is enough capacity for the new elements.
        /// Invalidates pre-existing pointers to elements at and after `index`, but
        /// does not invalidate any before that.
        /// Asserts that the index is in bounds or equal to the length.
pub fn addManyAtAssumeCapacity(self: *Self, index: usize, count: usize) []T

        /// Insert slice `items` at index `i` by moving `list[i .. list.len]` to make room.
        /// This operation is O(N).
        /// Invalidates pre-existing pointers to elements at and after `index`.
        /// Invalidates all pre-existing element pointers if capacity must be
        /// increased to accommodate the new elements.
        /// Asserts that the index is in bounds or equal to the length.
pub fn insertSlice(

        /// Grows or shrinks the list as necessary.
        /// Invalidates element pointers if additional capacity is allocated.
        /// Asserts that the range is in bounds.
pub fn replaceRange(self: *Self, start: usize, len: usize, new_items: []const T) Allocator.Error!void

        /// Grows or shrinks the list as necessary.
        /// Never invalidates element pointers.
        /// Asserts the capacity is enough for additional items.
pub fn replaceRangeAssumeCapacity(self: *Self, start: usize, len: usize, new_items: []const T) void

        /// Extends the list by 1 element. Allocates more memory as necessary.
        /// Invalidates element pointers if additional memory is needed.
pub fn append(self: *Self, item: T) Allocator.Error!void

        /// Extends the list by 1 element.
        /// Never invalidates element pointers.
        /// Asserts that the list can hold one additional item.
pub fn appendAssumeCapacity(self: *Self, item: T) void

        /// Remove the element at index `i`, shift elements after index
        /// `i` forward, and return the removed element.
        /// Invalidates element pointers to end of list.
        /// This operation is O(N).
        /// This preserves item order. Use `swapRemove` if order preservation is not important.
        /// Asserts that the index is in bounds.
        /// Asserts that the list is not empty.
pub fn orderedRemove(self: *Self, i: usize) T

        /// Removes the element at the specified index and returns it.
        /// The empty slot is filled from the end of the list.
        /// This operation is O(1).
        /// This may not preserve item order. Use `orderedRemove` if you need to preserve order.
        /// Asserts that the list is not empty.
        /// Asserts that the index is in bounds.
pub fn swapRemove(self: *Self, i: usize) T

        /// Append the slice of items to the list. Allocates more
        /// memory as necessary.
        /// Invalidates element pointers if additional memory is needed.
pub fn appendSlice(self: *Self, items: []const T) Allocator.Error!void

        /// Append the slice of items to the list.
        /// Never invalidates element pointers.
        /// Asserts that the list can hold the additional items.
pub fn appendSliceAssumeCapacity(self: *Self, items: []const T) void

        /// Append an unaligned slice of items to the list. Allocates more
        /// memory as necessary. Only call this function if calling
        /// `appendSlice` instead would be a compile error.
        /// Invalidates element pointers if additional memory is needed.
pub fn appendUnalignedSlice(self: *Self, items: []align(1) const T) Allocator.Error!void

        /// Append the slice of items to the list.
        /// Never invalidates element pointers.
        /// This function is only needed when calling
        /// `appendSliceAssumeCapacity` instead would be a compile error due to the
        /// alignment of the `items` parameter.
        /// Asserts that the list can hold the additional items.
pub fn appendUnalignedSliceAssumeCapacity(self: *Self, items: []align(1) const T) void

pub fn print(self: *Self, comptime fmt: []const u8, args: anytype) error

        /// Initializes a Writer which will append to the list.
pub fn writer(self: *Self) Writer

        /// Initializes a Writer which will append to the list but will return
        /// `error.OutOfMemory` rather than increasing capacity.
pub fn fixedWriter(self: *Self) FixedWriter

        /// Append a value to the list `n` times.
        /// Allocates more memory as necessary.
        /// Invalidates element pointers if additional memory is needed.
        /// The function is inline so that a comptime-known `value` parameter will
        /// have a more optimal memset codegen in case it has a repeated byte pattern.
pub inline fn appendNTimes(self: *Self, value: T, n: usize) Allocator.Error!void

        /// Append a value to the list `n` times.
        /// Never invalidates element pointers.
        /// The function is inline so that a comptime-known `value` parameter will
        /// have a more optimal memset codegen in case it has a repeated byte pattern.
        /// Asserts that the list can hold the additional items.
pub inline fn appendNTimesAssumeCapacity(self: *Self, value: T, n: usize) void

        /// Adjust the list length to `new_len`.
        /// Additional elements contain the value `undefined`.
        /// Invalidates element pointers if additional memory is needed.
pub fn resize(self: *Self, new_len: usize) Allocator.Error!void

        /// Reduce allocated capacity to `new_len`.
        /// May invalidate element pointers.
        /// Asserts that the new length is less than or equal to the previous length.
pub fn shrinkAndFree(self: *Self, new_len: usize) void

        /// Reduce length to `new_len`.
        /// Invalidates element pointers for the elements `items[new_len..]`.
        /// Asserts that the new length is less than or equal to the previous length.
pub fn shrinkRetainingCapacity(self: *Self, new_len: usize) void

        /// Invalidates all element pointers.
pub fn clearRetainingCapacity(self: *Self) void

        /// Invalidates all element pointers.
pub fn clearAndFree(self: *Self) void

        /// If the current capacity is less than `new_capacity`, this function will
        /// modify the array so that it can hold at least `new_capacity` items.
        /// Invalidates element pointers if additional memory is needed.
pub fn ensureTotalCapacity(self: *Self, new_capacity: usize) Allocator.Error!void

        /// If the current capacity is less than `new_capacity`, this function will
        /// modify the array so that it can hold exactly `new_capacity` items.
        /// Invalidates element pointers if additional memory is needed.
pub fn ensureTotalCapacityPrecise(self: *Self, new_capacity: usize) Allocator.Error!void

        /// Modify the array so that it can hold at least `additional_count` **more** items.
        /// Invalidates element pointers if additional memory is needed.
pub fn ensureUnusedCapacity(self: *Self, additional_count: usize) Allocator.Error!void

        /// Increases the array's length to match the full capacity that is already allocated.
        /// The new elements have `undefined` values.
        /// Never invalidates element pointers.
pub fn expandToCapacity(self: *Self) void

        /// Increase length by 1, returning pointer to the new item.
        /// The returned pointer becomes invalid when the list resized.
pub fn addOne(self: *Self) Allocator.Error!*T

        /// Increase length by 1, returning pointer to the new item.
        /// The returned pointer becomes invalid when the list is resized.
        /// Never invalidates element pointers.
        /// Asserts that the list can hold one additional item.
pub fn addOneAssumeCapacity(self: *Self) *T

        /// Resize the array, adding `n` new elements, which have `undefined` values.
        /// The return value is an array pointing to the newly allocated elements.
        /// The returned pointer becomes invalid when the list is resized.
        /// Resizes list if `self.capacity` is not large enough.
pub fn addManyAsArray(self: *Self, comptime n: usize) Allocator.Error!*[n]T

        /// Resize the array, adding `n` new elements, which have `undefined` values.
        /// The return value is an array pointing to the newly allocated elements.
        /// Never invalidates element pointers.
        /// The returned pointer becomes invalid when the list is resized.
        /// Asserts that the list can hold the additional items.
pub fn addManyAsArrayAssumeCapacity(self: *Self, comptime n: usize) *[n]T

        /// Resize the array, adding `n` new elements, which have `undefined` values.
        /// The return value is a slice pointing to the newly allocated elements.
        /// The returned pointer becomes invalid when the list is resized.
        /// Resizes list if `self.capacity` is not large enough.
pub fn addManyAsSlice(self: *Self, n: usize) Allocator.Error![]T

        /// Resize the array, adding `n` new elements, which have `undefined` values.
        /// The return value is a slice pointing to the newly allocated elements.
        /// Never invalidates element pointers.
        /// The returned pointer becomes invalid when the list is resized.
        /// Asserts that the list can hold the additional items.
pub fn addManyAsSliceAssumeCapacity(self: *Self, n: usize) []T

        /// Remove and return the last element from the list, or return `null` if list is empty.
        /// Invalidates element pointers to the removed element, if any.
pub fn pop(self: *Self) ?T

        /// Returns a slice of all the items plus the extra capacity, whose memory
        /// contents are `undefined`.
pub fn allocatedSlice(self: Self) Slice

        /// Returns a slice of only the extra capacity after items.
        /// This can be useful for writing directly into an ArrayList.
        /// Note that such an operation must be followed up with a direct
        /// modification of `self.items.len`.
pub fn unusedCapacitySlice(self: Self) []T

        /// Returns the last element from the list.
        /// Asserts that the list is not empty.
pub fn getLast(self: Self) T

        /// Returns the last element from the list, or `null` if list is empty.
pub fn getLastOrNull(self: Self) ?T

/// A contiguous, growable list of arbitrarily aligned items in memory.
/// This is a wrapper around an array of T values aligned to `alignment`-byte
/// addresses. If the specified alignment is `null`, then `@alignOf(T)` is used.
///
/// Functions that potentially allocate memory accept an `Allocator` parameter.
/// Initialize directly or with `initCapacity`, and deinitialize with `deinit`
/// or use `toOwnedSlice`.
///
/// Default initialization of this struct is deprecated; use `.empty` instead.
pub fn Aligned(comptime T: type, comptime alignment: ?mem.Alignment) type

pub fn SentinelSlice(comptime s: T) type

        /// Initialize with capacity to hold `num` elements.
        /// The resulting capacity will equal `num` exactly.
        /// Deinitialize with `deinit` or use `toOwnedSlice`.
pub fn initCapacity(gpa: Allocator, num: usize) Allocator.Error!Self

        /// Initialize with externally-managed memory. The buffer determines the
        /// capacity, and the length is set to zero.
        ///
        /// When initialized this way, all functions that accept an Allocator
        /// argument cause illegal behavior.
pub fn initBuffer(buffer: Slice) Self

        /// Release all allocated memory.
pub fn deinit(self: *Self, gpa: Allocator) void

        /// Convert this list into an analogous memory-managed one.
        /// The returned list has ownership of the underlying memory.
pub fn toManaged(self: *Self, gpa: Allocator) AlignedManaged(T, alignment)

        /// ArrayList takes ownership of the passed in slice.
        /// Deinitialize with `deinit` or use `toOwnedSlice`.
pub fn fromOwnedSlice(slice: Slice) Self

        /// ArrayList takes ownership of the passed in slice.
        /// Deinitialize with `deinit` or use `toOwnedSlice`.
pub fn fromOwnedSliceSentinel(comptime sentinel: T, slice: [:sentinel]T) Self

        /// The caller owns the returned memory. Empties this ArrayList.
        /// Its capacity is cleared, making deinit() safe but unnecessary to call.
pub fn toOwnedSlice(self: *Self, gpa: Allocator) Allocator.Error!Slice

        /// The caller owns the returned memory. ArrayList becomes empty.
pub fn toOwnedSliceSentinel(self: *Self, gpa: Allocator, comptime sentinel: T) Allocator.Error!SentinelSlice(sentinel)

        /// Creates a copy of this ArrayList.
pub fn clone(self: Self, gpa: Allocator) Allocator.Error!Self

        /// Insert `item` at index `i`. Moves `list[i .. list.len]` to higher indices to make room.
        /// If `i` is equal to the length of the list this operation is equivalent to append.
        /// This operation is O(N).
        /// Invalidates element pointers if additional memory is needed.
        /// Asserts that the index is in bounds or equal to the length.
pub fn insert(self: *Self, gpa: Allocator, i: usize, item: T) Allocator.Error!void

        /// Insert `item` at index `i`. Moves `list[i .. list.len]` to higher indices to make room.
        ///
        /// If `i` is equal to the length of the list this operation is equivalent to append.
        ///
        /// This operation is O(N).
        ///
        /// Asserts that the list has capacity for one additional item.
        ///
        /// Asserts that the index is in bounds or equal to the length.
pub fn insertAssumeCapacity(self: *Self, i: usize, item: T) void

        /// Insert `item` at index `i`, moving `list[i .. list.len]` to higher indices to make room.
        ///
        /// If `i` is equal to the length of the list this operation is equivalent to append.
        ///
        /// This operation is O(N).
        ///
        /// If the list lacks unused capacity for the additional item, returns
        /// `error.OutOfMemory`.
        ///
        /// Asserts that the index is in bounds or equal to the length.
pub fn insertBounded(self: *Self, i: usize, item: T) error

        /// Add `count` new elements at position `index`, which have
        /// `undefined` values. Returns a slice pointing to the newly allocated
        /// elements, which becomes invalid after various `ArrayList`
        /// operations.
        /// Invalidates pre-existing pointers to elements at and after `index`.
        /// Invalidates all pre-existing element pointers if capacity must be
        /// increased to accommodate the new elements.
        /// Asserts that the index is in bounds or equal to the length.
pub fn addManyAt(

        /// Add `count` new elements at position `index`, which have
        /// `undefined` values. Returns a slice pointing to the newly allocated
        /// elements, which becomes invalid after various `ArrayList`
        /// operations.
        /// Invalidates pre-existing pointers to elements at and after `index`, but
        /// does not invalidate any before that.
        /// Asserts that the list has capacity for the additional items.
        /// Asserts that the index is in bounds or equal to the length.
pub fn addManyAtAssumeCapacity(self: *Self, index: usize, count: usize) []T

        /// Add `count` new elements at position `index`, which have
        /// `undefined` values, returning a slice pointing to the newly
        /// allocated elements, which becomes invalid after various `ArrayList`
        /// operations.
        ///
        /// Invalidates pre-existing pointers to elements at and after `index`, but
        /// does not invalidate any before that.
        ///
        /// If the list lacks unused capacity for the additional items, returns
        /// `error.OutOfMemory`.
        ///
        /// Asserts that the index is in bounds or equal to the length.
pub fn addManyAtBounded(self: *Self, index: usize, count: usize) error

        /// Insert slice `items` at index `i` by moving `list[i .. list.len]` to make room.
        /// This operation is O(N).
        /// Invalidates pre-existing pointers to elements at and after `index`.
        /// Invalidates all pre-existing element pointers if capacity must be
        /// increased to accommodate the new elements.
        /// Asserts that the index is in bounds or equal to the length.
pub fn insertSlice(

        /// Grows or shrinks the list as necessary.
        /// Invalidates element pointers if additional capacity is allocated.
        /// Asserts that the range is in bounds.
pub fn replaceRange(

        /// Grows or shrinks the list as necessary.
        ///
        /// Never invalidates element pointers.
        ///
        /// Asserts the capacity is enough for additional items.
pub fn replaceRangeAssumeCapacity(self: *Self, start: usize, len: usize, new_items: []const T) void

        /// Grows or shrinks the list as necessary.
        ///
        /// Never invalidates element pointers.
        ///
        /// If the unused capacity is insufficient for additional items,
        /// returns `error.OutOfMemory`.
pub fn replaceRangeBounded(self: *Self, start: usize, len: usize, new_items: []const T) error

        /// Extend the list by 1 element. Allocates more memory as necessary.
        /// Invalidates element pointers if additional memory is needed.
pub fn append(self: *Self, gpa: Allocator, item: T) Allocator.Error!void

        /// Extend the list by 1 element.
        ///
        /// Never invalidates element pointers.
        ///
        /// Asserts that the list can hold one additional item.
pub fn appendAssumeCapacity(self: *Self, item: T) void

        /// Extend the list by 1 element.
        ///
        /// Never invalidates element pointers.
        ///
        /// If the list lacks unused capacity for the additional item, returns
        /// `error.OutOfMemory`.
pub fn appendBounded(self: *Self, item: T) error

        /// Remove the element at index `i` from the list and return its value.
        /// Invalidates pointers to the last element.
        /// This operation is O(N).
        /// Asserts that the index is in bounds.
pub fn orderedRemove(self: *Self, i: usize) T

        /// Remove the elements indexed by `sorted_indexes`. The indexes to be
        /// removed correspond to the array list before deletion.
        ///
        /// Asserts:
        /// * Each index to be removed is in bounds.
        /// * The indexes to be removed are sorted ascending.
        ///
        /// Duplicates in `sorted_indexes` are allowed.
        ///
        /// This operation is O(N).
        ///
        /// Invalidates element pointers beyond the first deleted index.
pub fn orderedRemoveMany(self: *Self, sorted_indexes: []const usize) void

        /// Removes the element at the specified index and returns it.
        /// The empty slot is filled from the end of the list.
        /// Invalidates pointers to last element.
        /// This operation is O(1).
        /// Asserts that the list is not empty.
        /// Asserts that the index is in bounds.
pub fn swapRemove(self: *Self, i: usize) T

        /// Append the slice of items to the list. Allocates more
        /// memory as necessary.
        /// Invalidates element pointers if additional memory is needed.
pub fn appendSlice(self: *Self, gpa: Allocator, items: []const T) Allocator.Error!void

        /// Append the slice of items to the list.
        ///
        /// Asserts that the list can hold the additional items.
pub fn appendSliceAssumeCapacity(self: *Self, items: []const T) void

        /// Append the slice of items to the list.
        ///
        /// If the list lacks unused capacity for the additional items, returns `error.OutOfMemory`.
pub fn appendSliceBounded(self: *Self, items: []const T) error

        /// Append the slice of items to the list. Allocates more
        /// memory as necessary. Only call this function if a call to `appendSlice` instead would
        /// be a compile error.
        /// Invalidates element pointers if additional memory is needed.
pub fn appendUnalignedSlice(self: *Self, gpa: Allocator, items: []align(1) const T) Allocator.Error!void

        /// Append an unaligned slice of items to the list.
        ///
        /// Intended to be used only when `appendSliceAssumeCapacity` would be
        /// a compile error.
        ///
        /// Asserts that the list can hold the additional items.
pub fn appendUnalignedSliceAssumeCapacity(self: *Self, items: []align(1) const T) void

        /// Append an unaligned slice of items to the list.
        ///
        /// Intended to be used only when `appendSliceAssumeCapacity` would be
        /// a compile error.
        ///
        /// If the list lacks unused capacity for the additional items, returns
        /// `error.OutOfMemory`.
pub fn appendUnalignedSliceBounded(self: *Self, items: []align(1) const T) error

pub fn print(self: *Self, gpa: Allocator, comptime fmt: []const u8, args: anytype) error

pub fn printAssumeCapacity(self: *Self, comptime fmt: []const u8, args: anytype) void

pub fn printBounded(self: *Self, comptime fmt: []const u8, args: anytype) error

        /// Deprecated in favor of `print` or `std.io.Writer.Allocating`.
pub const WriterContext = struct {

        /// Deprecated in favor of `print` or `std.io.Writer.Allocating`.
pub fn writer(self: *Self, gpa: Allocator) Writer

        /// Deprecated in favor of `print` or `std.io.Writer.Allocating`.
pub fn fixedWriter(self: *Self) FixedWriter

        /// Append a value to the list `n` times.
        /// Allocates more memory as necessary.
        /// Invalidates element pointers if additional memory is needed.
        /// The function is inline so that a comptime-known `value` parameter will
        /// have a more optimal memset codegen in case it has a repeated byte pattern.
pub inline fn appendNTimes(self: *Self, gpa: Allocator, value: T, n: usize) Allocator.Error!void

        /// Append a value to the list `n` times.
        ///
        /// Never invalidates element pointers.
        ///
        /// The function is inline so that a comptime-known `value` parameter will
        /// have better memset codegen in case it has a repeated byte pattern.
        ///
        /// Asserts that the list can hold the additional items.
pub inline fn appendNTimesAssumeCapacity(self: *Self, value: T, n: usize) void

        /// Append a value to the list `n` times.
        ///
        /// Never invalidates element pointers.
        ///
        /// The function is inline so that a comptime-known `value` parameter will
        /// have better memset codegen in case it has a repeated byte pattern.
        ///
        /// If the list lacks unused capacity for the additional items, returns
        /// `error.OutOfMemory`.
pub inline fn appendNTimesBounded(self: *Self, value: T, n: usize) error

        /// Adjust the list length to `new_len`.
        /// Additional elements contain the value `undefined`.
        /// Invalidates element pointers if additional memory is needed.
pub fn resize(self: *Self, gpa: Allocator, new_len: usize) Allocator.Error!void

        /// Reduce allocated capacity to `new_len`.
        /// May invalidate element pointers.
        /// Asserts that the new length is less than or equal to the previous length.
pub fn shrinkAndFree(self: *Self, gpa: Allocator, new_len: usize) void

        /// Reduce length to `new_len`.
        /// Invalidates pointers to elements `items[new_len..]`.
        /// Keeps capacity the same.
        /// Asserts that the new length is less than or equal to the previous length.
pub fn shrinkRetainingCapacity(self: *Self, new_len: usize) void

        /// Invalidates all element pointers.
pub fn clearRetainingCapacity(self: *Self) void

        /// Invalidates all element pointers.
pub fn clearAndFree(self: *Self, gpa: Allocator) void

        /// Modify the array so that it can hold at least `new_capacity` items.
        /// Implements super-linear growth to achieve amortized O(1) append operations.
        /// Invalidates element pointers if additional memory is needed.
pub fn ensureTotalCapacity(self: *Self, gpa: Allocator, new_capacity: usize) Allocator.Error!void

        /// If the current capacity is less than `new_capacity`, this function will
        /// modify the array so that it can hold exactly `new_capacity` items.
        /// Invalidates element pointers if additional memory is needed.
pub fn ensureTotalCapacityPrecise(self: *Self, gpa: Allocator, new_capacity: usize) Allocator.Error!void

        /// Modify the array so that it can hold at least `additional_count` **more** items.
        /// Invalidates element pointers if additional memory is needed.
pub fn ensureUnusedCapacity(

        /// Increases the array's length to match the full capacity that is already allocated.
        /// The new elements have `undefined` values.
        /// Never invalidates element pointers.
pub fn expandToCapacity(self: *Self) void

        /// Increase length by 1, returning pointer to the new item.
        /// The returned element pointer becomes invalid when the list is resized.
pub fn addOne(self: *Self, gpa: Allocator) Allocator.Error!*T

        /// Increase length by 1, returning pointer to the new item.
        ///
        /// Never invalidates element pointers.
        ///
        /// The returned element pointer becomes invalid when the list is resized.
        ///
        /// Asserts that the list can hold one additional item.
pub fn addOneAssumeCapacity(self: *Self) *T

        /// Increase length by 1, returning pointer to the new item.
        ///
        /// Never invalidates element pointers.
        ///
        /// The returned element pointer becomes invalid when the list is resized.
        ///
        /// If the list lacks unused capacity for the additional item, returns `error.OutOfMemory`.
pub fn addOneBounded(self: *Self) error

        /// Resize the array, adding `n` new elements, which have `undefined` values.
        /// The return value is an array pointing to the newly allocated elements.
        /// The returned pointer becomes invalid when the list is resized.
pub fn addManyAsArray(self: *Self, gpa: Allocator, comptime n: usize) Allocator.Error!*[n]T

        /// Resize the array, adding `n` new elements, which have `undefined` values.
        ///
        /// The return value is an array pointing to the newly allocated elements.
        ///
        /// Never invalidates element pointers.
        ///
        /// The returned pointer becomes invalid when the list is resized.
        ///
        /// Asserts that the list can hold the additional items.
pub fn addManyAsArrayAssumeCapacity(self: *Self, comptime n: usize) *[n]T

        /// Resize the array, adding `n` new elements, which have `undefined` values.
        ///
        /// The return value is an array pointing to the newly allocated elements.
        ///
        /// Never invalidates element pointers.
        ///
        /// The returned pointer becomes invalid when the list is resized.
        ///
        /// If the list lacks unused capacity for the additional items, returns
        /// `error.OutOfMemory`.
pub fn addManyAsArrayBounded(self: *Self, comptime n: usize) error

        /// Resize the array, adding `n` new elements, which have `undefined` values.
        /// The return value is a slice pointing to the newly allocated elements.
        /// The returned pointer becomes invalid when the list is resized.
        /// Resizes list if `self.capacity` is not large enough.
pub fn addManyAsSlice(self: *Self, gpa: Allocator, n: usize) Allocator.Error![]T

        /// Resizes the array, adding `n` new elements, which have `undefined`
        /// values, returning a slice pointing to the newly allocated elements.
        ///
        /// Never invalidates element pointers. The returned pointer becomes
        /// invalid when the list is resized.
        ///
        /// Asserts that the list can hold the additional items.
pub fn addManyAsSliceAssumeCapacity(self: *Self, n: usize) []T

        /// Resizes the array, adding `n` new elements, which have `undefined`
        /// values, returning a slice pointing to the newly allocated elements.
        ///
        /// Never invalidates element pointers. The returned pointer becomes
        /// invalid when the list is resized.
        ///
        /// If the list lacks unused capacity for the additional items, returns
        /// `error.OutOfMemory`.
pub fn addManyAsSliceBounded(self: *Self, n: usize) error

        /// Remove and return the last element from the list.
        /// If the list is empty, returns `null`.
        /// Invalidates pointers to last element.
pub fn pop(self: *Self) ?T

        /// Returns a slice of all the items plus the extra capacity, whose memory
        /// contents are `undefined`.
pub fn allocatedSlice(self: Self) Slice

        /// Returns a slice of only the extra capacity after items.
        /// This can be useful for writing directly into an ArrayList.
        /// Note that such an operation must be followed up with a direct
        /// modification of `self.items.len`.
pub fn unusedCapacitySlice(self: Self) []T

        /// Return the last element from the list.
        /// Asserts that the list is not empty.
pub fn getLast(self: Self) T

        /// Return the last element from the list, or
        /// return `null` if list is empty.
pub fn getLastOrNull(self: Self) ?T
