// Stream Processing Patterns (Zig 0.15.2)
// Curated from Lesson 04: Stream Editor (sed clone)
//
// Key patterns:
// 1. Buffered line-by-line reading from File
// 2. CLI argument parsing with flags and positional args
// 3. In-place file editing with atomic rename
// 4. String replacement (all occurrences) without allocator

const std = @import("std");
const testing = std.testing;

// Pattern 1: Buffered line reading from a file or stdin
// Use std.io.bufferedReaderSize for efficient line-by-line processing.
// readUntilDelimiterOrEof returns ?[]u8 (null on EOF, line without delimiter).
fn readLines(allocator: std.mem.Allocator, data: []const u8) ![][]const u8 {
    var list: std.ArrayList([]const u8) = .empty;
    defer list.deinit(allocator);

    var splitter = std.mem.splitScalar(u8, data, '\n');
    while (splitter.next()) |line| {
        // Skip trailing empty line from final newline
        if (line.len == 0 and splitter.peek() == null) break;
        try list.append(allocator, line);
    }
    return try list.toOwnedSlice(allocator);
}

test "readLines splits correctly" {
    const data = "hello\nworld\nfoo\n";
    const lines = try readLines(testing.allocator, data);
    defer testing.allocator.free(lines);

    try testing.expectEqual(@as(usize, 3), lines.len);
    try testing.expectEqualStrings("hello", lines[0]);
    try testing.expectEqualStrings("world", lines[1]);
    try testing.expectEqualStrings("foo", lines[2]);
}

// Pattern 2: Replace all occurrences of a substring (no allocator needed for small buffers)
// For larger strings, use std.mem.replaceOwned. For in-place work on known-size
// buffers, build manually with ArrayList.
fn replaceAll(allocator: std.mem.Allocator, input: []const u8, needle: []const u8, replacement: []const u8) ![]u8 {
    var result: std.ArrayList(u8) = .empty;
    defer result.deinit(allocator);

    var pos: usize = 0;
    while (pos <= input.len) {
        if (pos + needle.len <= input.len and std.mem.eql(u8, input[pos .. pos + needle.len], needle)) {
            try result.appendSlice(allocator, replacement);
            pos += needle.len;
            if (needle.len == 0) {
                // Avoid infinite loop on empty needle
                if (pos < input.len) {
                    try result.append(allocator, input[pos]);
                    pos += 1;
                } else break;
            }
        } else {
            if (pos < input.len) {
                try result.append(allocator, input[pos]);
            }
            pos += 1;
        }
    }
    return try result.toOwnedSlice(allocator);
}

test "replaceAll basic" {
    const r1 = try replaceAll(testing.allocator, "hello world hello", "hello", "HI");
    defer testing.allocator.free(r1);
    try testing.expectEqualStrings("HI world HI", r1);
}

test "replaceAll empty replacement (deletion)" {
    const r = try replaceAll(testing.allocator, "a\"b\"c", "\"", "");
    defer testing.allocator.free(r);
    try testing.expectEqualStrings("abc", r);
}

// Pattern 3: CLI argument parsing with mixed flags and positional args
// Use std.process.argsWithAllocator, collect into ArrayList, parse manually.
const CliOptions = struct {
    suppress: bool = false,
    in_place: bool = false,
    commands: []const []const u8 = &.{},
    filename: ?[]const u8 = null,
};

fn parseCliArgs(allocator: std.mem.Allocator, raw_args: []const []const u8) !CliOptions {
    var opts: CliOptions = .{};
    var cmds: std.ArrayList([]const u8) = .empty;
    defer cmds.deinit(allocator);

    var i: usize = 0;
    while (i < raw_args.len) : (i += 1) {
        const arg = raw_args[i];
        if (std.mem.eql(u8, arg, "-n")) {
            opts.suppress = true;
        } else if (std.mem.eql(u8, arg, "-i")) {
            opts.in_place = true;
        } else if (std.mem.eql(u8, arg, "-e")) {
            i += 1;
            if (i < raw_args.len) try cmds.append(allocator, raw_args[i]);
        } else {
            opts.filename = arg;
        }
    }
    opts.commands = try cmds.toOwnedSlice(allocator);
    return opts;
}

test "parseCliArgs" {
    const args = [_][]const u8{ "-n", "-e", "s/a/b/g", "file.txt" };
    const opts = try parseCliArgs(testing.allocator, &args);
    defer testing.allocator.free(opts.commands);

    try testing.expect(opts.suppress);
    try testing.expect(!opts.in_place);
    try testing.expectEqual(@as(usize, 1), opts.commands.len);
    try testing.expectEqualStrings("s/a/b/g", opts.commands[0]);
    try testing.expectEqualStrings("file.txt", opts.filename.?);
}

// Pattern 4: Atomic file write (in-place editing)
// Write to temp file, then rename. Prevents data loss on failure.
// NOTE: This is the pattern, not runnable in test (needs real filesystem).
// ```zig
// const tmp = try std.fmt.allocPrint(gpa, "{s}.tmp", .{fname});
// defer gpa.free(tmp);
// const f = try std.fs.cwd().createFile(tmp, .{});
// try f.writeAll(output);
// f.close();
// try std.fs.cwd().rename(tmp, fname);
// ```

// Pattern 5: Character transliteration (like tr or sed y command)
// Map each character from source to corresponding character in dest.
fn transliterate(allocator: std.mem.Allocator, input: []const u8, src: []const u8, dst: []const u8) ![]u8 {
    const result = try allocator.dupe(u8, input);
    for (result) |*ch| {
        if (std.mem.indexOfScalar(u8, src, ch.*)) |idx| {
            if (idx < dst.len) ch.* = dst[idx];
        }
    }
    return result;
}

test "transliterate ROT13" {
    const src = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    const dst = "NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm";
    const result = try transliterate(testing.allocator, "Hello World", src, dst);
    defer testing.allocator.free(result);
    try testing.expectEqualStrings("Uryyb Jbeyq", result);
}
