// memory_ownership.zig — Curated patterns for memory ownership pitfalls in Zig 0.15.2
//
// Patterns demonstrated:
// 1. errdefer + manual free = double-free (choose one owner)
// 2. Intermediate allocation leak when chaining formatters
// 3. Nested slice constness: [][]u8 does NOT coerce to [][]const u8

const std = @import("std");
const testing = std.testing;

// =============================================================================
// Pattern 1: errdefer + manual free = double-free
//
// If errdefer owns cleanup, do NOT also free manually before returning error.
// The errdefer fires on ANY error return, including explicit `return error.X`.
// =============================================================================

fn readPayload(allocator: std.mem.Allocator, too_big: bool) ![]u8 {
    const buf = try allocator.alloc(u8, 16);
    errdefer allocator.free(buf); // errdefer owns cleanup on error path

    if (too_big) {
        // ❌ WRONG: allocator.free(buf) here + errdefer = double-free
        // ✅ RIGHT: just return the error — errdefer handles cleanup
        return error.PayloadTooLarge;
    }

    @memset(buf, 'A');
    return buf; // success: caller owns buf, errdefer does NOT fire
}

test "errdefer owns error-path cleanup — no manual free needed" {
    const allocator = testing.allocator;

    // Error path: errdefer frees buf, no double-free
    const err_result = readPayload(allocator, true);
    try testing.expectError(error.PayloadTooLarge, err_result);

    // Success path: caller owns the buffer
    const buf = try readPayload(allocator, false);
    defer allocator.free(buf);
    try testing.expectEqualStrings("AAAAAAAAAAAAAAAA", buf);
}

// =============================================================================
// Pattern 2: Intermediate allocation leak when chaining formatters
//
// When func A returns an allocation and func B wraps it in a new allocation,
// the A result leaks unless explicitly freed.
// =============================================================================

fn formatInner(allocator: std.mem.Allocator, value: i32) ![]u8 {
    return try std.fmt.allocPrint(allocator, "value={d}", .{value});
}

fn formatWrapped(allocator: std.mem.Allocator, inner: []const u8) ![]u8 {
    return try std.fmt.allocPrint(allocator, "{{\"{s}\"}}", .{inner});
}

test "intermediate allocation must be freed when chaining formatters" {
    const allocator = testing.allocator;

    // ❌ WRONG (leaks inner):
    //   const inner = try formatInner(allocator, 42);
    //   const result = try formatWrapped(allocator, inner);
    //   defer allocator.free(result);
    //   // inner is never freed!

    // ✅ RIGHT: defer-free the intermediate before wrapping
    const inner = try formatInner(allocator, 42);
    defer allocator.free(inner);

    const result = try formatWrapped(allocator, inner);
    defer allocator.free(result);

    try testing.expectEqualStrings("{\"value=42\"}", result);
}

// =============================================================================
// Pattern 3: Nested slice constness — [][]u8 does NOT coerce to [][]const u8
//
// Zig's type system treats the inner pointer's mutability as part of the type.
// If your target type is [][]const u8, allocate []const u8 items directly.
// =============================================================================

fn takesConstSlices(slices: []const []const u8) usize {
    var total: usize = 0;
    for (slices) |s| total += s.len;
    return total;
}

test "allocate []const u8 items when target is [][]const u8" {
    const allocator = testing.allocator;

    // Source data (mutable buffers)
    var buf1 = [_]u8{ 'h', 'i' };
    var buf2 = [_]u8{ 'b', 'y', 'e' };

    // ❌ WRONG: allocating [][]u8 then passing to fn([]const []const u8)
    //   var items = try allocator.alloc([]u8, 2);  // [][]u8
    //   items[0] = &buf1;
    //   items[1] = &buf2;
    //   _ = takesConstSlices(items);  // compile error: [][]u8 ≠ [][]const u8

    // ✅ RIGHT: allocate []const u8 items directly
    const items = try allocator.alloc([]const u8, 2);
    defer allocator.free(items);
    items[0] = &buf1;
    items[1] = &buf2;

    try testing.expectEqual(@as(usize, 5), takesConstSlices(items));
}
