# Zig Systems Reference (0.15.2)

## Concurrency

All primitives init with `.{}` — static initialization, no allocator.

```zig
// Thread
const t = try std.Thread.spawn(.{}, worker, .{ arg1, arg2 });
t.join(); // or t.detach()
Thread.sleep(1_000_000_000); // nanoseconds
const cpus = try Thread.getCpuCount();

// Mutex
var mutex: Thread.Mutex = .{};
mutex.lock(); defer mutex.unlock();

// Condition (MUST loop — spurious wakeups)
var cond: Thread.Condition = .{};
while (!predicate) cond.wait(&mutex); // atomically unlock+block+relock
cond.signal(); // one waiter
cond.broadcast(); // all waiters

// RwLock (multiple readers OR one writer)
var rw: Thread.RwLock = .{};
rw.lockShared(); defer rw.unlockShared();
rw.lock(); defer rw.unlock();

// Semaphore (limit to N concurrent)
var sem: Thread.Semaphore = .{ .permits = 3 };
sem.wait(); sem.post();

// ResetEvent (one-shot signal — NEVER reset() while threads wait)
var ev: Thread.ResetEvent = .{};
ev.set(); ev.wait();

// WaitGroup (wait for N tasks)
var wg: Thread.WaitGroup = .{};
wg.start(); // before spawn
// ... in worker: defer wg.finish(); // MUST call — Pool does NOT
wg.wait();

// Thread Pool
var pool: Thread.Pool = undefined;
try pool.init(.{ .allocator = gpa, .n_jobs = 4 });
defer pool.deinit();
wg.start();
try pool.spawn(worker, .{ &wg, &data });
```

### Atomics
```zig
var counter = std.atomic.Value(u32).init(0);
counter.store(42, .seq_cst);
const val = counter.load(.seq_cst);
_ = counter.fetchAdd(1, .monotonic); // returns OLD value
// Also: fetchSub, fetchOr, fetchAnd, fetchXor

// CAS: null on success, current value on failure
const result = counter.cmpxchgWeak(expected, new, .acq_rel, .monotonic);
// cmpxchgWeak may spuriously fail — always loop
// cmpxchgStrong never spuriously fails but may be slower
const old = counter.swap(new, .seq_cst); // unconditional swap

// Ordering guide:
// .seq_cst      — when unsure (strongest, most expensive)
// .acq_rel      — producer/consumer (acquire on load, release on store)
// .acquire      — "see all writes from the releaser"
// .release      — "make my writes visible to acquirers"
// .monotonic    — simple counters where cross-thread ordering doesn't matter

std.atomic.spinLoopHint(); // PAUSE (x86) / YIELD (ARM)
const cl = std.atomic.cache_line; // for false-sharing prevention (align to this)
```

## Networking

```zig
// TCP server
const addr = std.net.Address.parseIp4("127.0.0.1", 8080) catch unreachable;
var server = try addr.listen(.{ .reuse_address = true });
defer server.deinit();

while (true) {
    const conn = try server.accept(); // .stream + .address
    defer conn.stream.close();
    const n = try conn.stream.read(&buf);
    try conn.stream.writeAll("HTTP/1.1 200 OK\r\n\r\n");
}

// Concurrent: Thread.spawn per connection, detach

// Socket timeout
const timeout = std.posix.timeval{ .sec = 5, .usec = 0 };
std.posix.setsockopt(conn.stream.handle, std.posix.SOL.SOCKET,
    std.posix.SO.RCVTIMEO, std.mem.asBytes(&timeout)) catch {};
// GOTCHA: SO_RCVTIMEO does NOT unblock accept() on macOS — use shutdown monitor

// IP extraction (reliable — {any} format may fail in some contexts)
const ip = addr.in.sa.addr; // u32 network byte order
const a: u8 = @truncate(ip);
const b: u8 = @truncate(ip >> 8);
const c: u8 = @truncate(ip >> 16);
const d: u8 = @truncate(ip >> 24);
// Port: std.mem.bigToNative(u16, addr.in.sa.port)

// TCP client
const stream = try std.net.tcpConnectToAddress(backend_addr);
defer stream.close();
```

### Signal Handling (macOS)
```zig
var running = std.atomic.Value(bool).init(true);
fn handler(_: c_int) callconv(.c) void { running.store(false, .seq_cst); }
const sa = std.posix.Sigaction{
    .handler = .{ .handler = handler },
    .mask = std.posix.sigemptyset(), // NOT empty_sigset (doesn't exist)
    .flags = 0,
};
std.posix.sigaction(std.posix.SIG.INT, &sa, null);
// GOTCHA: returns void on macOS — no catch! (Linux may return !void)
```

### Shutdown Pattern (macOS accept() workaround)
```zig
// Self-connection unblocks accept() since SO_RCVTIMEO doesn't help
fn shutdownMonitor(port: u16) void {
    while (running.load(.seq_cst)) Thread.sleep(200_000_000);
    const addr = std.net.Address.parseIp4("127.0.0.1", port) catch return;
    const stream = std.net.tcpConnectToAddress(addr) catch return;
    stream.close();
}
```

### Date/Time
```zig
const epoch_secs = std.time.epoch.EpochSeconds{ .secs = @intCast(std.time.timestamp()) };
const epoch_day = epoch_secs.getEpochDay();
const year_day = epoch_day.calculateYearDay();
const month_day = year_day.calculateMonthDay();
const day_secs = epoch_secs.getDaySeconds();
// Day of week: epoch 0 = Thursday, day % 7 → [Thu,Fri,Sat,Sun,Mon,Tue,Wed]
// GOTCHA: calculateDayOfWeek() does NOT exist — compute manually
```

### Path Traversal Defense
```zig
// realpathAlloc fails for non-existent paths → 404 not 403
// Pre-check for ".." BEFORE filesystem access for correct 403

// Approach 1: String matching (simple but may miss edge cases)
fn containsTraversal(p: []const u8) bool {
    return mem.eql(u8, p, "..") or mem.startsWith(u8, p, "../")
        or mem.endsWith(u8, p, "/..") or mem.indexOf(u8, p, "/../") != null;
}

// Approach 2: Depth tracking (preferred — handles arbitrary nesting, no allocations)
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
```

## Crypto
```zig
// Random
std.crypto.random.bytes(&buf);
std.crypto.random.uintLessThan(u8, max); // bounded

// AES-256-GCM (key=32, nonce=12, tag=16)
const Aes = std.crypto.aead.aes_gcm.Aes256Gcm;
Aes.encrypt(&ct, &tag, pt, &.{}, nonce, key);
Aes.decrypt(&pt, &ct, tag, &.{}, nonce, key) catch return error.AuthenticationFailed;
// Nonce MUST be unique per encryption — use crypto.random.bytes

// Argon2id KDF (allocator is FIRST arg)
try std.crypto.pwhash.argon2.kdf(allocator, &dk, pw, &salt,
    .{ .t = 3, .m = 65536, .p = 1 }, .argon2id);

// SHA-1
var h = std.crypto.hash.Sha1.init(.{});
h.update(data);
const digest = h.finalResult(); // [20]u8

// HMAC-SHA-256
std.crypto.auth.hmac.sha2.HmacSha256.create(&mac, data, &key);
```

## C Interop
```zig
// @cImport (requires .link_libc = true in build module)
const c = @cImport({ @cInclude("string.h"); @cInclude("stdlib.h"); });
// GOTCHA: std.c does NOT expose strlen/memcpy/memset — must @cImport

// Sentinel strings
const c_str: [*:0]const u8 = "hello";
const zig_slice = std.mem.span(c_str); // → []const u8
const sentinel: [:0]const u8 = "hello"; // .ptr gives [*:0] for C functions

// allocSentinel for dynamic null-terminated buffers
const buf = try allocator.allocSentinel(u8, 5, 0);
@memcpy(buf[0..5], "Hello");

// extern struct = C layout; packed struct = bit-level layout
const CPoint = extern struct { x: c_int, y: c_int };

// Pointer casts (MUST @alignCast from *anyopaque)
const typed: *u32 = @ptrCast(@alignCast(anyopaque_ptr));

// C type mapping
// c_int=int, c_uint=unsigned, c_long=long, usize=size_t
// *anyopaque=void*, [*:0]u8=char*, [*c]T=T* (nullable C pointer)

// Build linking
mod.link_libc = true;
mod.linkSystemLibrary("z", .{}); // e.g., zlib
mod.addCSourceFile(.{ .file = b.path("helper.c"), .flags = &.{"-Wall"} });

// c_allocator wraps malloc/free
const buf2 = try std.heap.c_allocator.alloc(u8, 100);

// Platform detection
const builtin = @import("builtin"); // NOT std.builtin
builtin.os.tag == .macos
builtin.cpu.arch == .aarch64
builtin.cpu.arch.endian() // .little or .big

// zlib GOTCHA: std.compress.flate.Compress has @panic("TODO")
// Use C zlib: @cImport(@cInclude("zlib.h")) with link_libc + linkSystemLibrary("z")
```

## SIMD
```zig
const V4 = @Vector(4, f32);
const a: V4 = .{ 1.0, 2.0, 3.0, 4.0 };
const sum = a + b; // element-wise; also -, *, /, +%, +|, ~, - (negate)

// @splat: MUST have type context (bare @splat(42) = compile error)
const ones: V4 = @splat(1.0);            // annotation provides context
const scaled = a * @as(V4, @splat(2.0)); // @as provides context

// @reduce: vector → scalar
@reduce(.Add, v) // sum; also .Mul, .Min, .Max, .And, .Or, .Xor

// @shuffle: reorder/combine (0-N from a, ~idx from b)
const rev = @shuffle(i32, a, undefined, [4]i32{ 3, 2, 1, 0 });
const mix = @shuffle(i32, a, b, [4]i32{ 0, ~@as(i32, 0), 1, ~@as(i32, 1) });

// @select: per-element conditional (first param = ELEMENT type, not vector)
const result = @select(i32, bool_vec, a, b);

// Comparison returns @Vector(N, bool)
const gt: @Vector(4, bool) = a > b;
const count = std.simd.countTrues(gt);

// std.simd: iota, repeat, reverseOrder, shiftElementsLeft/Right, extract
// Array ↔ Vector: implicit coercion both directions
// @abs works on signed int/float vectors
```
