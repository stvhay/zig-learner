// Zig 0.15.2 std.Thread.Pool — API signatures + doc comments

pub const Options = struct {

pub fn init(pool: *Pool, options: Options) !void

pub fn deinit(pool: *Pool) void

/// Runs `func` in the thread pool, calling `WaitGroup.start` beforehand, and
/// `WaitGroup.finish` after it returns.
///
/// In the case that queuing the function call fails to allocate memory, or the
/// target is single-threaded, the function is called directly.
pub fn spawnWg(pool: *Pool, wait_group: *WaitGroup, comptime func: anytype, args: anytype) void

/// Runs `func` in the thread pool, calling `WaitGroup.start` beforehand, and
/// `WaitGroup.finish` after it returns.
///
/// The first argument passed to `func` is a dense `usize` thread id, the rest
/// of the arguments are passed from `args`. Requires the pool to have been
/// initialized with `.track_ids = true`.
///
/// In the case that queuing the function call fails to allocate memory, or the
/// target is single-threaded, the function is called directly.
pub fn spawnWgId(pool: *Pool, wait_group: *WaitGroup, comptime func: anytype, args: anytype) void

pub fn spawn(pool: *Pool, comptime func: anytype, args: anytype) !void

pub fn waitAndWork(pool: *Pool, wait_group: *WaitGroup) void

pub fn getIdCount(pool: *Pool) usize
