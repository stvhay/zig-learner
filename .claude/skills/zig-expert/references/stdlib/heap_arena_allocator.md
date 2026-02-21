// Zig 0.15.2 std.heap.arena_allocator — API signatures + doc comments

/// This allocator takes an existing allocator, wraps it, and provides an interface where
/// you can allocate and then free it all together. Calls to free an individual item only
/// free the item if it was the most recent allocation, otherwise calls to free do
/// nothing.
pub const ArenaAllocator = struct {

    /// Inner state of ArenaAllocator. Can be stored rather than the entire ArenaAllocator
    /// as a memory-saving optimization.
pub const State = struct {

pub fn promote(self: State, child_allocator: Allocator) ArenaAllocator

pub fn allocator(self: *ArenaAllocator) Allocator

pub fn init(child_allocator: Allocator) ArenaAllocator

pub fn deinit(self: ArenaAllocator) void

pub const ResetMode = union(enum) {

    /// Queries the current memory use of this arena.
    /// This will **not** include the storage required for internal keeping.
pub fn queryCapacity(self: ArenaAllocator) usize

    /// Resets the arena allocator and frees all allocated memory.
    ///
    /// `mode` defines how the currently allocated memory is handled.
    /// See the variant documentation for `ResetMode` for the effects of each mode.
    ///
    /// The function will return whether the reset operation was successful or not.
    /// If the reallocation  failed `false` is returned. The arena will still be fully
    /// functional in that case, all memory is released. Future allocations just might
    /// be slower.
    ///
    /// NOTE: If `mode` is `free_all`, the function will always return `true`.
pub fn reset(self: *ArenaAllocator, mode: ResetMode) bool
