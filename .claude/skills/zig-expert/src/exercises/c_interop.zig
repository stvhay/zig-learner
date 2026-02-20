// Minimal C interop exercises — validates core patterns against the compiler.
// Requires .link_libc = true in build config for @cImport to work.

const std = @import("std");
const builtin = @import("builtin");
const testing = std.testing;
const mem = std.mem;

const libc = @cImport({
    @cInclude("stdlib.h");
    @cInclude("string.h");
});

test "sentinel-terminated C strings and std.mem.span" {
    const c_str: [*:0]const u8 = "hello";
    const slice: [:0]const u8 = mem.span(c_str);
    try testing.expectEqualStrings("hello", slice);
    try testing.expectEqual(@as(usize, 5), slice.len);
    try testing.expectEqual(@as(u8, 0), slice[slice.len]); // sentinel at end
}

test "extern struct layout and @offsetOf" {
    const Point = extern struct { x: f64, y: f64 };
    try testing.expectEqual(@as(usize, 16), @sizeOf(Point));
    try testing.expectEqual(@as(usize, 0), @offsetOf(Point, "x"));
    try testing.expectEqual(@as(usize, 8), @offsetOf(Point, "y"));

    const Mixed = extern struct { a: u8, b: u32, c: u8, d: u16 };
    try testing.expectEqual(@as(usize, 12), @sizeOf(Mixed));
    try testing.expectEqual(@as(usize, 4), @offsetOf(Mixed, "b"));
}

test "pointer types: [*]T vs *T vs *[N]T vs []T" {
    var arr = [_]u32{ 10, 20, 30, 40, 50 };
    const arr_ptr: *[5]u32 = &arr;          // pointer to array (carries length)
    const many_ptr: [*]u32 = &arr;          // many-pointer (no bounds)
    const single_ptr: *u32 = &arr[0];       // single pointer (deref only)
    const slice: []u32 = &arr;              // slice (pointer + length)

    try testing.expectEqual(@as(u32, 10), arr_ptr[0]);
    try testing.expectEqual(@as(u32, 30), many_ptr[2]);
    try testing.expectEqual(@as(u32, 10), single_ptr.*);
    try testing.expectEqual(@as(usize, 5), slice.len);
}

test "@cImport — strlen and strcmp from string.h" {
    const len = libc.strlen("Hello, libc!");
    try testing.expectEqual(@as(usize, 12), len);

    const cmp = libc.strcmp("abc", "abc");
    try testing.expectEqual(@as(c_int, 0), cmp);
    try testing.expect(libc.strcmp("abc", "abd") < 0);
}

test "@intFromPtr and @ptrFromInt round-trip" {
    var value: u64 = 12345;
    const ptr: *u64 = &value;
    const addr: usize = @intFromPtr(ptr);
    try testing.expect(addr != 0);

    const ptr2: *u64 = @ptrFromInt(addr);
    try testing.expectEqual(@as(u64, 12345), ptr2.*);
    try testing.expectEqual(ptr, ptr2);
}

test "@alignCast required when casting from *anyopaque" {
    var data: u32 = 42;
    const raw: *anyopaque = &data;
    // *anyopaque has alignment 1; *u32 needs alignment 4
    const typed: *u32 = @ptrCast(@alignCast(raw));
    try testing.expectEqual(@as(u32, 42), typed.*);
}

test "std.mem.sliceTo for finding sentinel in buffer" {
    const raw = [_]u8{ 'H', 'e', 'l', 'l', 'o', 0, 'x', 'x' };
    const found = mem.sliceTo(&raw, 0);
    try testing.expectEqualStrings("Hello", found);
}

test "C type mapping and @intCast conversions" {
    const zig_val: u32 = 255;
    const c_val: c_int = @intCast(zig_val);
    const back: i32 = @intCast(c_val);
    try testing.expectEqual(@as(i32, 255), back);
    try testing.expect(@sizeOf(c_long) >= @sizeOf(c_int));
}
