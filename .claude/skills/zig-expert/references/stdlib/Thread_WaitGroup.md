// Zig 0.15.2 std.Thread.WaitGroup — API signatures + doc comments

pub fn start(self: *WaitGroup) void

pub fn startMany(self: *WaitGroup, n: usize) void

pub fn finish(self: *WaitGroup) void

pub fn wait(self: *WaitGroup) void

pub fn reset(self: *WaitGroup) void

pub fn isDone(wg: *WaitGroup) bool

pub fn spawnManager(
