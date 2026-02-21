// signal_proxy.zig — Curated patterns for signal handling and HTTP proxying in Zig 0.15.2
//
// Patterns demonstrated:
// 1. Signal handler registration (SIGINT/SIGTERM) with posix.Sigaction
// 2. macOS accept() shutdown workaround (self-connection)
// 3. Case-insensitive HTTP header matching
// 4. Content-Length extraction from HTTP headers
// 5. nanoTimestamp for performance measurement

const std = @import("std");
const posix = std.posix;
const net = std.net;
const mem = std.mem;
const testing = std.testing;
const Atomic = std.atomic.Value;

// Pattern 1: Signal handler registration
// Key: handler uses callconv(.c), Sigaction struct with sigemptyset mask
// Key: on macOS, sigaction() does NOT return an error — no catch needed
// Key: use atomic flag for cross-thread signaling from handler
var signal_received = Atomic(bool).init(false);

fn testSignalHandler(_: c_int) callconv(.c) void {
    signal_received.store(true, .seq_cst);
}

test "signal handler registration" {
    const sa = posix.Sigaction{
        .handler = .{ .handler = testSignalHandler },
        .mask = posix.sigemptyset(),
        .flags = 0,
    };
    // Register handler — sigaction returns void on macOS (no catch)
    posix.sigaction(posix.SIG.INT, &sa, null);
    // Verify we can check the flag
    try testing.expect(!signal_received.load(.seq_cst));
}

// Pattern 2: macOS accept() shutdown workaround
// SO_RCVTIMEO does NOT unblock accept() on macOS.
// Solution: a monitor thread polls the running flag, then self-connects to unblock accept().
test "self-connection unblocks accept" {
    const addr = net.Address.parseIp4("127.0.0.1", 0) catch unreachable;
    var server = try addr.listen(.{ .reuse_address = true });
    defer server.deinit();

    const port = server.listen_address.getPort();

    // Simulate self-connection (what shutdown monitor does)
    const wake_addr = net.Address.parseIp4("127.0.0.1", port) catch unreachable;
    const stream = try net.tcpConnectToAddress(wake_addr);
    stream.close();

    // accept() would return this connection, unblocking the loop
    const conn = try server.accept();
    conn.stream.close();
}

// Pattern 3: Case-insensitive HTTP header matching
// HTTP headers are case-insensitive per RFC 7230 section 3.2
fn asciiStartsWithIgnoreCase(haystack: []const u8, needle: []const u8) bool {
    if (haystack.len < needle.len) return false;
    for (haystack[0..needle.len], needle) |h, n| {
        if (std.ascii.toLower(h) != std.ascii.toLower(n)) return false;
    }
    return true;
}

test "case-insensitive header matching" {
    try testing.expect(asciiStartsWithIgnoreCase("Content-Length: 42", "content-length:"));
    try testing.expect(asciiStartsWithIgnoreCase("CONTENT-LENGTH: 42", "content-length:"));
    try testing.expect(asciiStartsWithIgnoreCase("content-length: 42", "content-length:"));
    try testing.expect(!asciiStartsWithIgnoreCase("Content-Type: text", "content-length:"));
    try testing.expect(!asciiStartsWithIgnoreCase("short", "content-length:"));
}

// Pattern 4: Extract Content-Length from HTTP headers
// Scan line-by-line for "Content-Length:" header, parse integer value
fn findContentLength(headers: []const u8) ?usize {
    var pos: usize = 0;
    while (pos < headers.len) {
        const line_end = mem.indexOf(u8, headers[pos..], "\r\n") orelse break;
        const line = headers[pos .. pos + line_end];
        if (line.len == 0) break; // blank line = end of headers
        if (asciiStartsWithIgnoreCase(line, "content-length:")) {
            const val = mem.trim(u8, line["content-length:".len..], " ");
            return std.fmt.parseInt(usize, val, 10) catch null;
        }
        pos += line_end + 2;
    }
    return null;
}

test "content-length extraction" {
    const headers = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 1234\r\nConnection: close\r\n\r\nbody";
    try testing.expectEqual(@as(?usize, 1234), findContentLength(headers));

    const no_cl = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n";
    try testing.expectEqual(@as(?usize, null), findContentLength(no_cl));

    const mixed_case = "HTTP/1.1 200 OK\r\ncontent-length: 42\r\n\r\n";
    try testing.expectEqual(@as(?usize, 42), findContentLength(mixed_case));
}

// Pattern 5: nanoTimestamp for performance measurement
// Returns i128; cast difference to u64 for nanoseconds elapsed
test "nanoTimestamp timing" {
    const t0 = std.time.nanoTimestamp();
    std.Thread.sleep(1_000_000); // 1ms
    const t1 = std.time.nanoTimestamp();
    const elapsed_ns: u64 = @intCast(t1 - t0);
    // Should be at least 1ms (1_000_000 ns)
    try testing.expect(elapsed_ns >= 500_000); // allow some slack
    // Convert to milliseconds
    const elapsed_ms = elapsed_ns / 1_000_000;
    try testing.expect(elapsed_ms >= 1);
}
