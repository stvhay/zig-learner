// File I/O and CLI argument patterns for Zig 0.15.2
// Curated from Lesson 02 (Hex Dump applied project)
//
// Key patterns:
// 1. Buffered stdout writer with flush
// 2. CLI argument parsing (argsAlloc, NOT argsWithAllocator for simple cases)
// 3. File reading in a loop with file.read()
// 4. Seeking with file.seekTo()
// 5. Stdin fallback (File.stdin(), NOT std.io.getStdIn())
// 6. Hex formatting with zero-padding

const std = @import("std");

// Pattern 1: Buffered stdout writer
// IMPORTANT: flush() is on .interface, NOT on the writer struct
fn setupStdout() struct { buf: [4096]u8, writer: std.fs.File.Writer } {
    return .{
        .buf = undefined,
        .writer = undefined,
    };
}

test "buffered stdout pattern" {
    // In a real program (pub fn main):
    // var out_buf: [4096]u8 = undefined;
    // var out_w = std.fs.File.stdout().writer(&out_buf);
    // const stdout = &out_w.interface;
    // defer stdout.flush() catch {};
    //
    // For stderr:
    // var err_buf: [256]u8 = undefined;
    // var err_w = std.fs.File.stderr().writer(&err_buf);
    // const stderr = &err_w.interface;

    // Test with fixedBufferStream to verify formatting
    var buf: [256]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    const w = fbs.writer();

    // Hex offset with zero-padding (8-digit lowercase)
    try w.print("{x:0>8}: ", .{@as(usize, 0x1a)});
    try std.testing.expectEqualStrings("0000001a: ", fbs.getWritten());
}

test "hex byte formatting" {
    var buf: [64]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    const w = fbs.writer();

    // Lowercase hex (default xxd)
    try w.print("{x:0>2}", .{@as(u8, 0x4e)});
    try std.testing.expectEqualStrings("4e", fbs.getWritten());

    fbs.reset();
    // Uppercase hex (-u flag)
    try w.print("{X:0>2}", .{@as(u8, 0x4e)});
    try std.testing.expectEqualStrings("4E", fbs.getWritten());

    fbs.reset();
    // Binary format (-b flag)
    try w.print("{b:0>8}", .{@as(u8, 0x41)});
    try std.testing.expectEqualStrings("01000001", fbs.getWritten());

    fbs.reset();
    // Character output
    try w.print("{c}", .{@as(u8, 'A')});
    try std.testing.expectEqualStrings("A", fbs.getWritten());
}

test "parseInt auto-detect base" {
    // base 0 auto-detects: decimal, 0x hex, 0o octal, 0b binary
    const decimal = try std.fmt.parseInt(usize, "42", 0);
    try std.testing.expectEqual(@as(usize, 42), decimal);

    const hex = try std.fmt.parseInt(usize, "0x2a", 0);
    try std.testing.expectEqual(@as(usize, 42), hex);

    const hex_upper = try std.fmt.parseInt(usize, "0x2A", 0);
    try std.testing.expectEqual(@as(usize, 42), hex_upper);
}

test "file read loop pattern" {
    // Pattern for reading a file in chunks:
    //
    // const file = try std.fs.cwd().openFile(filename, .{});
    // defer file.close();
    //
    // // Seek if needed
    // try file.seekTo(offset);
    //
    // var buf: [4096]u8 = undefined;
    // while (true) {
    //     const n = file.read(&buf) catch |err| {
    //         if (err == error.EndOfStream) break;
    //         return err;
    //     };
    //     if (n == 0) break;  // EOF
    //     const data = buf[0..n];
    //     // process data...
    // }
    //
    // For stdin (when no filename provided):
    // const file = std.fs.File.stdin();
    // // Cannot seekTo on stdin -- must read and discard bytes instead
}

test "ascii printable check" {
    // xxd ASCII column: printable 0x20-0x7E, else '.'
    const printable = "Hello!";
    for (printable) |c| {
        try std.testing.expect(c >= 0x20 and c <= 0x7E);
    }

    // Non-printable examples
    try std.testing.expect(!(0x00 >= 0x20 and 0x00 <= 0x7E)); // null
    try std.testing.expect(!(0x7F >= 0x20 and 0x7F <= 0x7E)); // DEL
    try std.testing.expect(!(0xFF >= 0x20 and 0xFF <= 0x7E)); // high byte
}

test "hex char to nibble conversion" {
    // Pattern for parsing hex strings back to bytes
    const hexCharToNibble = struct {
        fn f(c: u8) ?u4 {
            return switch (c) {
                '0'...'9' => @intCast(c - '0'),
                'a'...'f' => @intCast(c - 'a' + 10),
                'A'...'F' => @intCast(c - 'A' + 10),
                else => null,
            };
        }
    }.f;

    try std.testing.expectEqual(@as(?u4, 0), hexCharToNibble('0'));
    try std.testing.expectEqual(@as(?u4, 10), hexCharToNibble('a'));
    try std.testing.expectEqual(@as(?u4, 15), hexCharToNibble('F'));
    try std.testing.expectEqual(@as(?u4, null), hexCharToNibble(' '));

    // Reconstruct byte from two nibbles
    const high = hexCharToNibble('4').?;
    const low = hexCharToNibble('e').?;
    const byte = (@as(u8, high) << 4) | @as(u8, low);
    try std.testing.expectEqual(@as(u8, 0x4e), byte);
}
