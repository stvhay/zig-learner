// Zig 0.15.2 std.mem — API signatures + doc comments

/// Stored as a power-of-two.
pub const Alignment = enum(math.Log2Int(usize)) {

pub fn toByteUnits(a: Alignment) usize

pub fn fromByteUnits(n: usize) Alignment

pub inline fn of(comptime T: type) Alignment

pub fn order(lhs: Alignment, rhs: Alignment) std.math.Order

pub fn compare(lhs: Alignment, op: std.math.CompareOperator, rhs: Alignment) bool

pub fn max(lhs: Alignment, rhs: Alignment) Alignment

pub fn min(lhs: Alignment, rhs: Alignment) Alignment

    /// Return next address with this alignment.
pub fn forward(a: Alignment, address: usize) usize

    /// Return previous address with this alignment.
pub fn backward(a: Alignment, address: usize) usize

    /// Return whether address is aligned to this amount.
pub fn check(a: Alignment, address: usize) bool

/// Detects and asserts if the std.mem.Allocator interface is violated by the caller
/// or the allocator.
pub fn ValidationAllocator(comptime T: type) type

pub fn init(underlying_allocator: T) @This()

pub fn allocator(self: *Self) Allocator

pub fn alloc(

pub fn resize(

pub fn remap(

pub fn free(

pub fn reset(self: *Self) void

pub fn validationWrap(allocator: anytype) ValidationAllocator(@TypeOf(allocator))

/// Copy all of source into dest at position 0.
/// dest.len must be >= source.len.
/// If the slices overlap, dest.ptr must be <= src.ptr.
/// This function is deprecated; use @memmove instead.
pub fn copyForwards(comptime T: type, dest: []T, source: []const T) void

/// Copy all of source into dest at position 0.
/// dest.len must be >= source.len.
/// If the slices overlap, dest.ptr must be >= src.ptr.
/// This function is deprecated; use @memmove instead.
pub fn copyBackwards(comptime T: type, dest: []T, source: []const T) void

/// Generally, Zig users are encouraged to explicitly initialize all fields of a struct explicitly rather than using this function.
/// However, it is recognized that there are sometimes use cases for initializing all fields to a "zero" value. For example, when
/// interfacing with a C API where this practice is more common and relied upon. If you are performing code review and see this
/// function used, examine closely - it may be a code smell.
/// Zero initializes the type.
/// This can be used to zero-initialize any type for which it makes sense. Structs will be initialized recursively.
pub fn zeroes(comptime T: type) T

/// Initializes all fields of the struct with their default value, or zero values if no default value is present.
/// If the field is present in the provided initial values, it will have that value instead.
/// Structs are initialized recursively.
pub fn zeroInit(comptime T: type, init: anytype) T

pub fn sort(

pub fn sortUnstable(

/// TODO: currently this just calls `insertionSortContext`. The block sort implementation
/// in this file needs to be adapted to use the sort context.
pub fn sortContext(a: usize, b: usize, context: anytype) void

pub fn sortUnstableContext(a: usize, b: usize, context: anytype) void

/// Compares two slices of numbers lexicographically. O(n).
pub fn order(comptime T: type, lhs: []const T, rhs: []const T) math.Order

/// Compares two many-item pointers with NUL-termination lexicographically.
pub fn orderZ(comptime T: type, lhs: [*:0]const T, rhs: [*:0]const T) math.Order

/// Returns true if lhs < rhs, false otherwise
pub fn lessThan(comptime T: type, lhs: []const T, rhs: []const T) bool

/// Returns true if and only if the slices have the same length and all elements
/// compare true using equality operator.
pub fn eql(comptime T: type, a: []const T, b: []const T) bool

pub inline fn isNotEqual(chunk_a: Chunk, chunk_b: Chunk) bool

pub inline fn isNotEqual(chunk_a: Chunk, chunk_b: Chunk) bool

/// Compares two slices and returns the index of the first inequality.
/// Returns null if the slices are equal.
pub fn indexOfDiff(comptime T: type, a: []const T, b: []const T) ?usize

/// Takes a sentinel-terminated pointer and returns a slice, iterating over the
/// memory to find the sentinel and determine the length.
/// Pointer attributes such as const are preserved.
/// `[*c]` pointers are assumed to be non-null and 0-terminated.
pub fn span(ptr: anytype) Span(@TypeOf(ptr))

/// Takes a pointer to an array, a sentinel-terminated pointer, or a slice and iterates searching for
/// the first occurrence of `end`, returning the scanned slice.
/// If `end` is not found, the full length of the array/slice/sentinel terminated pointer is returned.
/// If the pointer type is sentinel terminated and `end` matches that terminator, the
/// resulting slice is also sentinel terminated.
/// Pointer properties such as mutability and alignment are preserved.
/// C pointers are assumed to be non-null.
pub fn sliceTo(ptr: anytype, comptime end: std.meta.Elem(@TypeOf(ptr))) SliceTo(@TypeOf(ptr), end)

/// Takes a sentinel-terminated pointer and iterates over the memory to find the
/// sentinel and determine the length.
/// `[*c]` pointers are assumed to be non-null and 0-terminated.
pub fn len(value: anytype) usize

pub fn indexOfSentinel(comptime T: type, comptime sentinel: T, p: [*:sentinel]const T) usize

/// Returns true if all elements in a slice are equal to the scalar value provided
pub fn allEqual(comptime T: type, slice: []const T, scalar: T) bool

/// Remove a set of values from the beginning of a slice.
pub fn trimStart(comptime T: type, slice: []const T, values_to_strip: []const T) []const T

/// Remove a set of values from the end of a slice.
pub fn trimEnd(comptime T: type, slice: []const T, values_to_strip: []const T) []const T

/// Remove a set of values from the beginning and end of a slice.
pub fn trim(comptime T: type, slice: []const T, values_to_strip: []const T) []const T

/// Linear search for the index of a scalar value inside a slice.
pub fn indexOfScalar(comptime T: type, slice: []const T, value: T) ?usize

/// Linear search for the last index of a scalar value inside a slice.
pub fn lastIndexOfScalar(comptime T: type, slice: []const T, value: T) ?usize

pub fn indexOfScalarPos(comptime T: type, slice: []const T, start_index: usize, value: T) ?usize

pub fn indexOfAny(comptime T: type, slice: []const T, values: []const T) ?usize

pub fn lastIndexOfAny(comptime T: type, slice: []const T, values: []const T) ?usize

pub fn indexOfAnyPos(comptime T: type, slice: []const T, start_index: usize, values: []const T) ?usize

/// Find the first item in `slice` which is not contained in `values`.
///
/// Comparable to `strspn` in the C standard library.
pub fn indexOfNone(comptime T: type, slice: []const T, values: []const T) ?usize

/// Find the last item in `slice` which is not contained in `values`.
///
/// Like `strspn` in the C standard library, but searches from the end.
pub fn lastIndexOfNone(comptime T: type, slice: []const T, values: []const T) ?usize

/// Find the first item in `slice[start_index..]` which is not contained in `values`.
/// The returned index will be relative to the start of `slice`, and never less than `start_index`.
///
/// Comparable to `strspn` in the C standard library.
pub fn indexOfNonePos(comptime T: type, slice: []const T, start_index: usize, values: []const T) ?usize

pub fn indexOf(comptime T: type, haystack: []const T, needle: []const T) ?usize

/// Find the index in a slice of a sub-slice, searching from the end backwards.
/// To start looking at a different index, slice the haystack first.
/// Consider using `lastIndexOf` instead of this, which will automatically use a
/// more sophisticated algorithm on larger inputs.
pub fn lastIndexOfLinear(comptime T: type, haystack: []const T, needle: []const T) ?usize

/// Consider using `indexOfPos` instead of this, which will automatically use a
/// more sophisticated algorithm on larger inputs.
pub fn indexOfPosLinear(comptime T: type, haystack: []const T, start_index: usize, needle: []const T) ?usize

/// Find the index in a slice of a sub-slice, searching from the end backwards.
/// To start looking at a different index, slice the haystack first.
/// Uses the Reverse Boyer-Moore-Horspool algorithm on large inputs;
/// `lastIndexOfLinear` on small inputs.
pub fn lastIndexOf(comptime T: type, haystack: []const T, needle: []const T) ?usize

/// Uses Boyer-Moore-Horspool algorithm on large inputs; `indexOfPosLinear` on small inputs.
pub fn indexOfPos(comptime T: type, haystack: []const T, start_index: usize, needle: []const T) ?usize

/// Returns the number of needles inside the haystack
/// needle.len must be > 0
/// does not count overlapping needles
pub fn count(comptime T: type, haystack: []const T, needle: []const T) usize

/// See also: `containsAtLeastScalar`
pub fn containsAtLeast(comptime T: type, haystack: []const T, expected_count: usize, needle: []const T) bool

/// See also: `containsAtLeast`
pub fn containsAtLeastScalar(comptime T: type, haystack: []const T, expected_count: usize, needle: T) bool

/// Reads an integer from memory with size equal to bytes.len.
/// T specifies the return type, which must be large enough to store
/// the result.
pub fn readVarInt(comptime ReturnType: type, bytes: []const u8, endian: Endian) ReturnType

/// Loads an integer from packed memory with provided bit_count, bit_offset, and signedness.
/// Asserts that T is large enough to store the read value.
pub fn readVarPackedInt(

/// Reads an integer from memory with bit count specified by T.
/// The bit count of T must be evenly divisible by 8.
/// This function cannot fail and cannot cause undefined behavior.
pub inline fn readInt(comptime T: type, buffer: *const [@divExact(@typeInfo(T).int.bits, 8)]u8, endian: Endian) T

/// Loads an integer from packed memory.
/// Asserts that buffer contains at least bit_offset + @bitSizeOf(T) bits.
pub fn readPackedInt(comptime T: type, bytes: []const u8, bit_offset: usize, endian: Endian) T

/// Writes an integer to memory, storing it in twos-complement.
/// This function always succeeds, has defined behavior for all inputs, but
/// the integer bit width must be divisible by 8.
pub inline fn writeInt(comptime T: type, buffer: *[@divExact(@typeInfo(T).int.bits, 8)]u8, value: T, endian: Endian) void

/// Stores an integer to packed memory.
/// Asserts that buffer contains at least bit_offset + @bitSizeOf(T) bits.
pub fn writePackedInt(comptime T: type, bytes: []u8, bit_offset: usize, value: T, endian: Endian) void

/// Stores an integer to packed memory with provided bit_offset, bit_count, and signedness.
/// If negative, the written value is sign-extended.
pub fn writeVarPackedInt(bytes: []u8, bit_offset: usize, bit_count: usize, value: anytype, endian: std.builtin.Endian) void

/// Swap the byte order of all the members of the fields of a struct
/// (Changing their endianness)
pub fn byteSwapAllFields(comptime S: type, ptr: *S) void

pub fn byteSwapAllElements(comptime Elem: type, slice: []Elem) void

/// Returns an iterator that iterates over the slices of `buffer` that are not
/// any of the items in `delimiters`.
///
/// `tokenizeAny(u8, "   abc|def ||  ghi  ", " |")` will return slices
/// for "abc", "def", "ghi", null, in that order.
///
/// If `buffer` is empty, the iterator will return null.
/// If none of `delimiters` exist in buffer,
/// the iterator will return `buffer`, null, in that order.
///
/// See also: `tokenizeSequence`, `tokenizeScalar`,
///           `splitSequence`,`splitAny`, `splitScalar`,
///           `splitBackwardsSequence`, `splitBackwardsAny`, and `splitBackwardsScalar`
pub fn tokenizeAny(comptime T: type, buffer: []const T, delimiters: []const T) TokenIterator(T, .any)

/// Returns an iterator that iterates over the slices of `buffer` that are not
/// the sequence in `delimiter`.
///
/// `tokenizeSequence(u8, "<>abc><def<><>ghi", "<>")` will return slices
/// for "abc><def", "ghi", null, in that order.
///
/// If `buffer` is empty, the iterator will return null.
/// If `delimiter` does not exist in buffer,
/// the iterator will return `buffer`, null, in that order.
/// The delimiter length must not be zero.
///
/// See also: `tokenizeAny`, `tokenizeScalar`,
///           `splitSequence`,`splitAny`, and `splitScalar`
///           `splitBackwardsSequence`, `splitBackwardsAny`, and `splitBackwardsScalar`
pub fn tokenizeSequence(comptime T: type, buffer: []const T, delimiter: []const T) TokenIterator(T, .sequence)

/// Returns an iterator that iterates over the slices of `buffer` that are not
/// `delimiter`.
///
/// `tokenizeScalar(u8, "   abc def     ghi  ", ' ')` will return slices
/// for "abc", "def", "ghi", null, in that order.
///
/// If `buffer` is empty, the iterator will return null.
/// If `delimiter` does not exist in buffer,
/// the iterator will return `buffer`, null, in that order.
///
/// See also: `tokenizeAny`, `tokenizeSequence`,
///           `splitSequence`,`splitAny`, and `splitScalar`
///           `splitBackwardsSequence`, `splitBackwardsAny`, and `splitBackwardsScalar`
pub fn tokenizeScalar(comptime T: type, buffer: []const T, delimiter: T) TokenIterator(T, .scalar)

/// Returns an iterator that iterates over the slices of `buffer` that
/// are separated by the byte sequence in `delimiter`.
///
/// `splitSequence(u8, "abc||def||||ghi", "||")` will return slices
/// for "abc", "def", "", "ghi", null, in that order.
///
/// If `delimiter` does not exist in buffer,
/// the iterator will return `buffer`, null, in that order.
/// The delimiter length must not be zero.
///
/// See also: `splitAny`, `splitScalar`, `splitBackwardsSequence`,
///           `splitBackwardsAny`,`splitBackwardsScalar`,
///           `tokenizeAny`, `tokenizeSequence`, and `tokenizeScalar`.
pub fn splitSequence(comptime T: type, buffer: []const T, delimiter: []const T) SplitIterator(T, .sequence)

/// Returns an iterator that iterates over the slices of `buffer` that
/// are separated by any item in `delimiters`.
///
/// `splitAny(u8, "abc,def||ghi", "|,")` will return slices
/// for "abc", "def", "", "ghi", null, in that order.
///
/// If none of `delimiters` exist in buffer,
/// the iterator will return `buffer`, null, in that order.
///
/// See also: `splitSequence`, `splitScalar`, `splitBackwardsSequence`,
///           `splitBackwardsAny`,`splitBackwardsScalar`,
///           `tokenizeAny`, `tokenizeSequence`, and `tokenizeScalar`.
pub fn splitAny(comptime T: type, buffer: []const T, delimiters: []const T) SplitIterator(T, .any)

/// Returns an iterator that iterates over the slices of `buffer` that
/// are separated by `delimiter`.
///
/// `splitScalar(u8, "abc|def||ghi", '|')` will return slices
/// for "abc", "def", "", "ghi", null, in that order.
///
/// If `delimiter` does not exist in buffer,
/// the iterator will return `buffer`, null, in that order.
///
/// See also: `splitSequence`, `splitAny`, `splitBackwardsSequence`,
///           `splitBackwardsAny`,`splitBackwardsScalar`,
///           `tokenizeAny`, `tokenizeSequence`, and `tokenizeScalar`.
pub fn splitScalar(comptime T: type, buffer: []const T, delimiter: T) SplitIterator(T, .scalar)

/// Returns an iterator that iterates backwards over the slices of `buffer` that
/// are separated by the sequence in `delimiter`.
///
/// `splitBackwardsSequence(u8, "abc||def||||ghi", "||")` will return slices
/// for "ghi", "", "def", "abc", null, in that order.
///
/// If `delimiter` does not exist in buffer,
/// the iterator will return `buffer`, null, in that order.
/// The delimiter length must not be zero.
///
/// See also: `splitBackwardsAny`, `splitBackwardsScalar`,
///           `splitSequence`, `splitAny`,`splitScalar`,
///           `tokenizeAny`, `tokenizeSequence`, and `tokenizeScalar`.
pub fn splitBackwardsSequence(comptime T: type, buffer: []const T, delimiter: []const T) SplitBackwardsIterator(T, .sequence)

/// Returns an iterator that iterates backwards over the slices of `buffer` that
/// are separated by any item in `delimiters`.
///
/// `splitBackwardsAny(u8, "abc,def||ghi", "|,")` will return slices
/// for "ghi", "", "def", "abc", null, in that order.
///
/// If none of `delimiters` exist in buffer,
/// the iterator will return `buffer`, null, in that order.
///
/// See also: `splitBackwardsSequence`, `splitBackwardsScalar`,
///           `splitSequence`, `splitAny`,`splitScalar`,
///           `tokenizeAny`, `tokenizeSequence`, and `tokenizeScalar`.
pub fn splitBackwardsAny(comptime T: type, buffer: []const T, delimiters: []const T) SplitBackwardsIterator(T, .any)

/// Returns an iterator that iterates backwards over the slices of `buffer` that
/// are separated by `delimiter`.
///
/// `splitBackwardsScalar(u8, "abc|def||ghi", '|')` will return slices
/// for "ghi", "", "def", "abc", null, in that order.
///
/// If `delimiter` does not exist in buffer,
/// the iterator will return `buffer`, null, in that order.
///
/// See also: `splitBackwardsSequence`, `splitBackwardsAny`,
///           `splitSequence`, `splitAny`,`splitScalar`,
///           `tokenizeAny`, `tokenizeSequence`, and `tokenizeScalar`.
pub fn splitBackwardsScalar(comptime T: type, buffer: []const T, delimiter: T) SplitBackwardsIterator(T, .scalar)

/// Returns an iterator with a sliding window of slices for `buffer`.
/// The sliding window has length `size` and on every iteration moves
/// forward by `advance`.
///
/// Extract data for moving average with:
/// `window(u8, "abcdefg", 3, 1)` will return slices
/// "abc", "bcd", "cde", "def", "efg", null, in that order.
///
/// Chunk or split every N items with:
/// `window(u8, "abcdefg", 3, 3)` will return slices
/// "abc", "def", "g", null, in that order.
///
/// Pick every even index with:
/// `window(u8, "abcdefg", 1, 2)` will return slices
/// "a", "c", "e", "g" null, in that order.
///
/// The `size` and `advance` must be not be zero.
pub fn window(comptime T: type, buffer: []const T, size: usize, advance: usize) WindowIterator(T)

pub fn WindowIterator(comptime T: type) type

        /// Returns a slice of the first window.
        /// Call this only to get the first window and then use `next` to get
        /// all subsequent windows.
        /// Asserts that iteration has not begun.
pub fn first(self: *Self) []const T

        /// Returns a slice of the next window, or null if window is at end.
pub fn next(self: *Self) ?[]const T

        /// Resets the iterator to the initial window.
pub fn reset(self: *Self) void

pub fn startsWith(comptime T: type, haystack: []const T, needle: []const T) bool

pub fn endsWith(comptime T: type, haystack: []const T, needle: []const T) bool

pub const DelimiterType = enum { sequence, any, scalar };

pub fn TokenIterator(comptime T: type, comptime delimiter_type: DelimiterType) type

        /// Returns a slice of the current token, or null if tokenization is
        /// complete, and advances to the next token.
pub fn next(self: *Self) ?[]const T

        /// Returns a slice of the current token, or null if tokenization is
        /// complete. Does not advance to the next token.
pub fn peek(self: *Self) ?[]const T

        /// Returns a slice of the remaining bytes. Does not affect iterator state.
pub fn rest(self: Self) []const T

        /// Resets the iterator to the initial token.
pub fn reset(self: *Self) void

pub fn SplitIterator(comptime T: type, comptime delimiter_type: DelimiterType) type

        /// Returns a slice of the first field.
        /// Call this only to get the first field and then use `next` to get all subsequent fields.
        /// Asserts that iteration has not begun.
pub fn first(self: *Self) []const T

        /// Returns a slice of the next field, or null if splitting is complete.
pub fn next(self: *Self) ?[]const T

        /// Returns a slice of the next field, or null if splitting is complete.
        /// This method does not alter self.index.
pub fn peek(self: *Self) ?[]const T

        /// Returns a slice of the remaining bytes. Does not affect iterator state.
pub fn rest(self: Self) []const T

        /// Resets the iterator to the initial slice.
pub fn reset(self: *Self) void

pub fn SplitBackwardsIterator(comptime T: type, comptime delimiter_type: DelimiterType) type

        /// Returns a slice of the first field.
        /// Call this only to get the first field and then use `next` to get all subsequent fields.
        /// Asserts that iteration has not begun.
pub fn first(self: *Self) []const T

        /// Returns a slice of the next field, or null if splitting is complete.
pub fn next(self: *Self) ?[]const T

        /// Returns a slice of the remaining bytes. Does not affect iterator state.
pub fn rest(self: Self) []const T

        /// Resets the iterator to the initial slice.
pub fn reset(self: *Self) void

/// Naively combines a series of slices with a separator.
/// Allocates memory for the result, which must be freed by the caller.
pub fn join(allocator: Allocator, separator: []const u8, slices: []const []const u8) Allocator.Error![]u8

/// Naively combines a series of slices with a separator and null terminator.
/// Allocates memory for the result, which must be freed by the caller.
pub fn joinZ(allocator: Allocator, separator: []const u8, slices: []const []const u8) Allocator.Error![:0]u8

/// Copies each T from slices into a new slice that exactly holds all the elements.
pub fn concat(allocator: Allocator, comptime T: type, slices: []const []const T) Allocator.Error![]T

/// Copies each T from slices into a new slice that exactly holds all the elements.
pub fn concatWithSentinel(allocator: Allocator, comptime T: type, slices: []const []const T, comptime s: T) Allocator.Error![:s]T

/// Copies each T from slices into a new slice that exactly holds all the elements as well as the sentinel.
pub fn concatMaybeSentinel(allocator: Allocator, comptime T: type, slices: []const []const T, comptime s: ?T) Allocator.Error![]T

/// Returns the smallest number in a slice. O(n).
/// `slice` must not be empty.
pub fn min(comptime T: type, slice: []const T) T

/// Returns the largest number in a slice. O(n).
/// `slice` must not be empty.
pub fn max(comptime T: type, slice: []const T) T

/// Finds the smallest and largest number in a slice. O(n).
/// Returns an anonymous struct with the fields `min` and `max`.
/// `slice` must not be empty.
pub fn minMax(comptime T: type, slice: []const T) struct

/// Returns the index of the smallest number in a slice. O(n).
/// `slice` must not be empty.
pub fn indexOfMin(comptime T: type, slice: []const T) usize

/// Returns the index of the largest number in a slice. O(n).
/// `slice` must not be empty.
pub fn indexOfMax(comptime T: type, slice: []const T) usize

/// Finds the indices of the smallest and largest number in a slice. O(n).
/// Returns the indices of the smallest and largest numbers in that order.
/// `slice` must not be empty.
pub fn indexOfMinMax(comptime T: type, slice: []const T) struct

pub fn swap(comptime T: type, a: *T, b: *T) void

/// In-place order reversal of a slice
pub fn reverse(comptime T: type, items: []T) void

pub fn next(self: *@This()) ?Element

pub fn nextPtr(self: *@This()) ?ElementPointer

/// Iterates over a slice in reverse.
pub fn reverseIterator(slice: anytype) ReverseIterator(@TypeOf(slice))

/// In-place rotation of the values in an array ([0 1 2 3] becomes [1 2 3 0] if we rotate by 1)
/// Assumes 0 <= amount <= items.len
pub fn rotate(comptime T: type, items: []T, amount: usize) void

/// Replace needle with replacement as many times as possible, writing to an output buffer which is assumed to be of
/// appropriate size. Use replacementSize to calculate an appropriate buffer size.
/// The `input` and `output` slices must not overlap.
/// The needle must not be empty.
/// Returns the number of replacements made.
pub fn replace(comptime T: type, input: []const T, needle: []const T, replacement: []const T, output: []T) usize

/// Replace all occurrences of `match` with `replacement`.
pub fn replaceScalar(comptime T: type, slice: []T, match: T, replacement: T) void

/// Collapse consecutive duplicate elements into one entry.
pub fn collapseRepeatsLen(comptime T: type, slice: []T, elem: T) usize

/// Collapse consecutive duplicate elements into one entry.
pub fn collapseRepeats(comptime T: type, slice: []T, elem: T) []T

/// Calculate the size needed in an output buffer to perform a replacement.
/// The needle must not be empty.
pub fn replacementSize(comptime T: type, input: []const T, needle: []const T, replacement: []const T) usize

/// Perform a replacement on an allocated buffer of pre-determined size. Caller must free returned memory.
pub fn replaceOwned(comptime T: type, allocator: Allocator, input: []const T, needle: []const T, replacement: []const T) Allocator.Error![]T

/// Converts a little-endian integer to host endianness.
pub fn littleToNative(comptime T: type, x: T) T

/// Converts a big-endian integer to host endianness.
pub fn bigToNative(comptime T: type, x: T) T

/// Converts an integer from specified endianness to host endianness.
pub fn toNative(comptime T: type, x: T, endianness_of_x: Endian) T

/// Converts an integer which has host endianness to the desired endianness.
pub fn nativeTo(comptime T: type, x: T, desired_endianness: Endian) T

/// Converts an integer which has host endianness to little endian.
pub fn nativeToLittle(comptime T: type, x: T) T

/// Converts an integer which has host endianness to big endian.
pub fn nativeToBig(comptime T: type, x: T) T

/// Returns the number of elements that, if added to the given pointer, align it
/// to a multiple of the given quantity, or `null` if one of the following
/// conditions is met:
/// - The aligned pointer would not fit the address space,
/// - The delta required to align the pointer is not a multiple of the pointee's
///   type.
pub fn alignPointerOffset(ptr: anytype, align_to: usize) ?usize

/// Aligns a given pointer value to a specified alignment factor.
/// Returns an aligned pointer or null if one of the following conditions is
/// met:
/// - The aligned pointer would not fit the address space,
/// - The delta required to align the pointer is not a multiple of the pointee's
///   type.
pub fn alignPointer(ptr: anytype, align_to: usize) ?@TypeOf(ptr)

/// Given a pointer to a single item, returns a slice of the underlying bytes, preserving pointer attributes.
pub fn asBytes(ptr: anytype) AsBytesReturnType(@TypeOf(ptr))

/// Given any value, returns a copy of its bytes in an array.
pub fn toBytes(value: anytype) [@sizeOf(@TypeOf(value))]u8

/// Given a pointer to an array of bytes, returns a pointer to a value of the specified type
/// backed by those bytes, preserving pointer attributes.
pub fn bytesAsValue(comptime T: type, bytes: anytype) BytesAsValueReturnType(T, @TypeOf(bytes))

/// Given a pointer to an array of bytes, returns a value of the specified type backed by a
/// copy of those bytes.
pub fn bytesToValue(comptime T: type, bytes: anytype) T

/// Given a slice of bytes, returns a slice of the specified type
/// backed by those bytes, preserving pointer attributes.
/// If `T` is zero-bytes sized, the returned slice has a len of zero.
pub fn bytesAsSlice(comptime T: type, bytes: anytype) BytesAsSliceReturnType(T, @TypeOf(bytes))

/// Given a slice, returns a slice of the underlying bytes, preserving pointer attributes.
pub fn sliceAsBytes(slice: anytype) SliceAsBytesReturnType(@TypeOf(slice))

/// Round an address down to the next (or current) aligned address.
/// Unlike `alignForward`, `alignment` can be any positive number, not just a power of 2.
pub fn alignForwardAnyAlign(comptime T: type, addr: T, alignment: T) T

/// Round an address up to the next (or current) aligned address.
/// The alignment must be a power of 2 and greater than 0.
/// Asserts that rounding up the address does not cause integer overflow.
pub fn alignForward(comptime T: type, addr: T, alignment: T) T

pub fn alignForwardLog2(addr: usize, log2_alignment: u8) usize

pub fn doNotOptimizeAway(val: anytype) void

/// Round an address down to the previous (or current) aligned address.
/// Unlike `alignBackward`, `alignment` can be any positive number, not just a power of 2.
pub fn alignBackwardAnyAlign(comptime T: type, addr: T, alignment: T) T

/// Round an address down to the previous (or current) aligned address.
/// The alignment must be a power of 2 and greater than 0.
pub fn alignBackward(comptime T: type, addr: T, alignment: T) T

/// Returns whether `alignment` is a valid alignment, meaning it is
/// a positive power of 2.
pub fn isValidAlign(alignment: usize) bool

/// Returns whether `alignment` is a valid alignment, meaning it is
/// a positive power of 2.
pub fn isValidAlignGeneric(comptime T: type, alignment: T) bool

pub fn isAlignedAnyAlign(i: usize, alignment: usize) bool

pub fn isAlignedLog2(addr: usize, log2_alignment: u8) bool

/// Given an address and an alignment, return true if the address is a multiple of the alignment
/// The alignment must be a power of 2 and greater than 0.
pub fn isAligned(addr: usize, alignment: usize) bool

pub fn isAlignedGeneric(comptime T: type, addr: T, alignment: T) bool

/// Returns the largest slice in the given bytes that conforms to the new alignment,
/// or `null` if the given bytes contain no conforming address.
pub fn alignInBytes(bytes: []u8, comptime new_alignment: usize) ?[]align(new_alignment) u8

/// Returns the largest sub-slice within the given slice that conforms to the new alignment,
/// or `null` if the given slice contains no conforming address.
pub fn alignInSlice(slice: anytype, comptime new_alignment: usize) ?AlignedSlice(@TypeOf(slice), new_alignment)
