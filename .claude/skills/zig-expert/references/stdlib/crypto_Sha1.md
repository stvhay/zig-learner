// Zig 0.15.2 std.crypto.Sha1 — API signatures + doc comments

pub const Options = struct {};

pub fn init(options: Options) Sha1

pub fn hash(b: []const u8, out: *[digest_length]u8, options: Options) void

pub fn update(d: *Sha1, b: []const u8) void

pub fn peek(d: Sha1) [digest_length]u8

pub fn final(d: *Sha1, out: *[digest_length]u8) void

pub fn finalResult(d: *Sha1) [digest_length]u8
