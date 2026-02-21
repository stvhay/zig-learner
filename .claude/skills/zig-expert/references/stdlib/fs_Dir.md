// Zig 0.15.2 std.fs.Dir — API signatures + doc comments

pub const Entry = struct {

        /// Memory such as file names referenced in this returned entry becomes invalid
        /// with subsequent calls to `next`, as well as when this `Dir` is deinitialized.
pub fn next(self: *Self) Error!?Entry

pub fn reset(self: *Self) void

        /// Memory such as file names referenced in this returned entry becomes invalid
        /// with subsequent calls to `next`, as well as when this `Dir` is deinitialized.
pub fn next(self: *Self) Error!?Entry

pub fn reset(self: *Self) void

        /// Memory such as file names referenced in this returned entry becomes invalid
        /// with subsequent calls to `next`, as well as when this `Dir` is deinitialized.
pub fn next(self: *Self) Error!?Entry

        /// Implementation of `next` that can return `error.DirNotFound` if the directory being
        /// iterated was deleted during iteration (this error is Linux specific).
pub fn nextLinux(self: *Self) ErrorLinux!?Entry

pub fn reset(self: *Self) void

        /// Memory such as file names referenced in this returned entry becomes invalid
        /// with subsequent calls to `next`, as well as when this `Dir` is deinitialized.
pub fn next(self: *Self) Error!?Entry

pub fn reset(self: *Self) void

        /// Memory such as file names referenced in this returned entry becomes invalid
        /// with subsequent calls to `next`, as well as when this `Dir` is deinitialized.
pub fn next(self: *Self) Error!?Entry

        /// Implementation of `next` that can return platform-dependent errors depending on the host platform.
        /// When the host platform is Linux, `error.DirNotFound` can be returned if the directory being
        /// iterated was deleted during iteration.
pub fn nextWasi(self: *Self) ErrorWasi!?Entry

pub fn reset(self: *Self) void

pub fn iterate(self: Dir) Iterator

/// Like `iterate`, but will not reset the directory cursor before the first
/// iteration. This should only be used in cases where it is known that the
/// `Dir` has not had its cursor modified yet (e.g. it was just opened).
pub fn iterateAssumeFirstIteration(self: Dir) Iterator

pub const Walker = struct {

pub const Entry = struct {

    /// After each call to this function, and on deinit(), the memory returned
    /// from this function becomes invalid. A copy must be made in order to keep
    /// a reference to the path.
pub fn next(self: *Walker) !?Walker.Entry

pub fn deinit(self: *Walker) void

/// Recursively iterates over a directory.
///
/// `self` must have been opened with `OpenOptions{.iterate = true}`.
///
/// `Walker.deinit` releases allocated memory and directory handles.
///
/// The order of returned file system entries is undefined.
///
/// `self` will not be closed after walking it.
pub fn walk(self: Dir, allocator: Allocator) Allocator.Error!Walker

pub fn close(self: *Dir) void

/// Opens a file for reading or writing, without attempting to create a new file.
/// To create a new file, see `createFile`.
/// Call `File.close` to release the resource.
/// Asserts that the path parameter has no null bytes.
/// On Windows, `sub_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `sub_path` should be encoded as valid UTF-8.
/// On other platforms, `sub_path` is an opaque sequence of bytes with no particular encoding.
pub fn openFile(self: Dir, sub_path: []const u8, flags: File.OpenFlags) File.OpenError!File

/// Same as `openFile` but the path parameter is null-terminated.
pub fn openFileZ(self: Dir, sub_path: [*:0]const u8, flags: File.OpenFlags) File.OpenError!File

/// Same as `openFile` but Windows-only and the path parameter is
/// [WTF-16](https://simonsapin.github.io/wtf-8/#potentially-ill-formed-utf-16) encoded.
pub fn openFileW(self: Dir, sub_path_w: []const u16, flags: File.OpenFlags) File.OpenError!File

/// Creates, opens, or overwrites a file with write access.
/// Call `File.close` on the result when done.
/// Asserts that the path parameter has no null bytes.
/// On Windows, `sub_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `sub_path` should be encoded as valid UTF-8.
/// On other platforms, `sub_path` is an opaque sequence of bytes with no particular encoding.
pub fn createFile(self: Dir, sub_path: []const u8, flags: File.CreateFlags) File.OpenError!File

/// Same as `createFile` but the path parameter is null-terminated.
pub fn createFileZ(self: Dir, sub_path_c: [*:0]const u8, flags: File.CreateFlags) File.OpenError!File

/// Same as `createFile` but Windows-only and the path parameter is
/// [WTF-16](https://simonsapin.github.io/wtf-8/#potentially-ill-formed-utf-16) encoded.
pub fn createFileW(self: Dir, sub_path_w: []const u16, flags: File.CreateFlags) File.OpenError!File

/// Creates a single directory with a relative or absolute path.
/// To create multiple directories to make an entire path, see `makePath`.
/// To operate on only absolute paths, see `makeDirAbsolute`.
/// On Windows, `sub_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `sub_path` should be encoded as valid UTF-8.
/// On other platforms, `sub_path` is an opaque sequence of bytes with no particular encoding.
pub fn makeDir(self: Dir, sub_path: []const u8) MakeError!void

/// Same as `makeDir`, but `sub_path` is null-terminated.
/// To create multiple directories to make an entire path, see `makePath`.
/// To operate on only absolute paths, see `makeDirAbsoluteZ`.
pub fn makeDirZ(self: Dir, sub_path: [*:0]const u8) MakeError!void

/// Creates a single directory with a relative or absolute null-terminated WTF-16 LE-encoded path.
/// To create multiple directories to make an entire path, see `makePath`.
/// To operate on only absolute paths, see `makeDirAbsoluteW`.
pub fn makeDirW(self: Dir, sub_path: [*:0]const u16) MakeError!void

/// Calls makeDir iteratively to make an entire path
/// (i.e. creating any parent directories that do not exist).
/// Returns success if the path already exists and is a directory.
/// This function is not atomic, and if it returns an error, the file system may
/// have been modified regardless.
/// On Windows, `sub_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `sub_path` should be encoded as valid UTF-8.
/// On other platforms, `sub_path` is an opaque sequence of bytes with no particular encoding.
/// Fails on an empty path with `error.BadPathName` as that is not a path that can be created.
///
/// Paths containing `..` components are handled differently depending on the platform:
/// - On Windows, `..` are resolved before the path is passed to NtCreateFile, meaning
///   a `sub_path` like "first/../second" will resolve to "second" and only a
///   `./second` directory will be created.
/// - On other platforms, `..` are not resolved before the path is passed to `mkdirat`,
///   meaning a `sub_path` like "first/../second" will create both a `./first`
///   and a `./second` directory.
pub fn makePath(self: Dir, sub_path: []const u8) (MakeError || StatFileError)!void

pub const MakePathStatus = enum { existed, created };

/// Same as `makePath` except returns whether the path already existed or was successfully created.
pub fn makePathStatus(self: Dir, sub_path: []const u8) (MakeError || StatFileError)!MakePathStatus

/// This function performs `makePath`, followed by `openDir`.
/// If supported by the OS, this operation is atomic. It is not atomic on
/// all operating systems.
/// On Windows, `sub_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `sub_path` should be encoded as valid UTF-8.
/// On other platforms, `sub_path` is an opaque sequence of bytes with no particular encoding.
pub fn makeOpenPath(self: Dir, sub_path: []const u8, open_dir_options: OpenOptions) (MakeError || OpenError || StatFileError)!Dir

///  This function returns the canonicalized absolute pathname of
/// `pathname` relative to this `Dir`. If `pathname` is absolute, ignores this
/// `Dir` handle and returns the canonicalized absolute pathname of `pathname`
/// argument.
/// On Windows, `sub_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On other platforms, `sub_path` is an opaque sequence of bytes with no particular encoding.
/// On Windows, the result is encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On other platforms, the result is an opaque sequence of bytes with no particular encoding.
/// This function is not universally supported by all platforms.
/// Currently supported hosts are: Linux, macOS, and Windows.
/// See also `Dir.realpathZ`, `Dir.realpathW`, and `Dir.realpathAlloc`.
pub fn realpath(self: Dir, pathname: []const u8, out_buffer: []u8) RealPathError![]u8

/// Same as `Dir.realpath` except `pathname` is null-terminated.
/// See also `Dir.realpath`, `realpathZ`.
pub fn realpathZ(self: Dir, pathname: [*:0]const u8, out_buffer: []u8) RealPathError![]u8

/// Windows-only. Same as `Dir.realpath` except `pathname` is WTF16 LE encoded.
/// The result is encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// See also `Dir.realpath`, `realpathW`.
pub fn realpathW(self: Dir, pathname: []const u16, out_buffer: []u8) RealPathError![]u8

/// Same as `Dir.realpath` except caller must free the returned memory.
/// See also `Dir.realpath`.
pub fn realpathAlloc(self: Dir, allocator: Allocator, pathname: []const u8) RealPathAllocError![]u8

/// Changes the current working directory to the open directory handle.
/// This modifies global state and can have surprising effects in multi-
/// threaded applications. Most applications and especially libraries should
/// not call this function as a general rule, however it can have use cases
/// in, for example, implementing a shell, or child process execution.
/// Not all targets support this. For example, WASI does not have the concept
/// of a current working directory.
pub fn setAsCwd(self: Dir) !void

pub const OpenOptions = struct {

/// Opens a directory at the given path. The directory is a system resource that remains
/// open until `close` is called on the result.
/// The directory cannot be iterated unless the `iterate` option is set to `true`.
///
/// On Windows, `sub_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `sub_path` should be encoded as valid UTF-8.
/// On other platforms, `sub_path` is an opaque sequence of bytes with no particular encoding.
/// Asserts that the path parameter has no null bytes.
pub fn openDir(self: Dir, sub_path: []const u8, args: OpenOptions) OpenError!Dir

/// Same as `openDir` except the parameter is null-terminated.
pub fn openDirZ(self: Dir, sub_path_c: [*:0]const u8, args: OpenOptions) OpenError!Dir

/// Same as `openDir` except the path parameter is WTF-16 LE encoded, NT-prefixed.
/// This function asserts the target OS is Windows.
pub fn openDirW(self: Dir, sub_path_w: [*:0]const u16, args: OpenOptions) OpenError!Dir

/// Delete a file name and possibly the file it refers to, based on an open directory handle.
/// On Windows, `sub_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `sub_path` should be encoded as valid UTF-8.
/// On other platforms, `sub_path` is an opaque sequence of bytes with no particular encoding.
/// Asserts that the path parameter has no null bytes.
pub fn deleteFile(self: Dir, sub_path: []const u8) DeleteFileError!void

/// Same as `deleteFile` except the parameter is null-terminated.
pub fn deleteFileZ(self: Dir, sub_path_c: [*:0]const u8) DeleteFileError!void

/// Same as `deleteFile` except the parameter is WTF-16 LE encoded.
pub fn deleteFileW(self: Dir, sub_path_w: []const u16) DeleteFileError!void

/// Returns `error.DirNotEmpty` if the directory is not empty.
/// To delete a directory recursively, see `deleteTree`.
/// On Windows, `sub_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `sub_path` should be encoded as valid UTF-8.
/// On other platforms, `sub_path` is an opaque sequence of bytes with no particular encoding.
/// Asserts that the path parameter has no null bytes.
pub fn deleteDir(self: Dir, sub_path: []const u8) DeleteDirError!void

/// Same as `deleteDir` except the parameter is null-terminated.
pub fn deleteDirZ(self: Dir, sub_path_c: [*:0]const u8) DeleteDirError!void

/// Same as `deleteDir` except the parameter is WTF16LE, NT prefixed.
/// This function is Windows-only.
pub fn deleteDirW(self: Dir, sub_path_w: []const u16) DeleteDirError!void

/// Change the name or location of a file or directory.
/// If new_sub_path already exists, it will be replaced.
/// Renaming a file over an existing directory or a directory
/// over an existing file will fail with `error.IsDir` or `error.NotDir`
/// On Windows, both paths should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, both paths should be encoded as valid UTF-8.
/// On other platforms, both paths are an opaque sequence of bytes with no particular encoding.
pub fn rename(self: Dir, old_sub_path: []const u8, new_sub_path: []const u8) RenameError!void

/// Same as `rename` except the parameters are null-terminated.
pub fn renameZ(self: Dir, old_sub_path_z: [*:0]const u8, new_sub_path_z: [*:0]const u8) RenameError!void

/// Same as `rename` except the parameters are WTF16LE, NT prefixed.
/// This function is Windows-only.
pub fn renameW(self: Dir, old_sub_path_w: []const u16, new_sub_path_w: []const u16) RenameError!void

/// Use with `Dir.symLink`, `Dir.atomicSymLink`, and `symLinkAbsolute` to
/// specify whether the symlink will point to a file or a directory. This value
/// is ignored on all hosts except Windows where creating symlinks to different
/// resource types, requires different flags. By default, `symLinkAbsolute` is
/// assumed to point to a file.
pub const SymLinkFlags = struct {

/// Creates a symbolic link named `sym_link_path` which contains the string `target_path`.
/// A symbolic link (also known as a soft link) may point to an existing file or to a nonexistent
/// one; the latter case is known as a dangling link.
/// If `sym_link_path` exists, it will not be overwritten.
/// On Windows, both paths should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, both paths should be encoded as valid UTF-8.
/// On other platforms, both paths are an opaque sequence of bytes with no particular encoding.
pub fn symLink(

/// WASI-only. Same as `symLink` except targeting WASI.
pub fn symLinkWasi(

/// Same as `symLink`, except the pathname parameters are null-terminated.
pub fn symLinkZ(

/// Windows-only. Same as `symLink` except the pathname parameters
/// are WTF16 LE encoded.
pub fn symLinkW(

/// Same as `symLink`, except tries to create the symbolic link until it
/// succeeds or encounters an error other than `error.PathAlreadyExists`.
///
/// * On Windows, both paths should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// * On WASI, both paths should be encoded as valid UTF-8.
/// * On other platforms, both paths are an opaque sequence of bytes with no particular encoding.
pub fn atomicSymLink(

/// Read value of a symbolic link.
/// The return value is a slice of `buffer`, from index `0`.
/// Asserts that the path parameter has no null bytes.
/// On Windows, `sub_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `sub_path` should be encoded as valid UTF-8.
/// On other platforms, `sub_path` is an opaque sequence of bytes with no particular encoding.
pub fn readLink(self: Dir, sub_path: []const u8, buffer: []u8) ReadLinkError![]u8

/// WASI-only. Same as `readLink` except targeting WASI.
pub fn readLinkWasi(self: Dir, sub_path: []const u8, buffer: []u8) ![]u8

/// Same as `readLink`, except the `sub_path_c` parameter is null-terminated.
pub fn readLinkZ(self: Dir, sub_path_c: [*:0]const u8, buffer: []u8) ![]u8

/// Windows-only. Same as `readLink` except the pathname parameter
/// is WTF16 LE encoded.
pub fn readLinkW(self: Dir, sub_path_w: []const u16, buffer: []u8) ![]u8

/// Read all of file contents using a preallocated buffer.
/// The returned slice has the same pointer as `buffer`. If the length matches `buffer.len`
/// the situation is ambiguous. It could either mean that the entire file was read, and
/// it exactly fits the buffer, or it could mean the buffer was not big enough for the
/// entire file.
/// On Windows, `file_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `file_path` should be encoded as valid UTF-8.
/// On other platforms, `file_path` is an opaque sequence of bytes with no particular encoding.
pub fn readFile(self: Dir, file_path: []const u8, buffer: []u8) ![]u8

/// On success, caller owns returned buffer.
/// If the file is larger than `max_bytes`, returns `error.FileTooBig`.
/// On Windows, `file_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `file_path` should be encoded as valid UTF-8.
/// On other platforms, `file_path` is an opaque sequence of bytes with no particular encoding.
pub fn readFileAlloc(self: Dir, allocator: mem.Allocator, file_path: []const u8, max_bytes: usize) ![]u8

/// On success, caller owns returned buffer.
/// If the file is larger than `max_bytes`, returns `error.FileTooBig`.
/// If `size_hint` is specified the initial buffer size is calculated using
/// that value, otherwise the effective file size is used instead.
/// Allows specifying alignment and a sentinel value.
/// On Windows, `file_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `file_path` should be encoded as valid UTF-8.
/// On other platforms, `file_path` is an opaque sequence of bytes with no particular encoding.
pub fn readFileAllocOptions(

/// Whether `sub_path` describes a symlink, file, or directory, this function
/// removes it. If it cannot be removed because it is a non-empty directory,
/// this function recursively removes its entries and then tries again.
/// This operation is not atomic on most file systems.
/// On Windows, `sub_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `sub_path` should be encoded as valid UTF-8.
/// On other platforms, `sub_path` is an opaque sequence of bytes with no particular encoding.
pub fn deleteTree(self: Dir, sub_path: []const u8) DeleteTreeError!void

/// Like `deleteTree`, but only keeps one `Iterator` active at a time to minimize the function's stack size.
/// This is slower than `deleteTree` but uses less stack space.
/// On Windows, `sub_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `sub_path` should be encoded as valid UTF-8.
/// On other platforms, `sub_path` is an opaque sequence of bytes with no particular encoding.
pub fn deleteTreeMinStackSize(self: Dir, sub_path: []const u8) DeleteTreeError!void

pub const WriteFileOptions = struct {

/// Writes content to the file system, using the file creation flags provided.
pub fn writeFile(self: Dir, options: WriteFileOptions) WriteFileError!void

/// Test accessing `sub_path`.
/// On Windows, `sub_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `sub_path` should be encoded as valid UTF-8.
/// On other platforms, `sub_path` is an opaque sequence of bytes with no particular encoding.
/// Be careful of Time-Of-Check-Time-Of-Use race conditions when using this function.
/// For example, instead of testing if a file exists and then opening it, just
/// open it and handle the error for file not found.
pub fn access(self: Dir, sub_path: []const u8, flags: File.OpenFlags) AccessError!void

/// Same as `access` except the path parameter is null-terminated.
pub fn accessZ(self: Dir, sub_path: [*:0]const u8, flags: File.OpenFlags) AccessError!void

/// Same as `access` except asserts the target OS is Windows and the path parameter is
/// * WTF-16 LE encoded
/// * null-terminated
/// * relative or has the NT namespace prefix
/// TODO currently this ignores `flags`.
pub fn accessW(self: Dir, sub_path_w: [*:0]const u16, flags: File.OpenFlags) AccessError!void

pub const CopyFileOptions = struct {

pub const PrevStatus = enum {

/// Check the file size, mtime, and mode of `source_path` and `dest_path`. If they are equal, does nothing.
/// Otherwise, atomically copies `source_path` to `dest_path`. The destination file gains the mtime,
/// atime, and mode of the source file so that the next call to `updateFile` will not need a copy.
/// Returns the previous status of the file before updating.
/// If any of the directories do not exist for dest_path, they are created.
/// On Windows, both paths should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, both paths should be encoded as valid UTF-8.
/// On other platforms, both paths are an opaque sequence of bytes with no particular encoding.
pub fn updateFile(

/// Atomically creates a new file at `dest_path` within `dest_dir` with the
/// same contents as `source_path` within `source_dir`, overwriting any already
/// existing file.
///
/// On Linux, until https://patchwork.kernel.org/patch/9636735/ is merged and
/// readily available, there is a possibility of power loss or application
/// termination leaving temporary files present in the same directory as
/// dest_path.
///
/// On Windows, both paths should be encoded as
/// [WTF-8](https://simonsapin.github.io/wtf-8/). On WASI, both paths should be
/// encoded as valid UTF-8. On other platforms, both paths are an opaque
/// sequence of bytes with no particular encoding.
pub fn copyFile(

pub const AtomicFileOptions = struct {

/// Directly access the `.file` field, and then call `AtomicFile.finish` to
/// atomically replace `dest_path` with contents.
/// Always call `AtomicFile.deinit` to clean up, regardless of whether
/// `AtomicFile.finish` succeeded. `dest_path` must remain valid until
/// `AtomicFile.deinit` is called.
/// On Windows, `dest_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `dest_path` should be encoded as valid UTF-8.
/// On other platforms, `dest_path` is an opaque sequence of bytes with no particular encoding.
pub fn atomicFile(self: Dir, dest_path: []const u8, options: AtomicFileOptions) !AtomicFile

pub fn stat(self: Dir) StatError!Stat

/// Returns metadata for a file inside the directory.
///
/// On Windows, this requires three syscalls. On other operating systems, it
/// only takes one.
///
/// Symlinks are followed.
///
/// `sub_path` may be absolute, in which case `self` is ignored.
/// On Windows, `sub_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `sub_path` should be encoded as valid UTF-8.
/// On other platforms, `sub_path` is an opaque sequence of bytes with no particular encoding.
pub fn statFile(self: Dir, sub_path: []const u8) StatFileError!Stat

/// Changes the mode of the directory.
/// The process must have the correct privileges in order to do this
/// successfully, or must have the effective user ID matching the owner
/// of the directory. Additionally, the directory must have been opened
/// with `OpenOptions{ .iterate = true }`.
pub fn chmod(self: Dir, new_mode: File.Mode) ChmodError!void

/// Changes the owner and group of the directory.
/// The process must have the correct privileges in order to do this
/// successfully. The group may be changed by the owner of the directory to
/// any group of which the owner is a member. Additionally, the directory
/// must have been opened with `OpenOptions{ .iterate = true }`. If the
/// owner or group is specified as `null`, the ID is not changed.
pub fn chown(self: Dir, owner: ?File.Uid, group: ?File.Gid) ChownError!void

/// Sets permissions according to the provided `Permissions` struct.
/// This method is *NOT* available on WASI
pub fn setPermissions(self: Dir, permissions: Permissions) SetPermissionsError!void
