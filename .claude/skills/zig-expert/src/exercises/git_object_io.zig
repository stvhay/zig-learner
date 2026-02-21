// Git object I/O patterns for Zig 0.15.2
// Curated from Lesson 07 (Git Internals applied project)
//
// Key patterns:
// 1. C zlib compression via @cImport (std.compress.flate.Compress is broken — pitfall #38)
// 2. SHA-1 hashing with std.crypto.hash.Sha1
// 3. macOS POSIX stat field types and casting
// 4. Big-endian binary I/O for git index format
//
// Build: zig test git_object_io.zig -lz -lc

const std = @import("std");
const testing = std.testing;

// --- Pattern 1: C zlib compression/decompression ---
// std.compress.flate.Compress has @panic("TODO") in 0.15.2.
// Must use C zlib via @cImport. Link with -lz -lc.
const c = @cImport(@cInclude("zlib.h"));

fn zlibCompress(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    var bound: c_ulong = c.compressBound(@intCast(input.len));
    const buf = try allocator.alloc(u8, bound);
    errdefer allocator.free(buf);
    const rc = c.compress(buf.ptr, &bound, input.ptr, @intCast(input.len));
    if (rc != c.Z_OK) return error.CompressFailed;
    // IMPORTANT: realloc to actual size so free() works correctly.
    // Freeing a sub-slice of a larger allocation is an "Invalid free" panic.
    const result = allocator.realloc(buf, bound) catch {
        return buf[0..bound]; // realloc failure is non-fatal here
    };
    return result;
}

fn zlibDecompress(allocator: std.mem.Allocator, input: []const u8, max_size: usize) ![]u8 {
    const buf = try allocator.alloc(u8, max_size);
    errdefer allocator.free(buf);
    var out_len: c_ulong = @intCast(max_size);
    const rc = c.uncompress(buf.ptr, &out_len, input.ptr, @intCast(input.len));
    if (rc != c.Z_OK) return error.DecompressFailed;
    // Realloc to actual size — freeing a sub-slice panics with "Invalid free"
    const result = allocator.realloc(buf, out_len) catch {
        return buf[0..out_len];
    };
    return result;
}

test "c zlib compress and decompress round-trip" {
    const gpa = testing.allocator;
    const original = "Hello, git object store!";
    const compressed = try zlibCompress(gpa, original);
    defer gpa.free(compressed);
    // Compressed should be different size
    try testing.expect(compressed.len > 0);

    const decompressed = try zlibDecompress(gpa, compressed, 1024);
    defer gpa.free(decompressed);
    try testing.expectEqualStrings(original, decompressed);
}

// --- Pattern 2: SHA-1 hashing ---
fn gitBlobHash(content: []const u8) [20]u8 {
    var h = std.crypto.hash.Sha1.init(.{});
    // Git object format: "<type> <size>\0<content>"
    var size_buf: [20]u8 = undefined;
    const size_str = std.fmt.bufPrint(&size_buf, "{d}", .{content.len}) catch unreachable;
    h.update("blob ");
    h.update(size_str);
    h.update(&[_]u8{0});
    h.update(content);
    return h.finalResult(); // [20]u8
}

test "sha1 git blob hash" {
    // "hello world" (no newline) -> known git hash
    const hash = gitBlobHash("hello world");
    const hex = std.fmt.bytesToHex(hash, .lower);
    try testing.expectEqualStrings("95d09f2b10159347eece71399a7e2e907ea3df4f", &hex);
}

// --- Pattern 3: macOS POSIX stat field types ---
// On macOS (Darwin), std.posix.Stat field types differ from Linux:
//   ino  = u64  → use @truncate for u64→u32 narrowing
//   dev  = i32  → use @bitCast for i32→u32 reinterpretation
//   size = i64  → use @intCast for i64→u32 (if value fits)
//   mode = u16  → use @intCast for u16→u32 widening
//   uid  = u32  → direct use
//   gid  = u32  → direct use
//   mtimespec/ctimespec (NOT mtime/ctime): .sec (isize) + .nsec (isize)
test "posix fstat field access on macOS" {
    // Create a temp file to stat
    var tmp = try std.fs.cwd().createFile("_test_stat_tmp", .{});
    try tmp.writeAll("test data");
    tmp.close();
    defer std.fs.cwd().deleteFile("_test_stat_tmp") catch {};

    const f = try std.fs.cwd().openFile("_test_stat_tmp", .{});
    defer f.close();
    const stat = try std.posix.fstat(f.handle);

    // Demonstrate the casting patterns
    const ino_u32: u32 = @truncate(stat.ino); // u64 → u32
    const dev_u32: u32 = @bitCast(stat.dev); // i32 → u32
    const size_u32: u32 = @intCast(stat.size); // i64 → u32 (small file)
    const mode_u32: u32 = @intCast(stat.mode); // u16 → u32

    _ = ino_u32;
    _ = dev_u32;
    _ = mode_u32;
    try testing.expectEqual(@as(u32, 9), size_u32); // "test data" = 9 bytes

    // Time fields: mtimespec (NOT mtime), with .sec and .nsec
    const mtime_sec: u32 = @intCast(stat.mtimespec.sec);
    const mtime_nsec: u32 = @intCast(stat.mtimespec.nsec);
    try testing.expect(mtime_sec > 0);
    _ = mtime_nsec;
}

// --- Pattern 4: Big-endian binary I/O ---
test "big-endian read and write for git binary formats" {
    // Write u32 big-endian
    var buf: [4]u8 = undefined;
    std.mem.writeInt(u32, &buf, 0x44495243, .big); // "DIRC" magic
    try testing.expectEqualSlices(u8, "DIRC", &buf);

    // Read u32 big-endian
    const val = std.mem.readInt(u32, &buf, .big);
    try testing.expectEqual(@as(u32, 0x44495243), val);

    // Write u16 big-endian (for index entry flags)
    var buf16: [2]u8 = undefined;
    const name_len: u16 = 11;
    std.mem.writeInt(u16, &buf16, name_len, .big);
    try testing.expectEqual(@as(u16, 11), std.mem.readInt(u16, &buf16, .big));
}
