// Zig 0.15.2 std.Thread.RwLock — API signatures + doc comments

/// Attempts to obtain exclusive lock ownership.
/// Returns `true` if the lock is obtained, `false` otherwise.
pub fn tryLock(rwl: *RwLock) bool

/// Blocks until exclusive lock ownership is acquired.
pub fn lock(rwl: *RwLock) void

/// Releases a held exclusive lock.
/// Asserts the lock is held exclusively.
pub fn unlock(rwl: *RwLock) void

/// Attempts to obtain shared lock ownership.
/// Returns `true` if the lock is obtained, `false` otherwise.
pub fn tryLockShared(rwl: *RwLock) bool

/// Obtains shared lock ownership.
/// Blocks if another thread has exclusive ownership.
/// May block if another thread is attempting to get exclusive ownership.
pub fn lockShared(rwl: *RwLock) void

/// Releases a held shared lock.
pub fn unlockShared(rwl: *RwLock) void

/// Single-threaded applications use this for deadlock checks in
/// debug mode, and no-ops in release modes.
pub const SingleThreadedRwLock = struct {

    /// Attempts to obtain exclusive lock ownership.
    /// Returns `true` if the lock is obtained, `false` otherwise.
pub fn tryLock(rwl: *SingleThreadedRwLock) bool

    /// Blocks until exclusive lock ownership is acquired.
pub fn lock(rwl: *SingleThreadedRwLock) void

    /// Releases a held exclusive lock.
    /// Asserts the lock is held exclusively.
pub fn unlock(rwl: *SingleThreadedRwLock) void

    /// Attempts to obtain shared lock ownership.
    /// Returns `true` if the lock is obtained, `false` otherwise.
pub fn tryLockShared(rwl: *SingleThreadedRwLock) bool

    /// Blocks until shared lock ownership is acquired.
pub fn lockShared(rwl: *SingleThreadedRwLock) void

    /// Releases a held shared lock.
pub fn unlockShared(rwl: *SingleThreadedRwLock) void

pub const PthreadRwLock = struct {

pub fn tryLock(rwl: *PthreadRwLock) bool

pub fn lock(rwl: *PthreadRwLock) void

pub fn unlock(rwl: *PthreadRwLock) void

pub fn tryLockShared(rwl: *PthreadRwLock) bool

pub fn lockShared(rwl: *PthreadRwLock) void

pub fn unlockShared(rwl: *PthreadRwLock) void

pub const DefaultRwLock = struct {

pub fn tryLock(rwl: *DefaultRwLock) bool

pub fn lock(rwl: *DefaultRwLock) void

pub fn unlock(rwl: *DefaultRwLock) void

pub fn tryLockShared(rwl: *DefaultRwLock) bool

pub fn lockShared(rwl: *DefaultRwLock) void

pub fn unlockShared(rwl: *DefaultRwLock) void
