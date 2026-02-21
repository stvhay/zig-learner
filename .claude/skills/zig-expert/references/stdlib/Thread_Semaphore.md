// Zig 0.15.2 std.Thread.Semaphore — API signatures + doc comments

pub fn wait(sem: *Semaphore) void

pub fn timedWait(sem: *Semaphore, timeout_ns: u64) error

pub fn post(sem: *Semaphore) void
