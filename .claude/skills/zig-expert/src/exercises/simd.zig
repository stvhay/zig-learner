// Minimal SIMD / @Vector exercises — validates core patterns against the compiler.

const std = @import("std");
const testing = std.testing;
const simd = std.simd;

test "@Vector creation and element-wise arithmetic" {
    const a: @Vector(4, i32) = .{ 10, 20, 30, 40 };
    const b: @Vector(4, i32) = .{ 1, 2, 3, 4 };

    const sum = a + b;
    try testing.expectEqual([4]i32{ 11, 22, 33, 44 }, @as([4]i32, sum));

    const prod = a * b;
    try testing.expectEqual([4]i32{ 10, 40, 90, 160 }, @as([4]i32, prod));

    // Array <-> vector implicit coercion
    const arr = [4]i32{ 5, 6, 7, 8 };
    const vec: @Vector(4, i32) = arr;
    const back: [4]i32 = vec;
    try testing.expectEqual(@as(i32, 5), back[0]);
}

test "@splat requires type context via @as — common gotcha" {
    // CORRECT: @as provides the target vector type
    const vec = @as(@Vector(4, u32), @splat(42));
    try testing.expectEqual(@as(u32, 42), vec[0]);
    try testing.expectEqual(@as(u32, 42), vec[3]);

    // CORRECT: variable annotation provides type context
    const fvec: @Vector(4, f32) = @splat(3.14);
    try testing.expectApproxEqAbs(@as(f32, 3.14), fvec[2], 0.001);

    // Scalar-vector multiply via @splat
    const a: @Vector(4, u32) = .{ 10, 20, 30, 40 };
    const scaled = a * @as(@Vector(4, u32), @splat(3));
    try testing.expectEqual([4]u32{ 30, 60, 90, 120 }, @as([4]u32, scaled));
}

test "@reduce operations: Add, Min, Max" {
    const v: @Vector(4, i32) = .{ 30, -10, 50, 20 };
    try testing.expectEqual(@as(i32, 90), @reduce(.Add, v));
    try testing.expectEqual(@as(i32, -10), @reduce(.Min, v));
    try testing.expectEqual(@as(i32, 50), @reduce(.Max, v));

    // Boolean reduce
    const bv: @Vector(4, bool) = .{ true, false, true, true };
    try testing.expectEqual(false, @reduce(.And, bv)); // not all true
    try testing.expectEqual(true, @reduce(.Or, bv));   // some true
}

test "@shuffle for reordering and merging" {
    const a: @Vector(4, u32) = .{ 10, 20, 30, 40 };

    // Reverse
    const rev = @shuffle(u32, a, undefined, @Vector(4, i32){ 3, 2, 1, 0 });
    try testing.expectEqual([4]u32{ 40, 30, 20, 10 }, @as([4]u32, rev));

    // Merge from two vectors: positive = a, ~idx = b
    const b: @Vector(4, u32) = .{ 50, 60, 70, 80 };
    const mix = @shuffle(u32, a, b, @Vector(4, i32){ 0, ~@as(i32, 0), 1, ~@as(i32, 1) });
    try testing.expectEqual([4]u32{ 10, 50, 20, 60 }, @as([4]u32, mix));
}

test "@select for conditional element selection" {
    // @select(ElementType, pred, a, b) — first param is element type
    const mask: @Vector(4, bool) = .{ true, false, true, false };
    const a: @Vector(4, u32) = .{ 1, 2, 3, 4 };
    const b: @Vector(4, u32) = .{ 10, 20, 30, 40 };

    const result = @select(u32, mask, a, b);
    try testing.expectEqual([4]u32{ 1, 20, 3, 40 }, @as([4]u32, result));
}

test "comparisons return @Vector(N, bool)" {
    const a: @Vector(4, i32) = .{ 10, 20, 30, 40 };
    const b: @Vector(4, i32) = .{ 15, 15, 35, 35 };

    const gt: @Vector(4, bool) = a > b;
    try testing.expectEqual(@Vector(4, bool){ false, true, false, true }, gt);

    const eq: @Vector(4, bool) = a == b;
    try testing.expectEqual(@Vector(4, bool){ false, false, false, false }, eq);
}

test "dot product pattern: multiply + @reduce(.Add)" {
    const a: @Vector(4, f32) = .{ 1.0, 2.0, 3.0, 4.0 };
    const b: @Vector(4, f32) = .{ 5.0, 6.0, 7.0, 8.0 };
    const dot = @reduce(.Add, a * b);
    try testing.expectApproxEqAbs(@as(f32, 70.0), dot, 0.001);

    // Element-wise clamp: @max(low, @min(val, high))
    const values: @Vector(4, i32) = .{ -10, 50, 150, 75 };
    const clamped = @max(
        @as(@Vector(4, i32), @splat(0)),
        @min(values, @as(@Vector(4, i32), @splat(100))),
    );
    try testing.expectEqual([4]i32{ 0, 50, 100, 75 }, @as([4]i32, clamped));
}

test "std.simd.countTrues for counting matching elements" {
    const values: @Vector(8, i32) = .{ -5, 10, -3, 20, 0, -1, 15, -8 };
    const zero = @as(@Vector(8, i32), @splat(0));
    const positive_mask: @Vector(8, bool) = values > zero;
    const count = simd.countTrues(positive_mask);
    try testing.expectEqual(@as(u4, 3), count); // 10, 20, 15
}
