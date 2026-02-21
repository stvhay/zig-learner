// irc_protocol_parsing.zig — Patterns for zero-copy protocol parsing in Zig 0.15.2
//
// Patterns demonstrated:
// 1. Fixed-size array + len counter instead of self-referential slice (avoids dangling pointers)
// 2. Zero-copy parsing: all fields are slices into the original input (no allocation)
// 3. Method to reconstruct bounded slice on demand (safe alternative to stored slice)
// 4. Case-insensitive string comparison with std.ascii.eqlIgnoreCase
// 5. Thread-safe shared state with mutex + copy-in/copy-out (fixed buffers, no allocator)

const std = @import("std");
const testing = std.testing;

// Pattern 1: Fixed-size array + len counter avoids self-referential slices.
//
// PITFALL: Storing `params: []const []const u8` that points into `params_buf`
// creates a self-referential struct. When returned by value, the slice becomes
// a dangling pointer → segfault. Instead, store `params_len` and reconstruct
// the slice via a method.
//
// This pattern applies to ANY struct with bounded collections that must be
// returned by value. Use it instead of ArrayList when max size is comptime-known.
const Message = struct {
    prefix: ?[]const u8, // slice into original input — no allocation
    command: []const u8, // slice into original input
    params_buf: [15][]const u8 = undefined, // backing storage (max 15 per RFC 2812)
    params_len: usize = 0, // count — NOT a slice into params_buf

    // Reconstruct bounded slice on demand. Safe because it derives from
    // params_buf + params_len, not a stored pointer.
    pub fn params(self: *const Message) []const []const u8 {
        return self.params_buf[0..self.params_len];
    }
};

// Pattern 2: Zero-copy protocol parser. All returned slices borrow from `line`.
// Caller must keep `line` alive while using the Message.
fn parseMessage(line: []const u8) Message {
    var result: Message = .{ .prefix = null, .command = undefined };
    var rest = line;

    // Optional prefix starts with ':'
    if (rest.len > 0 and rest[0] == ':') {
        if (std.mem.indexOf(u8, rest, " ")) |idx| {
            result.prefix = rest[1..idx];
            rest = rest[idx + 1 ..];
        } else {
            result.prefix = rest[1..];
            result.command = "";
            return result;
        }
    }

    // Command
    if (std.mem.indexOf(u8, rest, " ")) |idx| {
        result.command = rest[0..idx];
        rest = rest[idx + 1 ..];
    } else {
        result.command = rest;
        return result;
    }

    // Parameters (last may be trailing with ':' prefix to include spaces)
    while (rest.len > 0 and result.params_len < 15) {
        if (rest[0] == ':') {
            result.params_buf[result.params_len] = rest[1..];
            result.params_len += 1;
            break;
        }
        if (std.mem.indexOf(u8, rest, " ")) |idx| {
            result.params_buf[result.params_len] = rest[0..idx];
            result.params_len += 1;
            rest = rest[idx + 1 ..];
        } else {
            result.params_buf[result.params_len] = rest;
            result.params_len += 1;
            break;
        }
    }
    return result;
}

test "zero-copy parse returns slices into input" {
    const line = ":Alice!a@host PRIVMSG #test :Hello world!";
    const msg = parseMessage(line);
    try testing.expectEqualStrings("Alice!a@host", msg.prefix.?);
    try testing.expectEqualStrings("PRIVMSG", msg.command);
    try testing.expectEqual(@as(usize, 2), msg.params().len);
    try testing.expectEqualStrings("#test", msg.params()[0]);
    try testing.expectEqualStrings("Hello world!", msg.params()[1]);
}

test "params method reconstructs slice safely (no dangling pointer)" {
    // Key: parseMessage returns Message by value. The params() method
    // reconstructs the slice from params_buf + params_len, so no
    // self-referential pointer can dangle.
    const msg = parseMessage(":server 001 nick :Welcome");
    const p = msg.params(); // safe — derived, not stored
    try testing.expectEqual(@as(usize, 2), p.len);
    try testing.expectEqualStrings("nick", p[0]);
    try testing.expectEqualStrings("Welcome", p[1]);
}

// Pattern 3: Case-insensitive string comparison for protocol commands.
// IRC commands are case-insensitive per RFC 2812. std.ascii.eqlIgnoreCase
// compares ASCII strings without allocation or locale dependency.
fn isCommand(msg: Message, cmd: []const u8) bool {
    return std.ascii.eqlIgnoreCase(msg.command, cmd);
}

test "case-insensitive command matching" {
    const msg1 = parseMessage("PRIVMSG #test :hi");
    try testing.expect(isCommand(msg1, "privmsg"));
    try testing.expect(isCommand(msg1, "PRIVMSG"));
    try testing.expect(isCommand(msg1, "Privmsg"));
    try testing.expect(!isCommand(msg1, "NOTICE"));
}

// Pattern 4: Thread-safe shared state with mutex + copy-in/copy-out.
// Fixed-size buffers avoid allocator dependency. Callers pass output
// buffers and receive copies, never references to internal state.
const SharedNick = struct {
    mutex: std.Thread.Mutex = .{},
    buf: [64]u8 = undefined,
    len: usize = 0,

    pub fn set(self: *SharedNick, nick: []const u8) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        const n = @min(nick.len, 64);
        @memcpy(self.buf[0..n], nick[0..n]);
        self.len = n;
    }

    // Returns a copy into caller's buffer — safe across threads.
    pub fn get(self: *SharedNick, out: []u8) []const u8 {
        self.mutex.lock();
        defer self.mutex.unlock();
        const n = @min(self.len, out.len);
        @memcpy(out[0..n], self.buf[0..n]);
        return out[0..n];
    }
};

test "thread-safe shared nickname" {
    var shared: SharedNick = .{};
    shared.set("Alice");

    var out: [64]u8 = undefined;
    try testing.expectEqualStrings("Alice", shared.get(&out));

    shared.set("Bob");
    try testing.expectEqualStrings("Bob", shared.get(&out));
}
