// Curated patterns: Bit-level I/O and PriorityQueue for tree building
// Extracted from Lesson 03 (Huffman Compression)

const std = @import("std");
const testing = std.testing;

// === 1. PriorityQueue with pointer elements and multi-field comparison ===
// GOTCHA: compareFn returns std.math.Order, NOT bool
// GOTCHA: PriorityQueue uses stored allocator (.init(gpa, ctx)), like HashMap

const TreeNode = struct {
    freq: u64,
    label: u8,
};

fn treeNodeCompare(_: void, a: *TreeNode, b: *TreeNode) std.math.Order {
    const freq_order = std.math.order(a.freq, b.freq);
    if (freq_order != .eq) return freq_order;
    return std.math.order(a.label, b.label); // deterministic tie-break
}

test "PriorityQueue with pointer elements and tie-breaking" {
    const gpa = testing.allocator;
    var pq = std.PriorityQueue(*TreeNode, void, treeNodeCompare).init(gpa, {});
    defer pq.deinit();

    // Heap-allocate nodes (required for pointer stability)
    var nodes: [3]*TreeNode = undefined;
    for (&nodes, [_]TreeNode{
        .{ .freq = 3, .label = 'a' },
        .{ .freq = 1, .label = 'c' },
        .{ .freq = 2, .label = 'b' },
    }) |*slot, init| {
        slot.* = try gpa.create(TreeNode);
        slot.*.* = init;
        try pq.add(slot.*);
    }
    defer for (nodes) |n| gpa.destroy(n);

    // Extract in frequency order (min-heap)
    try testing.expectEqual(@as(u8, 'c'), pq.remove().label); // freq 1
    try testing.expectEqual(@as(u8, 'b'), pq.remove().label); // freq 2
    try testing.expectEqual(@as(u8, 'a'), pq.remove().label); // freq 3
}

// === 2. Bit-level writer: pack bits into bytes (MSB-first) ===
// GOTCHA: u3 counter overflows at 7+1 — use u4 and check == 8

const BitWriter = struct {
    buffer: u8 = 0,
    bit_count: u4 = 0, // 0..8, NOT u3 (overflows at 7)
    output: std.ArrayList(u8) = .empty,

    fn writeBit(self: *BitWriter, allocator: std.mem.Allocator, bit: u1) !void {
        self.buffer = (self.buffer << 1) | bit;
        self.bit_count += 1;
        if (self.bit_count == 8) { // full byte
            try self.output.append(allocator, self.buffer);
            self.buffer = 0;
            self.bit_count = 0;
        }
    }

    fn flush(self: *BitWriter, allocator: std.mem.Allocator) !u8 {
        if (self.bit_count == 0) return 0;
        const used: u8 = @intCast(self.bit_count);
        const padding: u8 = 8 - used;
        const shift: u3 = @intCast(padding);
        self.buffer <<= shift;
        try self.output.append(allocator, self.buffer);
        self.buffer = 0;
        self.bit_count = 0;
        return padding;
    }

    fn deinit(self: *BitWriter, allocator: std.mem.Allocator) void {
        self.output.deinit(allocator);
    }
};

test "BitWriter: 8 bits produce 0x1E" {
    const gpa = testing.allocator;
    var bw = BitWriter{};
    defer bw.deinit(gpa);
    for ([_]u1{ 0, 0, 0, 1, 1, 1, 1, 0 }) |bit| try bw.writeBit(gpa, bit);
    try testing.expectEqual(@as(u8, 0x1E), bw.output.items[0]);
}

test "BitWriter: flush pads to byte boundary" {
    const gpa = testing.allocator;
    var bw = BitWriter{};
    defer bw.deinit(gpa);
    for ([_]u1{ 1, 1, 0 }) |bit| try bw.writeBit(gpa, bit);
    const padding = try bw.flush(gpa);
    try testing.expectEqual(@as(u8, 5), padding);
    try testing.expectEqual(@as(u8, 0xC0), bw.output.items[0]);
}

// === 3. Bit-level reader: unpack bytes to bits (MSB-first) ===

const BitReader = struct {
    data: []const u8,
    byte_pos: usize = 0,
    bit_pos: u3 = 0,

    fn readBit(self: *BitReader) ?u1 {
        if (self.byte_pos >= self.data.len) return null;
        const bit: u1 = @intCast((self.data[self.byte_pos] >> (7 - @as(u3, self.bit_pos))) & 1);
        if (self.bit_pos == 7) {
            self.bit_pos = 0;
            self.byte_pos += 1;
        } else {
            self.bit_pos += 1;
        }
        return bit;
    }
};

test "BitReader: read 0x1E bit-by-bit" {
    var br = BitReader{ .data = &[_]u8{0x1E} };
    const expected = [_]u1{ 0, 0, 0, 1, 1, 1, 1, 0 };
    for (expected) |exp| try testing.expectEqual(exp, br.readBit().?);
}

// === 4. Binary I/O: little-endian integers ===

test "binary write/read with std.mem.toBytes and readInt" {
    const val: u32 = 0xDEADBEEF;
    const bytes = std.mem.toBytes(val); // native endian
    const read_back = std.mem.readInt(u32, &bytes, .little);
    // On little-endian systems (x86/ARM), these match:
    try testing.expectEqual(val, read_back);
}
