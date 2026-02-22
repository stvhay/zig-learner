// Peer Type Resolution — patterns that trip up comptime evaluation
//
// KEY INSIGHT: When testing peer type resolution in if/else or switch,
// the condition must be runtime-evaluated. A comptime-known condition
// causes dead branch elimination — the compiler never resolves peer types.
const std = @import("std");
const expect = std.testing.expect;

// PATTERN 1: Force runtime evaluation with `var + _ = &var`
// Without this, `const cond = true` makes the else branch dead code.
test "T and null peer resolves to ?T (runtime condition)" {
    var cond = true;
    _ = &cond; // prevent comptime evaluation
    const result = if (cond) @as(u32, 42) else null;
    // Peer type: u32 + @TypeOf(null) = ?u32
    try expect(@TypeOf(result) == ?u32);
    try expect(result.? == 42);
}

// PATTERN 2: Error peer resolution produces specific error set, not anyerror
test "T and error.X peer resolves to error{X}!T" {
    var cond = true;
    _ = &cond;
    const result = if (cond) @as(u32, 42) else error.Fail;
    // Peer type: u32 + error{Fail} = error{Fail}!u32
    try expect(@TypeOf(result) == error{Fail}!u32);
    const val = try result;
    try expect(val == 42);
}

// PATTERN 3: comptime_int + concrete type => concrete type
test "comptime_int widens to concrete integer type" {
    const a: u32 = 10;
    const b = 20; // comptime_int
    const c = a + b;
    try expect(@TypeOf(c) == u32);
}

// PATTERN 4: *[N]T coerces to []T
test "pointer to array coerces to slice" {
    var arr = [_]u32{ 1, 2, 3 };
    const slice: []u32 = &arr;
    try expect(slice.len == 3);
}
