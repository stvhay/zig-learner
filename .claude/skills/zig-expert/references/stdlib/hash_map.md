// Zig 0.15.2 std.hash_map — API signatures + doc comments

pub fn getAutoHashFn(comptime K: type, comptime Context: type) (fn (Context, K) u64)

pub fn getAutoEqlFn(comptime K: type, comptime Context: type) (fn (Context, K, K) bool)

pub fn AutoHashMap(comptime K: type, comptime V: type) type

pub fn AutoHashMapUnmanaged(comptime K: type, comptime V: type) type

pub fn AutoContext(comptime K: type) type

/// Builtin hashmap for strings as keys.
/// Key memory is managed by the caller.  Keys and values
/// will not automatically be freed.
pub fn StringHashMap(comptime V: type) type

/// Key memory is managed by the caller.  Keys and values
/// will not automatically be freed.
pub fn StringHashMapUnmanaged(comptime V: type) type

pub const StringContext = struct {

pub fn hash(self: @This(), s: []const u8) u64

pub fn eql(self: @This(), a: []const u8, b: []const u8) bool

pub fn eqlString(a: []const u8, b: []const u8) bool

pub fn hashString(s: []const u8) u64

pub const StringIndexContext = struct {

pub fn eql(_: @This(), a: u32, b: u32) bool

pub fn hash(ctx: @This(), key: u32) u64

pub const StringIndexAdapter = struct {

pub fn eql(ctx: @This(), a: []const u8, b: u32) bool

pub fn hash(_: @This(), adapted_key: []const u8) u64

/// General purpose hash table.
/// No order is guaranteed and any modification invalidates live iterators.
/// It provides fast operations (lookup, insertion, deletion) with quite high
/// load factors (up to 80% by default) for low memory usage.
/// For a hash map that can be initialized directly that does not store an Allocator
/// field, see `HashMapUnmanaged`.
/// If iterating over the table entries is a strong usecase and needs to be fast,
/// prefer the alternative `std.ArrayHashMap`.
/// Context must be a struct type with two member functions:
///   hash(self, K) u64
///   eql(self, K, K) bool
/// Adapted variants of many functions are provided.  These variants
/// take a pseudo key instead of a key.  Their context must have the functions:
///   hash(self, PseudoKey) u64
///   eql(self, PseudoKey, K) bool
pub fn HashMap(

        /// Create a managed hash map with an empty context.
        /// If the context is not zero-sized, you must use
        /// initContext(allocator, ctx) instead.
pub fn init(allocator: Allocator) Self

        /// Create a managed hash map with a context
pub fn initContext(allocator: Allocator, ctx: Context) Self

        /// Puts the hash map into a state where any method call that would
        /// cause an existing key or value pointer to become invalidated will
        /// instead trigger an assertion.
        ///
        /// An additional call to `lockPointers` in such state also triggers an
        /// assertion.
        ///
        /// `unlockPointers` returns the hash map to the previous state.
pub fn lockPointers(self: *Self) void

        /// Undoes a call to `lockPointers`.
pub fn unlockPointers(self: *Self) void

        /// Release the backing array and invalidate this map.
        /// This does *not* deinit keys, values, or the context!
        /// If your keys or values need to be released, ensure
        /// that that is done before calling this function.
pub fn deinit(self: *Self) void

        /// Empty the map, but keep the backing allocation for future use.
        /// This does *not* free keys or values! Be sure to
        /// release them if they need deinitialization before
        /// calling this function.
pub fn clearRetainingCapacity(self: *Self) void

        /// Empty the map and release the backing allocation.
        /// This does *not* free keys or values! Be sure to
        /// release them if they need deinitialization before
        /// calling this function.
pub fn clearAndFree(self: *Self) void

        /// Return the number of items in the map.
pub fn count(self: Self) Size

        /// Create an iterator over the entries in the map.
        /// The iterator is invalidated if the map is modified.
pub fn iterator(self: *const Self) Iterator

        /// Create an iterator over the keys in the map.
        /// The iterator is invalidated if the map is modified.
pub fn keyIterator(self: Self) KeyIterator

        /// Create an iterator over the values in the map.
        /// The iterator is invalidated if the map is modified.
pub fn valueIterator(self: Self) ValueIterator

        /// If key exists this function cannot fail.
        /// If there is an existing item with `key`, then the result's
        /// `Entry` pointers point to it, and found_existing is true.
        /// Otherwise, puts a new item with undefined value, and
        /// the `Entry` pointers point to it. Caller should then initialize
        /// the value (but not the key).
pub fn getOrPut(self: *Self, key: K) Allocator.Error!GetOrPutResult

        /// If key exists this function cannot fail.
        /// If there is an existing item with `key`, then the result's
        /// `Entry` pointers point to it, and found_existing is true.
        /// Otherwise, puts a new item with undefined key and value, and
        /// the `Entry` pointers point to it. Caller must then initialize
        /// the key and value.
pub fn getOrPutAdapted(self: *Self, key: anytype, ctx: anytype) Allocator.Error!GetOrPutResult

        /// If there is an existing item with `key`, then the result's
        /// `Entry` pointers point to it, and found_existing is true.
        /// Otherwise, puts a new item with undefined value, and
        /// the `Entry` pointers point to it. Caller should then initialize
        /// the value (but not the key).
        /// If a new entry needs to be stored, this function asserts there
        /// is enough capacity to store it.
pub fn getOrPutAssumeCapacity(self: *Self, key: K) GetOrPutResult

        /// If there is an existing item with `key`, then the result's
        /// `Entry` pointers point to it, and found_existing is true.
        /// Otherwise, puts a new item with undefined value, and
        /// the `Entry` pointers point to it. Caller must then initialize
        /// the key and value.
        /// If a new entry needs to be stored, this function asserts there
        /// is enough capacity to store it.
pub fn getOrPutAssumeCapacityAdapted(self: *Self, key: anytype, ctx: anytype) GetOrPutResult

pub fn getOrPutValue(self: *Self, key: K, value: V) Allocator.Error!Entry

        /// Increases capacity, guaranteeing that insertions up until the
        /// `expected_count` will not cause an allocation, and therefore cannot fail.
pub fn ensureTotalCapacity(self: *Self, expected_count: Size) Allocator.Error!void

        /// Increases capacity, guaranteeing that insertions up until
        /// `additional_count` **more** items will not cause an allocation, and
        /// therefore cannot fail.
pub fn ensureUnusedCapacity(self: *Self, additional_count: Size) Allocator.Error!void

        /// Returns the number of total elements which may be present before it is
        /// no longer guaranteed that no allocations will be performed.
pub fn capacity(self: Self) Size

        /// Clobbers any existing data. To detect if a put would clobber
        /// existing data, see `getOrPut`.
pub fn put(self: *Self, key: K, value: V) Allocator.Error!void

        /// Inserts a key-value pair into the hash map, asserting that no previous
        /// entry with the same key is already present
pub fn putNoClobber(self: *Self, key: K, value: V) Allocator.Error!void

        /// Asserts there is enough capacity to store the new key-value pair.
        /// Clobbers any existing data. To detect if a put would clobber
        /// existing data, see `getOrPutAssumeCapacity`.
pub fn putAssumeCapacity(self: *Self, key: K, value: V) void

        /// Asserts there is enough capacity to store the new key-value pair.
        /// Asserts that it does not clobber any existing data.
        /// To detect if a put would clobber existing data, see `getOrPutAssumeCapacity`.
pub fn putAssumeCapacityNoClobber(self: *Self, key: K, value: V) void

        /// Inserts a new `Entry` into the hash map, returning the previous one, if any.
pub fn fetchPut(self: *Self, key: K, value: V) Allocator.Error!?KV

        /// Inserts a new `Entry` into the hash map, returning the previous one, if any.
        /// If insertion happens, asserts there is enough capacity without allocating.
pub fn fetchPutAssumeCapacity(self: *Self, key: K, value: V) ?KV

        /// Removes a value from the map and returns the removed kv pair.
pub fn fetchRemove(self: *Self, key: K) ?KV

pub fn fetchRemoveAdapted(self: *Self, key: anytype, ctx: anytype) ?KV

        /// Finds the value associated with a key in the map
pub fn get(self: Self, key: K) ?V

pub fn getAdapted(self: Self, key: anytype, ctx: anytype) ?V

pub fn getPtr(self: Self, key: K) ?*V

pub fn getPtrAdapted(self: Self, key: anytype, ctx: anytype) ?*V

        /// Finds the actual key associated with an adapted key in the map
pub fn getKey(self: Self, key: K) ?K

pub fn getKeyAdapted(self: Self, key: anytype, ctx: anytype) ?K

pub fn getKeyPtr(self: Self, key: K) ?*K

pub fn getKeyPtrAdapted(self: Self, key: anytype, ctx: anytype) ?*K

        /// Finds the key and value associated with a key in the map
pub fn getEntry(self: Self, key: K) ?Entry

pub fn getEntryAdapted(self: Self, key: anytype, ctx: anytype) ?Entry

        /// Check if the map contains a key
pub fn contains(self: Self, key: K) bool

pub fn containsAdapted(self: Self, key: anytype, ctx: anytype) bool

        /// If there is an `Entry` with a matching key, it is deleted from
        /// the hash map, and this function returns true.  Otherwise this
        /// function returns false.
        ///
        /// TODO: answer the question in these doc comments, does this
        /// increase the unused capacity by one?
pub fn remove(self: *Self, key: K) bool

        /// TODO: answer the question in these doc comments, does this
        /// increase the unused capacity by one?
pub fn removeAdapted(self: *Self, key: anytype, ctx: anytype) bool

        /// Delete the entry with key pointed to by key_ptr from the hash map.
        /// key_ptr is assumed to be a valid pointer to a key that is present
        /// in the hash map.
        ///
        /// TODO: answer the question in these doc comments, does this
        /// increase the unused capacity by one?
pub fn removeByPtr(self: *Self, key_ptr: *K) void

        /// Creates a copy of this map, using the same allocator
pub fn clone(self: Self) Allocator.Error!Self

        /// Creates a copy of this map, using a specified allocator
pub fn cloneWithAllocator(self: Self, new_allocator: Allocator) Allocator.Error!Self

        /// Creates a copy of this map, using a specified context
pub fn cloneWithContext(self: Self, new_ctx: anytype) Allocator.Error!HashMap(K, V, @TypeOf(new_ctx), max_load_percentage)

        /// Creates a copy of this map, using a specified allocator and context.
pub fn cloneWithAllocatorAndContext(

        /// Set the map to an empty state, making deinitialization a no-op, and
        /// returning a copy of the original.
pub fn move(self: *Self) Self

        /// Rehash the map, in-place.
        ///
        /// Over time, due to the current tombstone-based implementation, a
        /// HashMap could become fragmented due to the buildup of tombstone
        /// entries that causes a performance degradation due to excessive
        /// probing. The kind of pattern that might cause this is a long-lived
        /// HashMap with repeated inserts and deletes.
        ///
        /// After this function is called, there will be no tombstones in
        /// the HashMap, each of the entries is rehashed and any existing
        /// key/value pointers into the HashMap are invalidated.
pub fn rehash(self: *Self) void

/// A HashMap based on open addressing and linear probing.
/// A lookup or modification typically incurs only 2 cache misses.
/// No order is guaranteed and any modification invalidates live iterators.
/// It achieves good performance with quite high load factors (by default,
/// grow is triggered at 80% full) and only one byte of overhead per element.
/// The struct itself is only 16 bytes for a small footprint. This comes at
/// the price of handling size with u32, which should be reasonable enough
/// for almost all uses.
/// Deletions are achieved with tombstones.
///
/// Default initialization of this struct is deprecated; use `.empty` instead.
pub fn HashMapUnmanaged(

pub const Entry = struct {

pub const KV = struct {

pub fn isUsed(self: Metadata) bool

pub fn isTombstone(self: Metadata) bool

pub fn isFree(self: Metadata) bool

pub fn takeFingerprint(hash: Hash) FingerPrint

pub fn fill(self: *Metadata, fp: FingerPrint) void

pub fn remove(self: *Metadata) void

pub const Iterator = struct {

pub fn next(it: *Iterator) ?Entry

pub fn next(self: *@This()) ?*T

pub const GetOrPutResult = struct {

pub fn promote(self: Self, allocator: Allocator) Managed

pub fn promoteContext(self: Self, allocator: Allocator, ctx: Context) Managed

        /// Puts the hash map into a state where any method call that would
        /// cause an existing key or value pointer to become invalidated will
        /// instead trigger an assertion.
        ///
        /// An additional call to `lockPointers` in such state also triggers an
        /// assertion.
        ///
        /// `unlockPointers` returns the hash map to the previous state.
pub fn lockPointers(self: *Self) void

        /// Undoes a call to `lockPointers`.
pub fn unlockPointers(self: *Self) void

pub fn deinit(self: *Self, allocator: Allocator) void

pub fn ensureTotalCapacity(self: *Self, allocator: Allocator, new_size: Size) Allocator.Error!void

pub fn ensureTotalCapacityContext(self: *Self, allocator: Allocator, new_size: Size, ctx: Context) Allocator.Error!void

pub fn ensureUnusedCapacity(self: *Self, allocator: Allocator, additional_size: Size) Allocator.Error!void

pub fn ensureUnusedCapacityContext(self: *Self, allocator: Allocator, additional_size: Size, ctx: Context) Allocator.Error!void

pub fn clearRetainingCapacity(self: *Self) void

pub fn clearAndFree(self: *Self, allocator: Allocator) void

pub fn count(self: Self) Size

pub fn capacity(self: Self) Size

pub fn iterator(self: *const Self) Iterator

pub fn keyIterator(self: Self) KeyIterator

pub fn valueIterator(self: Self) ValueIterator

        /// Insert an entry in the map. Assumes it is not already present.
pub fn putNoClobber(self: *Self, allocator: Allocator, key: K, value: V) Allocator.Error!void

pub fn putNoClobberContext(self: *Self, allocator: Allocator, key: K, value: V, ctx: Context) Allocator.Error!void

        /// Asserts there is enough capacity to store the new key-value pair.
        /// Clobbers any existing data. To detect if a put would clobber
        /// existing data, see `getOrPutAssumeCapacity`.
pub fn putAssumeCapacity(self: *Self, key: K, value: V) void

pub fn putAssumeCapacityContext(self: *Self, key: K, value: V, ctx: Context) void

        /// Insert an entry in the map. Assumes it is not already present,
        /// and that no allocation is needed.
pub fn putAssumeCapacityNoClobber(self: *Self, key: K, value: V) void

pub fn putAssumeCapacityNoClobberContext(self: *Self, key: K, value: V, ctx: Context) void

        /// Inserts a new `Entry` into the hash map, returning the previous one, if any.
pub fn fetchPut(self: *Self, allocator: Allocator, key: K, value: V) Allocator.Error!?KV

pub fn fetchPutContext(self: *Self, allocator: Allocator, key: K, value: V, ctx: Context) Allocator.Error!?KV

        /// Inserts a new `Entry` into the hash map, returning the previous one, if any.
        /// If insertion happens, asserts there is enough capacity without allocating.
pub fn fetchPutAssumeCapacity(self: *Self, key: K, value: V) ?KV

pub fn fetchPutAssumeCapacityContext(self: *Self, key: K, value: V, ctx: Context) ?KV

        /// If there is an `Entry` with a matching key, it is deleted from
        /// the hash map, and then returned from this function.
pub fn fetchRemove(self: *Self, key: K) ?KV

pub fn fetchRemoveContext(self: *Self, key: K, ctx: Context) ?KV

pub fn fetchRemoveAdapted(self: *Self, key: anytype, ctx: anytype) ?KV

pub fn getEntry(self: Self, key: K) ?Entry

pub fn getEntryContext(self: Self, key: K, ctx: Context) ?Entry

pub fn getEntryAdapted(self: Self, key: anytype, ctx: anytype) ?Entry

        /// Insert an entry if the associated key is not already present, otherwise update preexisting value.
pub fn put(self: *Self, allocator: Allocator, key: K, value: V) Allocator.Error!void

pub fn putContext(self: *Self, allocator: Allocator, key: K, value: V, ctx: Context) Allocator.Error!void

        /// Get an optional pointer to the actual key associated with adapted key, if present.
pub fn getKeyPtr(self: Self, key: K) ?*K

pub fn getKeyPtrContext(self: Self, key: K, ctx: Context) ?*K

pub fn getKeyPtrAdapted(self: Self, key: anytype, ctx: anytype) ?*K

        /// Get a copy of the actual key associated with adapted key, if present.
pub fn getKey(self: Self, key: K) ?K

pub fn getKeyContext(self: Self, key: K, ctx: Context) ?K

pub fn getKeyAdapted(self: Self, key: anytype, ctx: anytype) ?K

        /// Get an optional pointer to the value associated with key, if present.
pub fn getPtr(self: Self, key: K) ?*V

pub fn getPtrContext(self: Self, key: K, ctx: Context) ?*V

pub fn getPtrAdapted(self: Self, key: anytype, ctx: anytype) ?*V

        /// Get a copy of the value associated with key, if present.
pub fn get(self: Self, key: K) ?V

pub fn getContext(self: Self, key: K, ctx: Context) ?V

pub fn getAdapted(self: Self, key: anytype, ctx: anytype) ?V

pub fn getOrPut(self: *Self, allocator: Allocator, key: K) Allocator.Error!GetOrPutResult

pub fn getOrPutContext(self: *Self, allocator: Allocator, key: K, ctx: Context) Allocator.Error!GetOrPutResult

pub fn getOrPutAdapted(self: *Self, allocator: Allocator, key: anytype, key_ctx: anytype) Allocator.Error!GetOrPutResult

pub fn getOrPutContextAdapted(self: *Self, allocator: Allocator, key: anytype, key_ctx: anytype, ctx: Context) Allocator.Error!GetOrPutResult

pub fn getOrPutAssumeCapacity(self: *Self, key: K) GetOrPutResult

pub fn getOrPutAssumeCapacityContext(self: *Self, key: K, ctx: Context) GetOrPutResult

pub fn getOrPutAssumeCapacityAdapted(self: *Self, key: anytype, ctx: anytype) GetOrPutResult

pub fn getOrPutValue(self: *Self, allocator: Allocator, key: K, value: V) Allocator.Error!Entry

pub fn getOrPutValueContext(self: *Self, allocator: Allocator, key: K, value: V, ctx: Context) Allocator.Error!Entry

        /// Return true if there is a value associated with key in the map.
pub fn contains(self: Self, key: K) bool

pub fn containsContext(self: Self, key: K, ctx: Context) bool

pub fn containsAdapted(self: Self, key: anytype, ctx: anytype) bool

        /// If there is an `Entry` with a matching key, it is deleted from
        /// the hash map, and this function returns true.  Otherwise this
        /// function returns false.
        ///
        /// TODO: answer the question in these doc comments, does this
        /// increase the unused capacity by one?
pub fn remove(self: *Self, key: K) bool

        /// TODO: answer the question in these doc comments, does this
        /// increase the unused capacity by one?
pub fn removeContext(self: *Self, key: K, ctx: Context) bool

        /// TODO: answer the question in these doc comments, does this
        /// increase the unused capacity by one?
pub fn removeAdapted(self: *Self, key: anytype, ctx: anytype) bool

        /// Delete the entry with key pointed to by key_ptr from the hash map.
        /// key_ptr is assumed to be a valid pointer to a key that is present
        /// in the hash map.
        ///
        /// TODO: answer the question in these doc comments, does this
        /// increase the unused capacity by one?
pub fn removeByPtr(self: *Self, key_ptr: *K) void

pub fn clone(self: Self, allocator: Allocator) Allocator.Error!Self

pub fn cloneContext(self: Self, allocator: Allocator, new_ctx: anytype) Allocator.Error!HashMapUnmanaged(K, V, @TypeOf(new_ctx), max_load_percentage)

        /// Set the map to an empty state, making deinitialization a no-op, and
        /// returning a copy of the original.
pub fn move(self: *Self) Self

        /// Rehash the map, in-place.
        ///
        /// Over time, due to the current tombstone-based implementation, a
        /// HashMap could become fragmented due to the buildup of tombstone
        /// entries that causes a performance degradation due to excessive
        /// probing. The kind of pattern that might cause this is a long-lived
        /// HashMap with repeated inserts and deletes.
        ///
        /// After this function is called, there will be no tombstones in
        /// the HashMap, each of the entries is rehashed and any existing
        /// key/value pointers into the HashMap are invalidated.
pub fn rehash(self: *Self, ctx: anytype) void
