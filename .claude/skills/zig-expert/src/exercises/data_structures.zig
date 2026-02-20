// Minimal data structures exercises — validates core patterns against the compiler.

const std = @import("std");
const testing = std.testing;

// === 1. PriorityQueue with Order compareFn (GOTCHA: returns Order, not bool) ===

fn minCompare(_: void, a: i32, b: i32) std.math.Order {
    return std.math.order(a, b);
}

test "PriorityQueue: compareFn returns std.math.Order, not bool" {
    const gpa = testing.allocator;
    var pq = std.PriorityQueue(i32, void, minCompare).init(gpa, {});
    defer pq.deinit();

    try pq.add(30);
    try pq.add(10);
    try pq.add(20);

    try testing.expectEqual(@as(?i32, 10), pq.peek());
    try testing.expectEqual(@as(i32, 10), pq.remove());
    try testing.expectEqual(@as(i32, 20), pq.remove());
    try testing.expectEqual(@as(i32, 30), pq.remove());
    try testing.expectEqual(@as(?i32, null), pq.peek());
}

// === 2. MultiArrayList field access via .slice().items(.field) ===

const Particle = struct { x: f32, y: f32, mass: f64, active: bool };

test "MultiArrayList: slice().items(.field) for SoA access" {
    const gpa = testing.allocator;
    var list: std.MultiArrayList(Particle) = .{};
    defer list.deinit(gpa);

    try list.append(gpa, .{ .x = 1.0, .y = 2.0, .mass = 10.0, .active = true });
    try list.append(gpa, .{ .x = 3.0, .y = 4.0, .mass = 20.0, .active = false });

    const sl = list.slice();
    const xs = sl.items(.x);
    try testing.expectEqual(@as(f32, 1.0), xs[0]);
    try testing.expectEqual(@as(f32, 3.0), xs[1]);

    // .get reconstructs full struct
    const p = sl.get(0);
    try testing.expectEqual(@as(f64, 10.0), p.mass);
}

// === 3. SegmentedList pointer stability ===

test "SegmentedList: pointers stay valid across appends" {
    const gpa = testing.allocator;
    var list: std.SegmentedList(i32, 4) = .{};
    defer list.deinit(gpa);

    try list.append(gpa, 42);
    const ptr = list.at(0);
    try testing.expectEqual(@as(i32, 42), ptr.*);

    // Append many more — ptr must remain valid (key guarantee)
    for (0..100) |i| {
        try list.append(gpa, @intCast(i));
    }
    try testing.expectEqual(@as(i32, 42), ptr.*);
}

// === 4. BitSet operations (static + dynamic) ===

test "StaticBitSet and DynamicBitSet basics" {
    // Static: comptime size, no allocator
    var bits = std.StaticBitSet(16).initEmpty();
    bits.set(0);
    bits.set(5);
    bits.set(15);
    try testing.expectEqual(@as(usize, 3), bits.count());
    try testing.expect(bits.isSet(5));

    // Dynamic: runtime size, allocator-backed
    const gpa = testing.allocator;
    var dyn = try std.DynamicBitSet.initEmpty(gpa, 100);
    defer dyn.deinit();
    dyn.set(50);
    try testing.expect(dyn.isSet(50));

    // resize(new_size, fill_value) — fill param controls new bits
    try dyn.resize(200, false);
    try testing.expect(dyn.isSet(50));    // old bits preserved
    try testing.expect(!dyn.isSet(150));  // new bits are false
}

// === 5. EnumSet init and operations ===

const Color = enum { red, green, blue, alpha };

test "EnumSet: initEmpty, initMany, union, intersect" {
    var set = std.EnumSet(Color).initEmpty();
    set.insert(.red);
    set.insert(.blue);
    try testing.expect(set.contains(.red));
    try testing.expect(!set.contains(.green));

    const primary = std.EnumSet(Color).initMany(&[_]Color{ .red, .green, .blue });
    const transparent = std.EnumSet(Color).initMany(&[_]Color{ .green, .alpha });
    const combined = primary.unionWith(transparent);
    try testing.expect(combined.contains(.alpha));

    const overlap = primary.intersectWith(transparent);
    try testing.expect(overlap.contains(.green));
    try testing.expect(!overlap.contains(.red));
}

// === 6. EnumArray (all keys) vs EnumMap (sparse) ===

test "EnumArray vs EnumMap: dense vs sparse" {
    // EnumArray: every key always present
    var arr = std.EnumArray(Color, u32).initFill(0);
    arr.set(.red, 255);
    try testing.expectEqual(@as(u32, 255), arr.get(.red));
    try testing.expectEqual(@as(u32, 0), arr.get(.green)); // always has a value

    // EnumMap: keys can be absent
    var map = std.EnumMap(Color, []const u8).init(.{
        .red = "#FF0000",
        .blue = "#0000FF",
    });
    try testing.expectEqualStrings("#FF0000", map.get(.red).?);
    try testing.expectEqual(@as(?[]const u8, null), map.get(.green)); // absent
    try testing.expect(!map.contains(.green));

    map.put(.green, "#00FF00");
    try testing.expect(map.contains(.green));
}

// === 7. DoublyLinkedList intrusive pattern with @fieldParentPtr ===

const ListItem = struct {
    value: u32,
    node: std.DoublyLinkedList.Node = .{},
};

test "DoublyLinkedList: intrusive nodes + @fieldParentPtr" {
    var list: std.DoublyLinkedList = .{}; // .{} init, no allocator

    var a = ListItem{ .value = 10 };
    var b = ListItem{ .value = 20 };
    var c = ListItem{ .value = 30 };

    list.append(&a.node);
    list.append(&b.node);
    list.append(&c.node);
    try testing.expectEqual(@as(usize, 3), list.len());

    // Recover parent struct from node pointer
    var sum: u32 = 0;
    var it: ?*std.DoublyLinkedList.Node = list.first;
    while (it) |node| {
        const item: *ListItem = @fieldParentPtr("node", node);
        sum += item.value;
        it = node.next;
    }
    try testing.expectEqual(@as(u32, 60), sum);

    list.remove(&b.node);
    try testing.expectEqual(@as(usize, 2), list.len());
}

// === 8. StaticStringMap usage ===

test "StaticStringMap: comptime lookup table" {
    const TokenKind = enum { kw_if, kw_else, kw_while, kw_for, ident };
    const keywords = std.StaticStringMap(TokenKind).initComptime(.{
        .{ "if", .kw_if },
        .{ "else", .kw_else },
        .{ "while", .kw_while },
        .{ "for", .kw_for },
    });

    try testing.expectEqual(@as(?TokenKind, .kw_if), keywords.get("if"));
    try testing.expectEqual(@as(?TokenKind, null), keywords.get("func"));
    try testing.expect(keywords.has("while"));
    try testing.expect(!keywords.has("match"));
}
