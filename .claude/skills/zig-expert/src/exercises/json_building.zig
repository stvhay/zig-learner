// JSON building patterns for Zig 0.15.2
// Covers: json.ObjectMap vs json.Array vs std.ArrayList init asymmetry,
//         arena allocator for nested JSON objects, serialization via json.fmt.
//
// KEY DISTINCTION:
//   json.ObjectMap = StringArrayHashMap(Value) → .init(allocator) (stored allocator)
//   json.Array     = array_list.Managed(Value) → .init(allocator) (stored allocator)
//   std.ArrayList  = array_list.Aligned(...)   → .empty (per-method allocator)
// The first two store the allocator; ArrayList does NOT.

const std = @import("std");
const json = std.json;
const testing = std.testing;

// ── Build a JSON object with nested array ───────────────────────
// json.ObjectMap uses .init(allocator) — stored allocator pattern.
// json.Array uses .init(allocator) — stored allocator pattern.
// ObjectMap.deinit() does NOT recursively free nested objects.
// Use ArenaAllocator when building nested JSON to avoid leaks.

fn buildToolResponse(base_allocator: std.mem.Allocator, name: []const u8, args: []const []const u8) ![]const u8 {
    // Arena frees all nested JSON objects at once — no recursive deinit needed
    var arena = std.heap.ArenaAllocator.init(base_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    // ObjectMap: .init(allocator) — stored allocator, NOT .empty
    var root = json.ObjectMap.init(alloc);
    try root.put("name", .{ .string = name });

    // Nested object: also uses arena allocator
    var params = json.ObjectMap.init(alloc);
    try params.put("type", .{ .string = "object" });

    // json.Array: .init(allocator) — stored allocator, NOT .empty
    var required = json.Array.init(alloc);
    for (args) |arg| {
        try required.append(.{ .string = arg });
    }
    try params.put("required", .{ .array = required });
    try root.put("inputSchema", .{ .object = params });

    // Serialize: allocPrint + json.fmt — no stringify in 0.15.2
    // Dupe to base_allocator so result survives arena teardown
    const serialized = try std.fmt.allocPrint(alloc, "{f}", .{json.fmt(
        json.Value{ .object = root },
        .{},
    )});
    return try base_allocator.dupe(u8, serialized);
}

test "buildToolResponse produces valid JSON" {
    const gpa = testing.allocator;
    const args = &[_][]const u8{ "path", "content" };
    const result = try buildToolResponse(gpa, "writeFile", args);
    defer gpa.free(result);

    // Parse back to verify structure
    const parsed = try json.parseFromSlice(json.Value, gpa, result, .{});
    defer parsed.deinit();

    const obj = parsed.value.object;
    try testing.expectEqualStrings("writeFile", obj.get("name").?.string);

    const schema = obj.get("inputSchema").?.object;
    try testing.expectEqualStrings("object", schema.get("type").?.string);

    const req = schema.get("required").?.array;
    try testing.expectEqual(@as(usize, 2), req.items.len);
    try testing.expectEqualStrings("path", req.items[0].string);
    try testing.expectEqualStrings("content", req.items[1].string);
}

// ── Contrast: ArrayList uses .empty, NOT .init ──────────────────
// This test demonstrates that std.ArrayList and json.Array have
// DIFFERENT init patterns despite similar names.

fn collectJsonKeys(allocator: std.mem.Allocator, obj: json.ObjectMap) ![][]const u8 {
    // std.ArrayList: .empty — per-method allocator (NEVER .init)
    var keys: std.ArrayList([]const u8) = .empty;
    defer keys.deinit(allocator);

    var it = obj.iterator();
    while (it.next()) |entry| {
        try keys.append(allocator, entry.key_ptr.*);
    }
    return try keys.toOwnedSlice(allocator);
}

test "ArrayList .empty vs json.Array .init contrast" {
    const gpa = testing.allocator;

    // json.Array: .init(allocator) — stored allocator
    var arr = json.Array.init(gpa);
    defer arr.deinit();
    try arr.append(.{ .string = "a" });
    try arr.append(.{ .string = "b" });
    try testing.expectEqual(@as(usize, 2), arr.items.len);

    // json.ObjectMap: .init(allocator) — stored allocator
    var obj = json.ObjectMap.init(gpa);
    defer obj.deinit();
    try obj.put("x", .{ .integer = 1 });
    try obj.put("y", .{ .integer = 2 });

    // std.ArrayList: .empty — per-method allocator
    const keys = try collectJsonKeys(gpa, obj);
    defer gpa.free(keys);
    try testing.expectEqual(@as(usize, 2), keys.len);
}

// ── Error set exhaustiveness ────────────────────────────────────
// When a reader type has a concrete (small) error set, `else` in
// catch switch is unreachable. Use bare `catch` to map all errors.

fn readLine(buf: []u8, input: []const u8) !?[]const u8 {
    var fbs = std.io.fixedBufferStream(input);
    const reader = fbs.reader();
    // FixedBufferStream reader error set = { StreamTooLong } only.
    // Using `catch |err| switch (err) { else => ... }` would be a
    // compile error because `else` is unreachable.
    // Bare `catch` works when all errors map to one result:
    return reader.readUntilDelimiterOrEof(buf, '\n') catch
        return error.LineTooLong;
}

test "readLine from fixed buffer" {
    var buf: [64]u8 = undefined;
    const line = try readLine(&buf, "hello\nworld");
    try testing.expectEqualStrings("hello", line.?);
}

test "readLine overflow returns error" {
    var buf: [4]u8 = undefined;
    try testing.expectError(error.LineTooLong, readLine(&buf, "toolongline\n"));
}
