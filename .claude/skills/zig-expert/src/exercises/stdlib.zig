const std = @import("std");
const testing = std.testing;

// Minimal stdlib validation exercises — 14 tests covering key patterns and gotchas

// 1. ArrayList .empty init + per-method allocator
test "ArrayList - creation and basic operations" {
    const gpa = testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa);

    // append takes allocator as first arg
    try list.append(gpa, 10);
    try list.append(gpa, 20);
    try list.append(gpa, 30);
    try testing.expectEqual(@as(usize, 3), list.items.len);

    // index access via .items slice
    try testing.expectEqual(@as(i32, 10), list.items[0]);
    try testing.expectEqual(@as(i32, 20), list.items[1]);
    try testing.expectEqual(@as(i32, 30), list.items[2]);
}

// 2. clearRetainingCapacity
test "ArrayList - appendSlice and clearRetainingCapacity" {
    const gpa = testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa);

    // appendSlice takes allocator and a slice
    try list.appendSlice(gpa, &[_]i32{ 5, 10, 15, 20 });
    try testing.expectEqual(@as(usize, 4), list.items.len);

    // clearRetainingCapacity: length goes to 0, capacity remains
    const cap_before = list.capacity;
    list.clearRetainingCapacity();
    try testing.expectEqual(@as(usize, 0), list.items.len);
    try testing.expectEqual(cap_before, list.capacity);
}

// 3. HashMap init + getOrPut pattern
test "AutoHashMap - getOrPut" {
    const gpa = testing.allocator;
    var map = std.AutoHashMap(u32, u32).init(gpa);
    defer map.deinit();

    // getOrPut: get existing or create a new entry
    const result1 = try map.getOrPut(42);
    try testing.expect(!result1.found_existing);
    result1.value_ptr.* = 100;

    const result2 = try map.getOrPut(42);
    try testing.expect(result2.found_existing);
    try testing.expectEqual(@as(u32, 100), result2.value_ptr.*);
}

// 4. std.mem.eql, startsWith, indexOf
test "mem - eql, startsWith, indexOf" {
    try testing.expect(std.mem.eql(u8, "hello", "hello"));
    try testing.expect(!std.mem.eql(u8, "hello", "world"));
    try testing.expect(std.mem.startsWith(u8, "hello world", "hello"));

    const idx = std.mem.indexOf(u8, "hello world hello", "world");
    try testing.expectEqual(@as(usize, 6), idx.?);
    try testing.expect(std.mem.indexOf(u8, "hello", "xyz") == null);
}

// 5. std.fmt.bufPrint and allocPrint
test "fmt.bufPrint and allocPrint" {
    var buf: [64]u8 = undefined;
    const result = try std.fmt.bufPrint(&buf, "Hello, {s}! You are {d} years old.", .{ "World", 42 });
    try testing.expectEqualStrings("Hello, World! You are 42 years old.", result);

    const gpa = testing.allocator;
    const heap_result = try std.fmt.allocPrint(gpa, "{d} + {d} = {d}", .{ 2, 3, 5 });
    defer gpa.free(heap_result);
    try testing.expectEqualStrings("2 + 3 = 5", heap_result);
}

// 6. std.fmt.comptimePrint
test "fmt.comptimePrint - comptime string formatting" {
    // comptimePrint produces a comptime-known string literal
    const s = std.fmt.comptimePrint("{d}_{s}", .{ 42, "hello" });
    try testing.expectEqualStrings("42_hello", s);
}

// 7. std.sort.pdq usage
test "sort.pdq - ascending and descending" {
    var asc_arr = [_]i32{ 5, 3, 1, 4, 2 };
    std.sort.pdq(i32, &asc_arr, {}, std.sort.asc(i32));
    try testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3, 4, 5 }, &asc_arr);

    var desc_arr = [_]i32{ 5, 3, 1, 4, 2 };
    std.sort.pdq(i32, &desc_arr, {}, std.sort.desc(i32));
    try testing.expectEqualSlices(i32, &[_]i32{ 5, 4, 3, 2, 1 }, &desc_arr);
}

// 8. JSON serialization with std.json.fmt
test "json - serialize with json.fmt and {f} specifier" {
    const gpa = testing.allocator;

    const Config = struct {
        name: []const u8,
        value: i32,
    };

    const config = Config{ .name = "hello", .value = 42 };

    // In 0.15.2: use std.json.fmt(value, options) with {f} format specifier
    const json_str = try std.fmt.allocPrint(gpa, "{f}", .{std.json.fmt(config, .{})});
    defer gpa.free(json_str);

    // Verify it's valid JSON by round-tripping
    const parsed = try std.json.parseFromSlice(Config, gpa, json_str, .{});
    defer parsed.deinit();
    try testing.expectEqualStrings("hello", parsed.value.name);
    try testing.expectEqual(@as(i32, 42), parsed.value.value);
}

// 9. std.math.isPowerOfTwo (including n>0 requirement)
test "math - isPowerOfTwo (asserts n > 0)" {
    try testing.expect(std.math.isPowerOfTwo(@as(u32, 64)));
    try testing.expect(!std.math.isPowerOfTwo(@as(u32, 63)));
    // GOTCHA: isPowerOfTwo(0) panics! It asserts n > 0.
    // Do NOT call with 0: std.math.isPowerOfTwo(@as(u32, 0)) -> panic
}

// 10. String multiline literals
test "strings - multiline string literals" {
    // \\ at the start of each line creates a multiline string
    const s =
        \\Line 1
        \\Line 2
        \\Line 3
    ;
    try testing.expect(std.mem.indexOf(u8, s, "Line 2") != null);

    // Multi-line string preserves newlines between lines
    var iter = std.mem.splitScalar(u8, s, '\n');
    try testing.expectEqualStrings("Line 1", iter.next().?);
    try testing.expectEqualStrings("Line 2", iter.next().?);
    try testing.expectEqualStrings("Line 3", iter.next().?);
}

// 11. File I/O basics
test "fs - create, write, read, and delete a temp file" {
    const gpa = testing.allocator;
    const tmp_path = "/tmp/zig_skill_stdlib_test.txt";
    const content = "Hello from Zig stdlib test!\nLine 2\n";

    // Write
    {
        const file = try std.fs.cwd().createFile(tmp_path, .{});
        defer file.close();
        try file.writeAll(content);
    }

    // Read back
    {
        const data = try std.fs.cwd().readFileAlloc(gpa, tmp_path, 1024);
        defer gpa.free(data);
        try testing.expectEqualStrings(content, data);
    }

    // Clean up
    try std.fs.cwd().deleteFile(tmp_path);
}

// 12. std.mem.sliceTo
test "mem.sliceTo for finding sentinel in C data" {
    // Simulating C data: a buffer with a null terminator somewhere
    const data = [_]u8{ 'h', 'i', 0, 'x', 'y' };

    // sliceTo finds the sentinel and returns the slice before it
    const result = std.mem.sliceTo(&data, 0);
    try testing.expectEqualStrings("hi", result);
}

// 13. mem.order returns enum
test "mem.order - lexicographic comparison returns Order enum" {
    try testing.expect(std.mem.order(u8, "abc", "abd") == .lt);
    try testing.expect(std.mem.order(u8, "abd", "abc") == .gt);
    try testing.expect(std.mem.order(u8, "abc", "abc") == .eq);
    try testing.expect(std.mem.order(u8, "abc", "abcd") == .lt);
}

// 14. Unicode UTF-8 iteration
test "strings - unicode UTF-8 iteration" {
    const utf8_str = "Hello";
    var view = std.unicode.Utf8View.initUnchecked(utf8_str);
    var iter = view.iterator();
    var count: usize = 0;
    while (iter.nextCodepoint()) |_| {
        count += 1;
    }
    try testing.expectEqual(@as(usize, 5), count);
}
