// Zig 0.15.2 std.fs.path — API signatures + doc comments

/// Returns if the given byte is a valid path separator
pub fn isSep(byte: u8) bool

pub const PathType = enum {

    /// Returns true if `c` is a valid path separator for the `path_type`.
pub inline fn isSep(comptime path_type: PathType, comptime T: type, c: T) bool

/// Naively combines a series of paths with the native path separator.
/// Allocates memory for the result, which must be freed by the caller.
pub fn join(allocator: Allocator, paths: []const []const u8) ![]u8

/// Naively combines a series of paths with the native path separator and null terminator.
/// Allocates memory for the result, which must be freed by the caller.
pub fn joinZ(allocator: Allocator, paths: []const []const u8) ![:0]u8

pub fn fmtJoin(paths: []const []const u8) std.fmt.Formatter([]const []const u8, formatJoin)

pub fn isAbsoluteZ(path_c: [*:0]const u8) bool

pub fn isAbsolute(path: []const u8) bool

pub fn isAbsoluteWindows(path: []const u8) bool

pub fn isAbsoluteWindowsW(path_w: [*:0]const u16) bool

pub fn isAbsoluteWindowsWTF16(path: []const u16) bool

pub fn isAbsoluteWindowsZ(path_c: [*:0]const u8) bool

pub fn isAbsolutePosix(path: []const u8) bool

pub fn isAbsolutePosixZ(path_c: [*:0]const u8) bool

pub const WindowsPath = struct {

pub const Kind = enum {

pub fn windowsParsePath(path: []const u8) WindowsPath

pub fn diskDesignator(path: []const u8) []const u8

pub fn diskDesignatorWindows(path: []const u8) []const u8

/// On Windows, this calls `resolveWindows` and on POSIX it calls `resolvePosix`.
pub fn resolve(allocator: Allocator, paths: []const []const u8) ![]u8

/// This function is like a series of `cd` statements executed one after another.
/// It resolves "." and "..", but will not convert relative path to absolute path, use std.fs.Dir.realpath instead.
/// The result does not have a trailing path separator.
/// Each drive has its own current working directory.
/// Path separators are canonicalized to '\\' and drives are canonicalized to capital letters.
/// Note: all usage of this function should be audited due to the existence of symlinks.
/// Without performing actual syscalls, resolving `..` could be incorrect.
/// This API may break in the future: https://github.com/ziglang/zig/issues/13613
pub fn resolveWindows(allocator: Allocator, paths: []const []const u8) ![]u8

/// This function is like a series of `cd` statements executed one after another.
/// It resolves "." and "..", but will not convert relative path to absolute path, use std.fs.Dir.realpath instead.
/// The result does not have a trailing path separator.
/// This function does not perform any syscalls. Executing this series of path
/// lookups on the actual filesystem may produce different results due to
/// symlinks.
pub fn resolvePosix(allocator: Allocator, paths: []const []const u8) Allocator.Error![]u8

/// Strip the last component from a file path.
///
/// If the path is a file in the current directory (no directory component)
/// then returns null.
///
/// If the path is the root directory, returns null.
pub fn dirname(path: []const u8) ?[]const u8

pub fn dirnameWindows(path: []const u8) ?[]const u8

pub fn dirnamePosix(path: []const u8) ?[]const u8

pub fn basename(path: []const u8) []const u8

pub fn basenamePosix(path: []const u8) []const u8

pub fn basenameWindows(path: []const u8) []const u8

/// Returns the relative path from `from` to `to`. If `from` and `to` each
/// resolve to the same path (after calling `resolve` on each), a zero-length
/// string is returned.
/// On Windows this canonicalizes the drive to a capital letter and paths to `\\`.
pub fn relative(allocator: Allocator, from: []const u8, to: []const u8) ![]u8

pub fn relativeWindows(allocator: Allocator, from: []const u8, to: []const u8) ![]u8

pub fn relativePosix(allocator: Allocator, from: []const u8, to: []const u8) ![]u8

/// Searches for a file extension separated by a `.` and returns the string after that `.`.
/// Files that end or start with `.` and have no other `.` in their name
/// are considered to have no extension, in which case this returns "".
/// Examples:
/// - `"main.zig"`      ⇒ `".zig"`
/// - `"src/main.zig"`  ⇒ `".zig"`
/// - `".gitignore"`    ⇒ `""`
/// - `".image.png"`    ⇒ `".png"`
/// - `"keep."`         ⇒ `"."`
/// - `"src.keep.me"`   ⇒ `".me"`
/// - `"/src/keep.me"`  ⇒ `".me"`
/// - `"/src/keep.me/"` ⇒ `".me"`
/// The returned slice is guaranteed to have its pointer within the start and end
/// pointer address range of `path`, even if it is length zero.
pub fn extension(path: []const u8) []const u8

/// Returns the last component of this path without its extension (if any):
/// - "hello/world/lib.tar.gz" ⇒ "lib.tar"
/// - "hello/world/lib.tar"    ⇒ "lib"
/// - "hello/world/lib"        ⇒ "lib"
pub fn stem(path: []const u8) []const u8

/// A path component iterator that can move forwards and backwards.
/// The 'root' of the path (`/` for POSIX, things like `C:\`, `\\server\share\`, etc
/// for Windows) is treated specially and will never be returned by any of the
/// `first`, `last`, `next`, or `previous` functions.
/// Multiple consecutive path separators are skipped (treated as a single separator)
/// when iterating.
/// All returned component names/paths are slices of the original path.
/// There is no normalization of paths performed while iterating.
pub fn ComponentIterator(comptime path_type: PathType, comptime T: type) type

pub const Component = struct {

        /// After `init`, `next` will return the first component after the root
        /// (there is no need to call `first` after `init`).
        /// To iterate backwards (from the end of the path to the beginning), call `last`
        /// after `init` and then iterate via `previous` calls.
        /// For Windows paths, `error.BadPathName` is returned if the `path` has an explicit
        /// namespace prefix (`\\.\`, `\\?\`, or `\??\`) or if it is a UNC path with more
        /// than two path separators at the beginning.
pub fn init(path: []const T) InitError!Self

        /// Returns the root of the path if it is an absolute path, or null otherwise.
        /// For POSIX paths, this will be `/`.
        /// For Windows paths, this will be something like `C:\`, `\\server\share\`, etc.
        /// For UEFI paths, this will be `\`.
pub fn root(self: Self) ?[]const T

        /// Returns the first component (from the beginning of the path).
        /// For example, if the path is `/a/b/c` then this will return the `a` component.
        /// After calling `first`, `previous` will always return `null`, and `next` will return
        /// the component to the right of the one returned by `first`, if any exist.
pub fn first(self: *Self) ?Component

        /// Returns the last component (from the end of the path).
        /// For example, if the path is `/a/b/c` then this will return the `c` component.
        /// After calling `last`, `next` will always return `null`, and `previous` will return
        /// the component to the left of the one returned by `last`, if any exist.
pub fn last(self: *Self) ?Component

        /// Returns the next component (the component to the right of the most recently
        /// returned component), or null if no such component exists.
        /// For example, if the path is `/a/b/c` and the most recently returned component
        /// is `b`, then this will return the `c` component.
pub fn next(self: *Self) ?Component

        /// Like `next`, but does not modify the iterator state.
pub fn peekNext(self: Self) ?Component

        /// Returns the previous component (the component to the left of the most recently
        /// returned component), or null if no such component exists.
        /// For example, if the path is `/a/b/c` and the most recently returned component
        /// is `b`, then this will return the `a` component.
pub fn previous(self: *Self) ?Component

        /// Like `previous`, but does not modify the iterator state.
pub fn peekPrevious(self: Self) ?Component

pub fn componentIterator(path: []const u8) !NativeComponentIterator
