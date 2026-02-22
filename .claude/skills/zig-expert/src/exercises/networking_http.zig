// networking_http.zig — Curated patterns for TCP servers and HTTP in Zig 0.15.2
//
// Patterns demonstrated:
// 1. TCP server: parseIp4 + listen + accept
// 2. Socket timeout via SO_RCVTIMEO
// 3. Thread-per-connection with detach
// 4. URL percent-decoding
// 5. Path traversal detection (pre-filesystem check)
// 6. HTTP date formatting with EpochSeconds
// 7. Thread-safe logging with Mutex + atomic write
// 8. TCP stream read loop — handle partial reads in test helpers

const std = @import("std");
const mem = std.mem;
const net = std.net;
const posix = std.posix;
const testing = std.testing;

// Pattern 1: TCP server lifecycle — parseIp4, listen, accept, read/write
// Key: addr.listen returns Server with .accept() → Connection with .stream + .address
// Key: server.deinit() (NOT server.close())
test "tcp server accept pattern" {
    const addr = net.Address.parseIp4("127.0.0.1", 0) catch unreachable; // port 0 = OS picks
    var server = try addr.listen(.{ .reuse_address = true });
    defer server.deinit();

    // Get actual bound port
    const bound_port = server.listen_address.getPort();
    try testing.expect(bound_port > 0);

    // Connect from client side
    const client = try net.tcpConnectToAddress(
        net.Address.parseIp4("127.0.0.1", bound_port) catch unreachable,
    );
    defer client.close();

    // Accept on server side
    const conn = try server.accept();
    defer conn.stream.close();

    // Client writes, server reads
    try client.writeAll("hello");
    var buf: [64]u8 = undefined;
    const n = try conn.stream.read(&buf);
    try testing.expectEqualStrings("hello", buf[0..n]);
}

// Pattern 2: Socket timeout via setsockopt SO_RCVTIMEO
// Key: posix.timeval{ .sec, .usec }, setsockopt with SOL.SOCKET + SO.RCVTIMEO
// Key: mem.asBytes(&timeout) to pass struct as byte slice
// GOTCHA: SO_RCVTIMEO does NOT unblock accept() on macOS — only works on read()
test "socket timeout pattern" {
    const timeout = posix.timeval{ .sec = 1, .usec = 0 };
    // This is how you'd set it on a connection's stream handle:
    // posix.setsockopt(conn.stream.handle, posix.SOL.SOCKET,
    //     posix.SO.RCVTIMEO, mem.asBytes(&timeout)) catch {};
    _ = timeout;
}

// Pattern 3: URL percent-decoding
// Key: %XX where XX is two hex digits → single byte
// Key: Must decode BEFORE path traversal check (encoded ".." = "%2e%2e")
fn urlDecode(input: []const u8, out: []u8) ![]const u8 {
    var i: usize = 0;
    var o: usize = 0;
    while (i < input.len) {
        if (i + 2 < input.len and input[i] == '%') {
            const hi = hexDigit(input[i + 1]) orelse return error.InvalidEncoding;
            const lo = hexDigit(input[i + 2]) orelse return error.InvalidEncoding;
            out[o] = (@as(u8, hi) << 4) | lo;
            o += 1;
            i += 3;
        } else {
            out[o] = input[i];
            o += 1;
            i += 1;
        }
    }
    return out[0..o];
}

fn hexDigit(c: u8) ?u4 {
    if (c >= '0' and c <= '9') return @intCast(c - '0');
    if (c >= 'a' and c <= 'f') return @intCast(c - 'a' + 10);
    if (c >= 'A' and c <= 'F') return @intCast(c - 'A' + 10);
    return null;
}

test "url decode" {
    var buf: [256]u8 = undefined;
    const r1 = try urlDecode("/about%2Ehtml", &buf);
    try testing.expectEqualStrings("/about.html", r1);

    const r2 = try urlDecode("/%2e%2e/etc/passwd", &buf);
    try testing.expectEqualStrings("/../etc/passwd", r2);

    const r3 = try urlDecode("/hello%20world", &buf);
    try testing.expectEqualStrings("/hello world", r3);
}

// Pattern 4a: Path traversal detection — string-matching approach
// Key: realpathAlloc fails for non-existent paths → would give 404 not 403
// Key: Must check AFTER url-decoding (encoded %2e%2e = "..")
fn containsTraversal(path: []const u8) bool {
    const p = if (path.len > 0 and path[0] == '/') path[1..] else path;
    return mem.eql(u8, p, "..") or mem.startsWith(u8, p, "../") or
        mem.endsWith(u8, p, "/..") or mem.indexOf(u8, p, "/../") != null;
}

test "path traversal detection (string matching)" {
    try testing.expect(containsTraversal("/../etc/passwd"));
    try testing.expect(containsTraversal("/subdir/../../etc/passwd"));
    try testing.expect(containsTraversal("../etc/passwd"));
    try testing.expect(!containsTraversal("/index.html"));
    try testing.expect(!containsTraversal("/subdir/nested.html"));
}

// Pattern 4b: Path traversal detection — depth-tracking approach (preferred)
// Key: Walk path components, track depth relative to root. If depth goes negative,
//      the path escapes the root. More robust than string-matching: handles arbitrary
//      nesting like "/a/b/c/../../../.." without enumerating patterns.
// Key: Uses tokenizeScalar (not splitScalar) to skip empty components from "//"
// Key: No allocations needed — pure arithmetic on path components
fn isPathSafe(decoded_path: []const u8) bool {
    var depth: i32 = 0;
    var it = mem.tokenizeScalar(u8, decoded_path, '/');
    while (it.next()) |component| {
        if (mem.eql(u8, component, "..")) {
            depth -= 1;
            if (depth < 0) return false; // Escaped root
        } else if (!mem.eql(u8, component, ".")) {
            depth += 1;
        }
    }
    return true;
}

test "path traversal detection (depth tracking)" {
    // Traversal attacks — should be rejected
    try testing.expect(!isPathSafe("/../etc/passwd"));
    try testing.expect(!isPathSafe("/subdir/../../etc/passwd"));
    try testing.expect(!isPathSafe("../etc/passwd"));
    try testing.expect(!isPathSafe("/a/b/c/../../../../etc/passwd"));
    // Safe paths
    try testing.expect(isPathSafe("/index.html"));
    try testing.expect(isPathSafe("/subdir/nested.html"));
    try testing.expect(isPathSafe("/a/b/../b/file.html")); // stays within root
}

// Pattern 5: HTTP date formatting with EpochSeconds
// Key: epoch day 0 = Thursday (1970-01-01)
// Key: @mod(day + 4, 7) gives 0=Sun..6=Sat
// Key: month_day.day_index is 0-based, add 1 for display
// Key: month_day.month is enum starting at 1 — @intFromEnum - 1 for array index
// GOTCHA: No calculateDayOfWeek() method — must compute manually
fn formatHttpDate(buf: []u8) []const u8 {
    const ts: i64 = std.time.timestamp();
    const epoch_secs = std.time.epoch.EpochSeconds{ .secs = @intCast(ts) };
    const epoch_day = epoch_secs.getEpochDay();
    const year_day = epoch_day.calculateYearDay();
    const month_day = year_day.calculateMonthDay();
    const day_secs = epoch_secs.getDaySeconds();

    const dow_idx = @mod(epoch_day.day + 4, 7);
    const dow = [_][]const u8{ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };
    const mon = [_][]const u8{ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };

    return std.fmt.bufPrint(buf, "{s}, {d:0>2} {s} {d} {d:0>2}:{d:0>2}:{d:0>2} GMT", .{
        dow[dow_idx],
        month_day.day_index + 1,
        mon[@intFromEnum(month_day.month) - 1],
        year_day.year,
        day_secs.getHoursIntoDay(),
        day_secs.getMinutesIntoHour(),
        day_secs.getSecondsIntoMinute(),
    }) catch return buf[0..0];
}

test "http date format" {
    var buf: [64]u8 = undefined;
    const date = formatHttpDate(&buf);
    // Should contain "GMT" at the end
    try testing.expect(mem.endsWith(u8, date, "GMT"));
    // Should have day-of-week at start
    try testing.expect(date.len >= 29); // "Thu, 01 Jan 2025 12:00:00 GMT"
}

// Pattern 6: Thread-safe logging with Mutex + bufPrint + atomic write
// Key: Format FIRST into local buffer, THEN lock mutex and write
// Key: Use File.writeAll() directly (not buffered writer) for atomic writes
// Key: Extract IP octets via @truncate + shift from addr.in.sa.addr
test "ip extraction from net.Address" {
    const addr = net.Address.parseIp4("127.0.0.1", 8080) catch unreachable;
    const ip = addr.in.sa.addr;
    const a: u8 = @truncate(ip);
    const b: u8 = @truncate(ip >> 8);
    const c: u8 = @truncate(ip >> 16);
    const d: u8 = @truncate(ip >> 24);
    try testing.expectEqual(@as(u8, 127), a);
    try testing.expectEqual(@as(u8, 0), b);
    try testing.expectEqual(@as(u8, 0), c);
    try testing.expectEqual(@as(u8, 1), d);
}

// Pattern 8: TCP stream read loop — stream.read() may return partial data
// GOTCHA: A single read() on a TCP stream can return fewer bytes than the sender wrote.
// For protocol-framed data (RESP, HTTP, etc.), the test helper must loop until a
// complete message is received. Without this, tests pass locally but fail under load
// or on CI where TCP segments fragment differently.
//
// Key: accumulate into buffer, check completeness after each read, time out if stuck.
// Key: std.Thread.sleep(ns) for delays — NOT std.time.sleep (does not exist in 0.15.2).
fn readFullResponse(stream: net.Stream, buf: []u8, timeout_ms: u64) ![]const u8 {
    var total: usize = 0;
    const deadline = @as(u64, @intCast(std.time.milliTimestamp())) + timeout_ms;
    while (total < buf.len) {
        const n = stream.read(buf[total..]) catch |err| switch (err) {
            error.WouldBlock => {
                if (@as(u64, @intCast(std.time.milliTimestamp())) >= deadline)
                    return error.Timeout;
                std.Thread.sleep(1_000_000); // 1ms
                continue;
            },
            else => return err,
        };
        if (n == 0) break; // peer closed
        total += n;
        // Check if response is complete (example: RESP simple string ends with \r\n)
        if (total >= 2 and buf[total - 2] == '\r' and buf[total - 1] == '\n')
            break;
    }
    return buf[0..total];
}

test "tcp read loop handles partial data" {
    const addr = net.Address.parseIp4("127.0.0.1", 0) catch unreachable;
    var server = try addr.listen(.{ .reuse_address = true });
    defer server.deinit();
    const port = server.listen_address.getPort();

    // Server thread: write response in two parts to simulate fragmentation
    const t = try std.Thread.spawn(.{}, struct {
        fn run(s: *net.Server) void {
            const conn = s.accept() catch return;
            defer conn.stream.close();
            conn.stream.writeAll("+PO") catch return;
            std.Thread.sleep(5_000_000); // 5ms gap between fragments
            conn.stream.writeAll("NG\r\n") catch return;
        }
    }.run, .{&server});
    defer t.join();

    const client = try net.tcpConnectToAddress(
        net.Address.parseIp4("127.0.0.1", port) catch unreachable,
    );
    defer client.close();

    var buf: [64]u8 = undefined;
    const resp = try readFullResponse(client, &buf, 5000);
    try testing.expectEqualStrings("+PONG\r\n", resp);
}
