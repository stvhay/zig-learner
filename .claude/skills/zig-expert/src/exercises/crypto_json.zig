// Crypto + JSON patterns for Zig 0.15.2
// Covers: AES-256-GCM, Argon2id KDF, parseFromSlice .alloc_always,
//         and the dangling pointer pitfall with .alloc_if_needed.

const std = @import("std");
const crypto = std.crypto;
const json = std.json;
const testing = std.testing;

const Aes256Gcm = crypto.aead.aes_gcm.Aes256Gcm;

// ── AES-256-GCM Encrypt/Decrypt ──────────────────────────────────
// Key: [32]u8, Nonce: [12]u8, Tag: [16]u8
// ad (associated data): &.{} for empty

fn encryptData(allocator: std.mem.Allocator, key: [32]u8, plaintext: []const u8) !struct { ciphertext: []u8, nonce: [12]u8, tag: [16]u8 } {
    var nonce: [12]u8 = undefined;
    crypto.random.bytes(&nonce);
    const ciphertext = try allocator.alloc(u8, plaintext.len);
    var tag: [16]u8 = undefined;
    Aes256Gcm.encrypt(ciphertext, &tag, plaintext, &.{}, nonce, key);
    return .{ .ciphertext = ciphertext, .nonce = nonce, .tag = tag };
}

fn decryptData(allocator: std.mem.Allocator, key: [32]u8, ciphertext: []const u8, nonce: [12]u8, tag: [16]u8) ![]u8 {
    const plaintext = try allocator.alloc(u8, ciphertext.len);
    errdefer allocator.free(plaintext);
    Aes256Gcm.decrypt(plaintext, ciphertext, tag, &.{}, nonce, key) catch
        return error.AuthenticationFailed;
    return plaintext;
}

test "AES-256-GCM round-trip" {
    const gpa = testing.allocator;
    var key: [32]u8 = undefined;
    crypto.random.bytes(&key);
    const message = "secret data";
    const enc = try encryptData(gpa, key, message);
    defer gpa.free(enc.ciphertext);
    const dec = try decryptData(gpa, key, enc.ciphertext, enc.nonce, enc.tag);
    defer gpa.free(dec);
    try testing.expectEqualStrings(message, dec);
}

test "AES-256-GCM wrong key fails" {
    const gpa = testing.allocator;
    var key: [32]u8 = undefined;
    crypto.random.bytes(&key);
    const enc = try encryptData(gpa, key, "data");
    defer gpa.free(enc.ciphertext);
    var wrong_key: [32]u8 = undefined;
    crypto.random.bytes(&wrong_key);
    try testing.expectError(error.AuthenticationFailed, decryptData(gpa, wrong_key, enc.ciphertext, enc.nonce, enc.tag));
}

// ── Argon2id Key Derivation ──────────────────────────────────────
// allocator is FIRST param. salt is *const [16]u8 (pointer to array).

fn deriveKey(allocator: std.mem.Allocator, password: []const u8, salt: [16]u8) ![32]u8 {
    var derived: [32]u8 = undefined;
    try crypto.pwhash.argon2.kdf(
        allocator,
        &derived,
        password,
        &salt, // pointer to the array
        .{ .t = 3, .m = 65536, .p = 1 },
        .argon2id,
    );
    return derived;
}

test "Argon2id deterministic with same salt" {
    const gpa = testing.allocator;
    var salt: [16]u8 = undefined;
    crypto.random.bytes(&salt);
    const k1 = try deriveKey(gpa, "password", salt);
    const k2 = try deriveKey(gpa, "password", salt);
    try testing.expectEqual(k1, k2);
}

test "Argon2id different salt produces different key" {
    const gpa = testing.allocator;
    var s1: [16]u8 = undefined;
    var s2: [16]u8 = undefined;
    crypto.random.bytes(&s1);
    crypto.random.bytes(&s2);
    const k1 = try deriveKey(gpa, "password", s1);
    const k2 = try deriveKey(gpa, "password", s2);
    try testing.expect(!std.mem.eql(u8, &k1, &k2));
}

// ── JSON parseFromSlice: .alloc_always vs dangling pointers ──────
// CRITICAL PATTERN: Default .alloc_if_needed makes []const u8 fields
// point directly into the input buffer. If you free the input buffer,
// the parsed strings become dangling pointers (0xAA in debug mode).
//
// Use .alloc_always when the input buffer has a shorter lifetime
// than the parsed result.

const Record = struct {
    name: []const u8,
    value: []const u8,
};

const Data = struct {
    records: []const Record,
};

test "parseFromSlice .alloc_always prevents dangling pointers" {
    const gpa = testing.allocator;

    // Simulate: parse JSON from a buffer that will be freed
    const input = try gpa.dupe(u8,
        \\{"records":[{"name":"key1","value":"val1"}]}
    );

    // Parse with .alloc_always — strings are independently allocated
    const parsed = try json.parseFromSlice(Data, gpa, input, .{ .allocate = .alloc_always });
    defer parsed.deinit();

    // Free the input buffer — with .alloc_always, parsed strings survive
    gpa.free(input);

    // Strings are still valid because they were copied, not referenced
    try testing.expectEqualStrings("key1", parsed.value.records[0].name);
    try testing.expectEqualStrings("val1", parsed.value.records[0].value);
}

test "JSON round-trip with allocPrint and parseFromSlice" {
    const gpa = testing.allocator;

    const records = [_]Record{
        .{ .name = "github", .value = "s3cret" },
        .{ .name = "email", .value = "hunter2" },
    };
    const data = Data{ .records = &records };

    // Serialize: {f} format specifier
    const serialized = try std.fmt.allocPrint(gpa, "{f}", .{json.fmt(data, .{})});
    defer gpa.free(serialized);

    // Deserialize with .alloc_always (safe even if serialized is later freed)
    const parsed = try json.parseFromSlice(Data, gpa, serialized, .{ .allocate = .alloc_always });
    defer parsed.deinit();

    try testing.expectEqual(@as(usize, 2), parsed.value.records.len);
    try testing.expectEqualStrings("github", parsed.value.records[0].name);
    try testing.expectEqualStrings("hunter2", parsed.value.records[1].value);
}
