const std = @import("std");
const testing = std.testing;
const builtin = @import("builtin");

// Minimal build system validation exercises — 5 tests

// 1. @hasDecl for feature detection
test "conditional compilation - comptime feature detection with @hasDecl" {
    // @hasDecl checks if a type/module exports a declaration
    const has_expect = @hasDecl(testing, "expect");
    try testing.expect(has_expect);

    // Can branch on @hasDecl at comptime
    if (@hasDecl(testing, "expectEqual")) {
        // Only compiles if testing exports expectEqual
        try testing.expectEqual(@as(u32, 1), @as(u32, 1));
    }
}

// 2. @hasField for struct introspection
test "conditional compilation - @hasField for struct introspection" {
    const Point = struct { x: f32, y: f32 };
    try testing.expect(@hasField(Point, "x"));
    try testing.expect(@hasField(Point, "y"));
    try testing.expect(!@hasField(Point, "z"));
}

// 3. @import("builtin") for platform info
test "conditional compilation - target OS and architecture" {
    // builtin.os.tag is known at comptime
    const os = builtin.os.tag;
    const path_sep: u8 = if (os == .windows) '\\' else '/';
    try testing.expect(path_sep == '/' or path_sep == '\\');

    // CPU architecture
    const arch = builtin.cpu.arch;
    const ptr_width = switch (arch) {
        .x86_64, .aarch64, .riscv64, .powerpc64, .powerpc64le, .s390x, .sparc64, .mips64, .mips64el, .loongarch64 => 64,
        .x86, .arm, .riscv32, .wasm32, .mips, .mipsel, .sparc, .m68k, .loongarch32 => 32,
        else => @bitSizeOf(usize),
    };
    try testing.expectEqual(@bitSizeOf(usize), ptr_width);
}

// 4. Conditional compilation patterns
test "conditional compilation - optimization mode" {
    const mode = builtin.mode;
    // builtin.OptimizeMode: .Debug, .ReleaseSafe, .ReleaseFast, .ReleaseSmall
    const has_safety = switch (mode) {
        .Debug, .ReleaseSafe => true,
        .ReleaseFast, .ReleaseSmall => false,
    };
    // In Debug mode (default), safety checks are on
    if (mode == .Debug) {
        try testing.expect(has_safety);
    }
}

// 5. Comptime feature flags with builtin.is_test
test "builtin info - is_test and endianness" {
    // builtin.is_test is true when compiled via zig test / b.addTest
    try testing.expect(builtin.is_test);

    // Endianness detection
    const endian = builtin.cpu.arch.endian();
    if (builtin.cpu.arch == .x86_64 or builtin.cpu.arch == .aarch64) {
        try testing.expect(endian == .little);
    }
}
