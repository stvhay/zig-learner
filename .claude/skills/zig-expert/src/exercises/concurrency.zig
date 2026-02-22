const std = @import("std");
const testing = std.testing;
const Thread = std.Thread;
const Mutex = Thread.Mutex;
const Condition = Thread.Condition;
const Atomic = std.atomic;

// Minimal concurrency validation exercises for the zig-expert skill.
// Copied from src/exercises/concurrency.zig — 10 core tests.

// ---------------------------------------------------------------------------
// 1. Thread spawn and join
// ---------------------------------------------------------------------------

fn simpleWorker(result: *i32) void {
    result.* = 42;
}

test "Thread.spawn and join" {
    var result: i32 = 0;
    const thread = try Thread.spawn(.{}, simpleWorker, .{&result});
    thread.join();
    try testing.expectEqual(@as(i32, 42), result);
}

// ---------------------------------------------------------------------------
// 2. Mutex lock/unlock
// ---------------------------------------------------------------------------

const SharedCounter = struct {
    mutex: Mutex = .{},
    count: i64 = 0,
    fn increment(self: *SharedCounter) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        self.count += 1;
    }
};

fn counterWorker(counter: *SharedCounter, iterations: u32) void {
    var i: u32 = 0;
    while (i < iterations) : (i += 1) {
        counter.increment();
    }
}

test "Mutex protecting shared state across threads" {
    var counter = SharedCounter{};
    const n_threads = 4;
    const iterations = 1000;
    var threads: [n_threads]Thread = undefined;
    for (&threads) |*t| {
        t.* = try Thread.spawn(.{}, counterWorker, .{ &counter, iterations });
    }
    for (threads) |t| t.join();
    try testing.expectEqual(@as(i64, n_threads * iterations), counter.count);
}

// ---------------------------------------------------------------------------
// 3. Condition variable with while loop (spurious wakeup pattern)
// ---------------------------------------------------------------------------

const BoundedQueue = struct {
    mutex: Mutex = .{},
    not_empty: Condition = .{},
    not_full: Condition = .{},
    buf: [8]i32 = undefined,
    head: usize = 0,
    tail: usize = 0,
    count: usize = 0,

    fn push(self: *BoundedQueue, val: i32) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        while (self.count == self.buf.len) self.not_full.wait(&self.mutex);
        self.buf[self.tail] = val;
        self.tail = (self.tail + 1) % self.buf.len;
        self.count += 1;
        self.not_empty.signal();
    }
    fn pop(self: *BoundedQueue) i32 {
        self.mutex.lock();
        defer self.mutex.unlock();
        while (self.count == 0) self.not_empty.wait(&self.mutex);
        const val = self.buf[self.head];
        self.head = (self.head + 1) % self.buf.len;
        self.count -= 1;
        self.not_full.signal();
        return val;
    }
};

fn producer(q: *BoundedQueue) void {
    for (0..20) |i| q.push(@intCast(i));
}
fn consumer(q: *BoundedQueue, results: *[20]i32) void {
    for (results) |*r| r.* = q.pop();
}

test "Condition variable: producer-consumer queue" {
    var q = BoundedQueue{};
    var results: [20]i32 = undefined;
    const prod = try Thread.spawn(.{}, producer, .{&q});
    const cons = try Thread.spawn(.{}, consumer, .{ &q, &results });
    prod.join();
    cons.join();
    for (results, 0..) |r, i| {
        try testing.expectEqual(@as(i32, @intCast(i)), r);
    }
}

// ---------------------------------------------------------------------------
// 4. Atomic operations (load, store, fetchAdd)
// ---------------------------------------------------------------------------

test "Atomic load, store, fetchAdd" {
    var counter = Atomic.Value(u32).init(0);
    counter.store(42, .seq_cst);
    try testing.expectEqual(@as(u32, 42), counter.load(.seq_cst));

    var c = Atomic.Value(i32).init(10);
    const old = c.fetchAdd(5, .seq_cst);
    try testing.expectEqual(@as(i32, 10), old);
    try testing.expectEqual(@as(i32, 15), c.load(.seq_cst));
}

// ---------------------------------------------------------------------------
// 5. ResetEvent signal/wait
// ---------------------------------------------------------------------------

fn resetEventWaiter(event: *Thread.ResetEvent, flag: *Atomic.Value(bool)) void {
    event.wait();
    flag.store(true, .release);
}

test "ResetEvent for signaling between threads" {
    var event: Thread.ResetEvent = .{};
    var flag = Atomic.Value(bool).init(false);
    const waiter = try Thread.spawn(.{}, resetEventWaiter, .{ &event, &flag });
    Thread.sleep(1_000_000); // 1ms
    try testing.expect(!flag.load(.acquire));
    event.set();
    waiter.join();
    try testing.expect(flag.load(.acquire));
}

// ---------------------------------------------------------------------------
// 6. Thread.Pool with spawnWg (pool auto-manages wg.start/finish)
// ---------------------------------------------------------------------------

// NOTE: Thread.Pool in 0.15.2 uses spawnWg, NOT spawn.
// spawnWg handles wg.start() and wg.finish() automatically.
// The worker should NOT call wg.finish() — pool does it.
fn poolTask(results: []Atomic.Value(u32), idx: usize) void {
    results[idx].store(@intCast(idx + 1), .release);
}

test "Thread.Pool with spawnWg" {
    const allocator = testing.allocator;
    var pool: Thread.Pool = undefined;
    try pool.init(.{ .allocator = allocator, .n_jobs = 2 });
    defer pool.deinit();

    const n = 8;
    var results: [n]Atomic.Value(u32) = undefined;
    for (&results) |*r| r.* = Atomic.Value(u32).init(0);

    var wg: Thread.WaitGroup = .{};
    for (0..n) |i| {
        // spawnWg calls wg.start() before dispatch and wg.finish() after fn returns
        pool.spawnWg(&wg, poolTask, .{ &results, i });
    }
    wg.wait();
    for (results, 0..) |r, i| {
        try testing.expectEqual(@as(u32, @intCast(i + 1)), r.load(.acquire));
    }
}

// ---------------------------------------------------------------------------
// 7. Lock-free stack with cmpxchgWeak
// ---------------------------------------------------------------------------

fn LockFreeStack(comptime T: type) type {
    return struct {
        const Self = @This();
        const Node = struct { value: T, next: ?*Node };

        head: Atomic.Value(?*Node),
        allocator: std.mem.Allocator,

        fn init(allocator: std.mem.Allocator) Self {
            return .{ .head = Atomic.Value(?*Node).init(null), .allocator = allocator };
        }
        fn push(self: *Self, value: T) !void {
            const node = try self.allocator.create(Node);
            node.value = value;
            var current_head = self.head.load(.monotonic);
            while (true) {
                node.next = current_head;
                const result = self.head.cmpxchgWeak(current_head, node, .release, .monotonic);
                if (result) |new_head| current_head = new_head else break;
            }
        }
        fn pop(self: *Self) ?T {
            var current_head = self.head.load(.acquire);
            while (current_head) |node| {
                const result = self.head.cmpxchgWeak(current_head, node.next, .acq_rel, .acquire);
                if (result) |new_head| {
                    current_head = new_head;
                } else {
                    const value = node.value;
                    self.allocator.destroy(node);
                    return value;
                }
            }
            return null;
        }
        fn deinit(self: *Self) void {
            while (self.pop()) |_| {}
        }
    };
}

test "lock-free stack: push/pop with CAS" {
    const allocator = testing.allocator;
    var stack = LockFreeStack(i32).init(allocator);
    defer stack.deinit();

    try stack.push(1);
    try stack.push(2);
    try stack.push(3);

    try testing.expectEqual(@as(?i32, 3), stack.pop()); // LIFO
    try testing.expectEqual(@as(?i32, 2), stack.pop());
    try testing.expectEqual(@as(?i32, 1), stack.pop());
    try testing.expectEqual(@as(?i32, null), stack.pop());
}

// ---------------------------------------------------------------------------
// 8. RwLock read vs write lock
// ---------------------------------------------------------------------------

const SharedData = struct {
    rwlock: Thread.RwLock = .{},
    value: i64 = 0,
    fn read(self: *SharedData) i64 {
        self.rwlock.lockShared();
        defer self.rwlock.unlockShared();
        return self.value;
    }
    fn write(self: *SharedData, val: i64) void {
        self.rwlock.lock();
        defer self.rwlock.unlock();
        self.value = val;
    }
};

fn writerWorker(data: *SharedData) void {
    var i: i64 = 1;
    while (i <= 100) : (i += 1) data.write(i);
}

test "RwLock: concurrent readers, exclusive writer" {
    var data = SharedData{};
    const writer = try Thread.spawn(.{}, writerWorker, .{&data});
    writer.join();
    try testing.expectEqual(@as(i64, 100), data.read());
}

// ---------------------------------------------------------------------------
// 9. spinLoopHint and cache_line
// ---------------------------------------------------------------------------

test "spinLoopHint and cache_line" {
    Atomic.spinLoopHint();
    try testing.expect(Atomic.cache_line >= 32);
    try testing.expect(Atomic.cache_line <= 256);
}

// ---------------------------------------------------------------------------
// 10. Compare-and-swap (cmpxchgStrong)
// ---------------------------------------------------------------------------

test "cmpxchgStrong: success and failure" {
    var val = Atomic.Value(u32).init(100);
    const success = val.cmpxchgStrong(100, 200, .seq_cst, .seq_cst);
    try testing.expectEqual(@as(?u32, null), success);
    try testing.expectEqual(@as(u32, 200), val.load(.seq_cst));

    const failed = val.cmpxchgStrong(100, 300, .seq_cst, .seq_cst);
    try testing.expectEqual(@as(?u32, 200), failed);
}
