// Zig 0.15.2 std.fs.File — API signatures + doc comments

pub const Kind = enum {

pub const OpenMode = enum {

pub const Lock = enum {

pub const OpenFlags = struct {

pub fn isRead(self: OpenFlags) bool

pub fn isWrite(self: OpenFlags) bool

pub const CreateFlags = struct {

pub fn stdout() File

pub fn stderr() File

pub fn stdin() File

/// Upon success, the stream is in an uninitialized state. To continue using it,
/// you must use the open() function.
pub fn close(self: File) void

/// Blocks until all pending file contents and metadata modifications
/// for the file have been synchronized with the underlying filesystem.
///
/// Note that this does not ensure that metadata for the
/// directory containing the file has also reached disk.
pub fn sync(self: File) SyncError!void

/// Test whether the file refers to a terminal.
/// See also `getOrEnableAnsiEscapeSupport` and `supportsAnsiEscapeCodes`.
pub fn isTty(self: File) bool

pub fn isCygwinPty(file: File) bool

/// Returns whether or not ANSI escape codes will be treated as such,
/// and attempts to enable support for ANSI escape codes if necessary
/// (on Windows).
///
/// Returns `true` if ANSI escape codes are supported or support was
/// successfully enabled. Returns false if ANSI escape codes are not
/// supported or support was unable to be enabled.
///
/// See also `supportsAnsiEscapeCodes`.
pub fn getOrEnableAnsiEscapeSupport(self: File) bool

/// Test whether ANSI escape codes will be treated as such without
/// attempting to enable support for ANSI escape codes.
///
/// See also `getOrEnableAnsiEscapeSupport`.
pub fn supportsAnsiEscapeCodes(self: File) bool

/// Shrinks or expands the file.
/// The file offset after this call is left unchanged.
pub fn setEndPos(self: File, length: u64) SetEndPosError!void

/// Repositions read/write file offset relative to the current offset.
/// TODO: integrate with async I/O
pub fn seekBy(self: File, offset: i64) SeekError!void

/// Repositions read/write file offset relative to the end.
/// TODO: integrate with async I/O
pub fn seekFromEnd(self: File, offset: i64) SeekError!void

/// Repositions read/write file offset relative to the beginning.
/// TODO: integrate with async I/O
pub fn seekTo(self: File, offset: u64) SeekError!void

/// TODO: integrate with async I/O
pub fn getPos(self: File) GetSeekPosError!u64

/// TODO: integrate with async I/O
pub fn getEndPos(self: File) GetEndPosError!u64

/// TODO: integrate with async I/O
pub fn mode(self: File) ModeError!Mode

pub const Stat = struct {

pub fn fromPosix(st: posix.Stat) Stat

pub fn fromLinux(stx: linux.Statx) Stat

pub fn fromWasi(st: std.os.wasi.filestat_t) Stat

/// Returns `Stat` containing basic information about the `File`.
/// TODO: integrate with async I/O
pub fn stat(self: File) StatError!Stat

/// Changes the mode of the file.
/// The process must have the correct privileges in order to do this
/// successfully, or must have the effective user ID matching the owner
/// of the file.
pub fn chmod(self: File, new_mode: Mode) ChmodError!void

/// Changes the owner and group of the file.
/// The process must have the correct privileges in order to do this
/// successfully. The group may be changed by the owner of the file to
/// any group of which the owner is a member. If the owner or group is
/// specified as `null`, the ID is not changed.
pub fn chown(self: File, owner: ?Uid, group: ?Gid) ChownError!void

/// Cross-platform representation of permissions on a file.
/// The `readonly` and `setReadonly` are the only methods available across all platforms.
/// Platform-specific functionality is available through the `inner` field.
pub const Permissions = struct {

    /// Returns `true` if permissions represent an unwritable file.
    /// On Unix, `true` is returned only if no class has write permissions.
pub fn readOnly(self: Self) bool

    /// Sets whether write permissions are provided.
    /// On Unix, this affects *all* classes. If this is undesired, use `unixSet`.
    /// This method *DOES NOT* set permissions on the filesystem: use `File.setPermissions(permissions)`
pub fn setReadOnly(self: *Self, read_only: bool) void

pub const PermissionsWindows = struct {

    /// Returns `true` if permissions represent an unwritable file.
pub fn readOnly(self: Self) bool

    /// Sets whether write permissions are provided.
    /// This method *DOES NOT* set permissions on the filesystem: use `File.setPermissions(permissions)`
pub fn setReadOnly(self: *Self, read_only: bool) void

pub const PermissionsUnix = struct {

    /// Returns `true` if permissions represent an unwritable file.
    /// `true` is returned only if no class has write permissions.
pub fn readOnly(self: Self) bool

    /// Sets whether write permissions are provided.
    /// This affects *all* classes. If this is undesired, use `unixSet`.
    /// This method *DOES NOT* set permissions on the filesystem: use `File.setPermissions(permissions)`
pub fn setReadOnly(self: *Self, read_only: bool) void

pub const Class = enum(u2) {

pub const Permission = enum(u3) {

    /// Returns `true` if the chosen class has the selected permission.
    /// This method is only available on Unix platforms.
pub fn unixHas(self: Self, class: Class, permission: Permission) bool

    /// Sets the permissions for the chosen class. Any permissions set to `null` are left unchanged.
    /// This method *DOES NOT* set permissions on the filesystem: use `File.setPermissions(permissions)`
pub fn unixSet(self: *Self, class: Class, permissions: struct

    /// Returns a `Permissions` struct representing the permissions from the passed mode.
pub fn unixNew(new_mode: Mode) Self

/// Sets permissions according to the provided `Permissions` struct.
/// This method is *NOT* available on WASI
pub fn setPermissions(self: File, permissions: Permissions) SetPermissionsError!void

/// The underlying file system may have a different granularity than nanoseconds,
/// and therefore this function cannot guarantee any precision will be stored.
/// Further, the maximum value is limited by the system ABI. When a value is provided
/// that exceeds this range, the value is clamped to the maximum.
/// TODO: integrate with async I/O
pub fn updateTimes(

/// Deprecated in favor of `Reader`.
pub fn readToEndAlloc(self: File, allocator: Allocator, max_bytes: usize) ![]u8

/// Deprecated in favor of `Reader`.
pub fn readToEndAllocOptions(

pub fn read(self: File, buffer: []u8) ReadError!usize

/// Deprecated in favor of `Reader`.
pub fn readAll(self: File, buffer: []u8) ReadError!usize

/// On Windows, this function currently does alter the file pointer.
/// https://github.com/ziglang/zig/issues/12783
pub fn pread(self: File, buffer: []u8, offset: u64) PReadError!usize

/// Deprecated in favor of `Reader`.
pub fn preadAll(self: File, buffer: []u8, offset: u64) PReadError!usize

/// See https://github.com/ziglang/zig/issues/7699
pub fn readv(self: File, iovecs: []const posix.iovec) ReadError!usize

/// Deprecated in favor of `Reader`.
pub fn readvAll(self: File, iovecs: []posix.iovec) ReadError!usize

/// See https://github.com/ziglang/zig/issues/7699
/// On Windows, this function currently does alter the file pointer.
/// https://github.com/ziglang/zig/issues/12783
pub fn preadv(self: File, iovecs: []const posix.iovec, offset: u64) PReadError!usize

/// Deprecated in favor of `Reader`.
pub fn preadvAll(self: File, iovecs: []posix.iovec, offset: u64) PReadError!usize

pub fn write(self: File, bytes: []const u8) WriteError!usize

/// Deprecated in favor of `Writer`.
pub fn writeAll(self: File, bytes: []const u8) WriteError!void

/// On Windows, this function currently does alter the file pointer.
/// https://github.com/ziglang/zig/issues/12783
pub fn pwrite(self: File, bytes: []const u8, offset: u64) PWriteError!usize

/// Deprecated in favor of `Writer`.
pub fn pwriteAll(self: File, bytes: []const u8, offset: u64) PWriteError!void

/// See https://github.com/ziglang/zig/issues/7699
pub fn writev(self: File, iovecs: []const posix.iovec_const) WriteError!usize

/// Deprecated in favor of `Writer`.
pub fn writevAll(self: File, iovecs: []posix.iovec_const) WriteError!void

/// See https://github.com/ziglang/zig/issues/7699
/// On Windows, this function currently does alter the file pointer.
/// https://github.com/ziglang/zig/issues/12783
pub fn pwritev(self: File, iovecs: []posix.iovec_const, offset: u64) PWriteError!usize

/// Deprecated in favor of `Writer`.
pub fn pwritevAll(self: File, iovecs: []posix.iovec_const, offset: u64) PWriteError!void

/// Deprecated in favor of `Writer`.
pub fn copyRange(in: File, in_offset: u64, out: File, out_offset: u64, len: u64) CopyRangeError!u64

/// Deprecated in favor of `Writer`.
pub fn copyRangeAll(in: File, in_offset: u64, out: File, out_offset: u64, len: u64) CopyRangeError!u64

/// Deprecated in favor of `Reader`.
pub fn deprecatedReader(file: File) DeprecatedReader

/// Deprecated in favor of `Writer`.
pub fn deprecatedWriter(file: File) DeprecatedWriter

/// Memoizes key information about a file handle such as:
/// * The size from calling stat, or the error that occurred therein.
/// * The current seek position.
/// * The error that occurred when trying to seek.
/// * Whether reading should be done positionally or streaming.
/// * Whether reading should be done via fd-to-fd syscalls (e.g. `sendfile`)
///   versus plain variants (e.g. `read`).
///
/// Fulfills the `std.Io.Reader` interface.
pub const Reader = struct {

pub const Mode = enum {

pub fn toStreaming(m: @This()) @This()

pub fn toReading(m: @This()) @This()

pub fn initInterface(buffer: []u8) std.Io.Reader

pub fn init(file: File, buffer: []u8) Reader

pub fn initSize(file: File, buffer: []u8, size: ?u64) Reader

    /// Positional is more threadsafe, since the global seek position is not
    /// affected, but when such syscalls are not available, preemptively
    /// initializing in streaming mode skips a failed syscall.
pub fn initStreaming(file: File, buffer: []u8) Reader

pub fn getSize(r: *Reader) SizeError!u64

pub fn seekBy(r: *Reader, offset: i64) Reader.SeekError!void

pub fn seekTo(r: *Reader, offset: u64) Reader.SeekError!void

pub fn logicalPos(r: *const Reader) u64

pub fn atEnd(r: *Reader) bool

pub const Writer = struct {

pub fn init(file: File, buffer: []u8) Writer

    /// Positional is more threadsafe, since the global seek position is not
    /// affected, but when such syscalls are not available, preemptively
    /// initializing in streaming mode will skip a failed syscall.
pub fn initStreaming(file: File, buffer: []u8) Writer

pub fn initInterface(buffer: []u8) std.Io.Writer

pub fn moveToReader(w: *Writer) Reader

pub fn drain(io_w: *std.Io.Writer, data: []const []const u8, splat: usize) std.Io.Writer.Error!usize

pub fn sendFile(

pub fn seekTo(w: *Writer, offset: u64) SeekError!void

    /// Flushes any buffered data and sets the end position of the file.
    ///
    /// If not overwriting existing contents, then calling `interface.flush`
    /// directly is sufficient.
    ///
    /// Flush failure is handled by setting `err` so that it can be handled
    /// along with other write failures.
pub fn end(w: *Writer) EndError!void

/// Defaults to positional reading; falls back to streaming.
///
/// Positional is more threadsafe, since the global seek position is not
/// affected.
pub fn reader(file: File, buffer: []u8) Reader

/// Positional is more threadsafe, since the global seek position is not
/// affected, but when such syscalls are not available, preemptively
/// initializing in streaming mode skips a failed syscall.
pub fn readerStreaming(file: File, buffer: []u8) Reader

/// Defaults to positional reading; falls back to streaming.
///
/// Positional is more threadsafe, since the global seek position is not
/// affected.
pub fn writer(file: File, buffer: []u8) Writer

/// Positional is more threadsafe, since the global seek position is not
/// affected, but when such syscalls are not available, preemptively
/// initializing in streaming mode will skip a failed syscall.
pub fn writerStreaming(file: File, buffer: []u8) Writer

/// Blocks when an incompatible lock is held by another process.
/// A process may hold only one type of lock (shared or exclusive) on
/// a file. When a process terminates in any way, the lock is released.
///
/// Assumes the file is unlocked.
///
/// TODO: integrate with async I/O
pub fn lock(file: File, l: Lock) LockError!void

/// Assumes the file is locked.
pub fn unlock(file: File) void

/// Attempts to obtain a lock, returning `true` if the lock is
/// obtained, and `false` if there was an existing incompatible lock held.
/// A process may hold only one type of lock (shared or exclusive) on
/// a file. When a process terminates in any way, the lock is released.
///
/// Assumes the file is unlocked.
///
/// TODO: integrate with async I/O
pub fn tryLock(file: File, l: Lock) LockError!bool

/// Assumes the file is already locked in exclusive mode.
/// Atomically modifies the lock to be in shared mode, without releasing it.
///
/// TODO: integrate with async I/O
pub fn downgradeLock(file: File) LockError!void
