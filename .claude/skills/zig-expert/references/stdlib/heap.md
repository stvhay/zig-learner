// Zig 0.15.2 std.heap — API signatures + doc comments

pub const Check = enum { ok, leak };

/// If the page size is comptime-known, return value is comptime.
/// Otherwise, calls `std.options.queryPageSize` which by default queries the
/// host operating system at runtime.
pub inline fn pageSize() usize

/// The default implementation of `std.options.queryPageSize`.
/// Asserts that the page size is within `page_size_min` and `page_size_max`
pub fn defaultQueryPageSize() usize

/// Returns a `StackFallbackAllocator` allocating using either a
/// `FixedBufferAllocator` on an array of size `size` and falling back to
/// `fallback_allocator` if that fails.
pub fn stackFallback(comptime size: usize, fallback_allocator: Allocator) StackFallbackAllocator(size)

/// An allocator that attempts to allocate using a
/// `FixedBufferAllocator` using an array of size `size`. If the
/// allocation fails, it will fall back to using
/// `fallback_allocator`. Easily created with `stackFallback`.
pub fn StackFallbackAllocator(comptime size: usize) type

        /// This function both fetches a `Allocator` interface to this
        /// allocator *and* resets the internal buffer allocator.
pub fn get(self: *Self) Allocator

/// This one should not try alignments that exceed what C malloc can handle.
pub fn testAllocator(base_allocator: mem.Allocator) !void

pub fn testAllocatorAligned(base_allocator: mem.Allocator) !void

pub fn testAllocatorLargeAlignment(base_allocator: mem.Allocator) !void

pub fn testAllocatorAlignedShrink(base_allocator: mem.Allocator) !void
