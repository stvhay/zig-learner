// Zig 0.15.2 std.posix — API signatures + doc comments

pub const TCSA = enum(c_uint) {

pub const LOCK = struct {

pub const LOG = struct {

/// Obtains errno from the return value of a system function call.
///
/// For some systems this will obtain the value directly from the syscall return value;
/// for others it will use a thread-local errno variable. Therefore, this
/// function only returns a well-defined value when it is called directly after
/// the system function call whose errno value is intended to be observed.
pub fn errno(rc: anytype) E

/// Closes the file descriptor.
///
/// Asserts the file descriptor is open.
///
/// This function is not capable of returning any indication of failure. An
/// application which wants to ensure writes have succeeded before closing must
/// call `fsync` before `close`.
///
/// The Zig standard library does not support POSIX thread cancellation.
pub fn close(fd: fd_t) void

/// Changes the mode of the file referred to by the file descriptor.
///
/// The process must have the correct privileges in order to do this
/// successfully, or must have the effective user ID matching the owner
/// of the file.
pub fn fchmod(fd: fd_t, mode: mode_t) FChmodError!void

/// Changes the `mode` of `path` relative to the directory referred to by
/// `dirfd`. The process must have the correct privileges in order to do this
/// successfully, or must have the effective user ID matching the owner of the
/// file.
///
/// On Linux the `fchmodat2` syscall will be used if available, otherwise a
/// workaround using procfs will be employed. Changing the mode of a symbolic
/// link with `AT.SYMLINK_NOFOLLOW` set will also return
/// `OperationNotSupported`, as:
///
///  1. Permissions on the link are ignored when resolving its target.
///  2. This operation has been known to invoke undefined behaviour across
///     different filesystems[1].
///
/// [1]: https://sourceware.org/legacy-ml/libc-alpha/2020-02/msg00467.html.
pub inline fn fchmodat(dirfd: fd_t, path: []const u8, mode: mode_t, flags: u32) FChmodAtError!void

/// Changes the owner and group of the file referred to by the file descriptor.
/// The process must have the correct privileges in order to do this
/// successfully. The group may be changed by the owner of the directory to
/// any group of which the owner is a member. If the owner or group is
/// specified as `null`, the ID is not changed.
pub fn fchown(fd: fd_t, owner: ?uid_t, group: ?gid_t) FChownError!void

pub fn reboot(cmd: RebootCommand) RebootError!void

/// Obtain a series of random bytes. These bytes can be used to seed user-space
/// random number generators or for cryptographic purposes.
/// When linking against libc, this calls the
/// appropriate OS-specific library call. Otherwise it uses the zig standard
/// library implementation.
pub fn getrandom(buffer: []u8) GetRandomError!void

/// Causes abnormal process termination.
/// If linking against libc, this calls the abort() libc function. Otherwise
/// it raises SIGABRT followed by SIGKILL and finally lo
/// Invokes the current signal handler for SIGABRT, if any.
pub fn abort() noreturn

pub fn raise(sig: u8) RaiseError!void

pub fn kill(pid: pid_t, sig: u8) KillError!void

/// Exits all threads of the program with the specified status code.
pub fn exit(status: u8) noreturn

/// Returns the number of bytes that were read, which can be less than
/// buf.len. If 0 bytes were read, that means EOF.
/// If `fd` is opened in non blocking mode, the function will return error.WouldBlock
/// when EAGAIN is received.
///
/// Linux has a limit on how many bytes may be transferred in one `read` call, which is `0x7ffff000`
/// on both 64-bit and 32-bit systems. This is due to using a signed C int as the return value, as
/// well as stuffing the errno codes into the last `4096` values. This is noted on the `read` man page.
/// The limit on Darwin is `0x7fffffff`, trying to read more than that returns EINVAL.
/// The corresponding POSIX limit is `maxInt(isize)`.
pub fn read(fd: fd_t, buf: []u8) ReadError!usize

/// Number of bytes read is returned. Upon reading end-of-file, zero is returned.
///
/// For POSIX systems, if `fd` is opened in non blocking mode, the function will
/// return error.WouldBlock when EAGAIN is received.
/// On Windows, if the application has a global event loop enabled, I/O Completion Ports are
/// used to perform the I/O. `error.WouldBlock` is not possible on Windows.
///
/// This operation is non-atomic on the following systems:
/// * Windows
/// On these systems, the read races with concurrent writes to the same file descriptor.
///
/// This function assumes that all vectors, including zero-length vectors, have
/// a pointer within the address space of the application.
pub fn readv(fd: fd_t, iov: []const iovec) ReadError!usize

/// Number of bytes read is returned. Upon reading end-of-file, zero is returned.
///
/// Retries when interrupted by a signal.
///
/// For POSIX systems, if `fd` is opened in non blocking mode, the function will
/// return error.WouldBlock when EAGAIN is received.
/// On Windows, if the application has a global event loop enabled, I/O Completion Ports are
/// used to perform the I/O. `error.WouldBlock` is not possible on Windows.
///
/// Linux has a limit on how many bytes may be transferred in one `pread` call, which is `0x7ffff000`
/// on both 64-bit and 32-bit systems. This is due to using a signed C int as the return value, as
/// well as stuffing the errno codes into the last `4096` values. This is noted on the `read` man page.
/// The limit on Darwin is `0x7fffffff`, trying to read more than that returns EINVAL.
/// The corresponding POSIX limit is `maxInt(isize)`.
pub fn pread(fd: fd_t, buf: []u8, offset: u64) PReadError!usize

/// Length must be positive when treated as an i64.
pub fn ftruncate(fd: fd_t, length: u64) TruncateError!void

/// Number of bytes read is returned. Upon reading end-of-file, zero is returned.
///
/// Retries when interrupted by a signal.
///
/// For POSIX systems, if `fd` is opened in non blocking mode, the function will
/// return error.WouldBlock when EAGAIN is received.
/// On Windows, if the application has a global event loop enabled, I/O Completion Ports are
/// used to perform the I/O. `error.WouldBlock` is not possible on Windows.
///
/// This operation is non-atomic on the following systems:
/// * Darwin
/// * Windows
/// On these systems, the read races with concurrent writes to the same file descriptor.
pub fn preadv(fd: fd_t, iov: []const iovec, offset: u64) PReadError!usize

/// Write to a file descriptor.
/// Retries when interrupted by a signal.
/// Returns the number of bytes written. If nonzero bytes were supplied, this will be nonzero.
///
/// Note that a successful write() may transfer fewer than count bytes.  Such partial  writes  can
/// occur  for  various reasons; for example, because there was insufficient space on the disk
/// device to write all of the requested bytes, or because a blocked write() to a socket,  pipe,  or
/// similar  was  interrupted by a signal handler after it had transferred some, but before it had
/// transferred all of the requested bytes.  In the event of a partial write, the caller can  make
/// another  write() call to transfer the remaining bytes.  The subsequent call will either
/// transfer further bytes or may result in an error (e.g., if the disk is now full).
///
/// For POSIX systems, if `fd` is opened in non blocking mode, the function will
/// return error.WouldBlock when EAGAIN is received.
/// On Windows, if the application has a global event loop enabled, I/O Completion Ports are
/// used to perform the I/O. `error.WouldBlock` is not possible on Windows.
///
/// Linux has a limit on how many bytes may be transferred in one `write` call, which is `0x7ffff000`
/// on both 64-bit and 32-bit systems. This is due to using a signed C int as the return value, as
/// well as stuffing the errno codes into the last `4096` values. This is noted on the `write` man page.
/// The limit on Darwin is `0x7fffffff`, trying to read more than that returns EINVAL.
/// The corresponding POSIX limit is `maxInt(isize)`.
pub fn write(fd: fd_t, bytes: []const u8) WriteError!usize

/// Write multiple buffers to a file descriptor.
/// Retries when interrupted by a signal.
/// Returns the number of bytes written. If nonzero bytes were supplied, this will be nonzero.
///
/// Note that a successful write() may transfer fewer bytes than supplied.  Such partial  writes  can
/// occur  for  various reasons; for example, because there was insufficient space on the disk
/// device to write all of the requested bytes, or because a blocked write() to a socket,  pipe,  or
/// similar  was  interrupted by a signal handler after it had transferred some, but before it had
/// transferred all of the requested bytes.  In the event of a partial write, the caller can  make
/// another  write() call to transfer the remaining bytes.  The subsequent call will either
/// transfer further bytes or may result in an error (e.g., if the disk is now full).
///
/// For POSIX systems, if `fd` is opened in non blocking mode, the function will
/// return error.WouldBlock when EAGAIN is received.
/// On Windows, if the application has a global event loop enabled, I/O Completion Ports are
/// used to perform the I/O. `error.WouldBlock` is not possible on Windows.
///
/// If `iov.len` is larger than `IOV_MAX`, a partial write will occur.
///
/// This function assumes that all vectors, including zero-length vectors, have
/// a pointer within the address space of the application.
pub fn writev(fd: fd_t, iov: []const iovec_const) WriteError!usize

/// Write to a file descriptor, with a position offset.
/// Retries when interrupted by a signal.
/// Returns the number of bytes written. If nonzero bytes were supplied, this will be nonzero.
///
/// Note that a successful write() may transfer fewer bytes than supplied.  Such partial  writes  can
/// occur  for  various reasons; for example, because there was insufficient space on the disk
/// device to write all of the requested bytes, or because a blocked write() to a socket,  pipe,  or
/// similar  was  interrupted by a signal handler after it had transferred some, but before it had
/// transferred all of the requested bytes.  In the event of a partial write, the caller can  make
/// another  write() call to transfer the remaining bytes.  The subsequent call will either
/// transfer further bytes or may result in an error (e.g., if the disk is now full).
///
/// For POSIX systems, if `fd` is opened in non blocking mode, the function will
/// return error.WouldBlock when EAGAIN is received.
/// On Windows, if the application has a global event loop enabled, I/O Completion Ports are
/// used to perform the I/O. `error.WouldBlock` is not possible on Windows.
///
/// Linux has a limit on how many bytes may be transferred in one `pwrite` call, which is `0x7ffff000`
/// on both 64-bit and 32-bit systems. This is due to using a signed C int as the return value, as
/// well as stuffing the errno codes into the last `4096` values. This is noted on the `write` man page.
/// The limit on Darwin is `0x7fffffff`, trying to write more than that returns EINVAL.
/// The corresponding POSIX limit is `maxInt(isize)`.
pub fn pwrite(fd: fd_t, bytes: []const u8, offset: u64) PWriteError!usize

/// Write multiple buffers to a file descriptor, with a position offset.
/// Retries when interrupted by a signal.
/// Returns the number of bytes written. If nonzero bytes were supplied, this will be nonzero.
///
/// Note that a successful write() may transfer fewer than count bytes.  Such partial  writes  can
/// occur  for  various reasons; for example, because there was insufficient space on the disk
/// device to write all of the requested bytes, or because a blocked write() to a socket,  pipe,  or
/// similar  was  interrupted by a signal handler after it had transferred some, but before it had
/// transferred all of the requested bytes.  In the event of a partial write, the caller can  make
/// another  write() call to transfer the remaining bytes.  The subsequent call will either
/// transfer further bytes or may result in an error (e.g., if the disk is now full).
///
/// If `fd` is opened in non blocking mode, the function will
/// return error.WouldBlock when EAGAIN is received.
///
/// The following systems do not have this syscall, and will return partial writes if more than one
/// vector is provided:
/// * Darwin
/// * Windows
///
/// If `iov.len` is larger than `IOV_MAX`, a partial write will occur.
pub fn pwritev(fd: fd_t, iov: []const iovec_const, offset: u64) PWriteError!usize

/// Open and possibly create a file. Keeps trying if it gets interrupted.
/// On Windows, `file_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `file_path` should be encoded as valid UTF-8.
/// On other platforms, `file_path` is an opaque sequence of bytes with no particular encoding.
/// See also `openZ`.
pub fn open(file_path: []const u8, flags: O, perm: mode_t) OpenError!fd_t

/// Open and possibly create a file. Keeps trying if it gets interrupted.
/// On Windows, `file_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `file_path` should be encoded as valid UTF-8.
/// On other platforms, `file_path` is an opaque sequence of bytes with no particular encoding.
/// See also `open`.
pub fn openZ(file_path: [*:0]const u8, flags: O, perm: mode_t) OpenError!fd_t

/// Open and possibly create a file. Keeps trying if it gets interrupted.
/// `file_path` is relative to the open directory handle `dir_fd`.
/// On Windows, `file_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `file_path` should be encoded as valid UTF-8.
/// On other platforms, `file_path` is an opaque sequence of bytes with no particular encoding.
/// See also `openatZ`.
pub fn openat(dir_fd: fd_t, file_path: []const u8, flags: O, mode: mode_t) OpenError!fd_t

/// Open and possibly create a file in WASI.
pub fn openatWasi(

/// Open and possibly create a file. Keeps trying if it gets interrupted.
/// `file_path` is relative to the open directory handle `dir_fd`.
/// On Windows, `file_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `file_path` should be encoded as valid UTF-8.
/// On other platforms, `file_path` is an opaque sequence of bytes with no particular encoding.
/// See also `openat`.
pub fn openatZ(dir_fd: fd_t, file_path: [*:0]const u8, flags: O, mode: mode_t) OpenError!fd_t

pub fn dup(old_fd: fd_t) !fd_t

pub fn dup2(old_fd: fd_t, new_fd: fd_t) !void

/// This function ignores PATH environment variable. See `execvpeZ` for that.
pub fn execveZ(

pub const Arg0Expand = enum {

/// Like `execvpeZ` except if `arg0_expand` is `.expand`, then `argv` is mutable,
/// and `argv[0]` is expanded to be the same absolute path that is passed to the execve syscall.
/// If this function returns with an error, `argv[0]` will be restored to the value it was when it was passed in.
pub fn execvpeZ_expandArg0(

/// This function also uses the PATH environment variable to get the full path to the executable.
/// If `file` is an absolute path, this is the same as `execveZ`.
pub fn execvpeZ(

/// Get an environment variable.
/// See also `getenvZ`.
pub fn getenv(key: []const u8) ?[:0]const u8

/// Get an environment variable with a null-terminated name.
/// See also `getenv`.
pub fn getenvZ(key: [*:0]const u8) ?[:0]const u8

/// The result is a slice of out_buffer, indexed from 0.
pub fn getcwd(out_buffer: []u8) GetCwdError![]u8

/// Creates a symbolic link named `sym_link_path` which contains the string `target_path`.
/// A symbolic link (also known as a soft link) may point to an existing file or to a nonexistent
/// one; the latter case is known as a dangling link.
/// On Windows, both paths should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, both paths should be encoded as valid UTF-8.
/// On other platforms, both paths are an opaque sequence of bytes with no particular encoding.
/// If `sym_link_path` exists, it will not be overwritten.
/// See also `symlinkZ.
pub fn symlink(target_path: []const u8, sym_link_path: []const u8) SymLinkError!void

/// This is the same as `symlink` except the parameters are null-terminated pointers.
/// See also `symlink`.
pub fn symlinkZ(target_path: [*:0]const u8, sym_link_path: [*:0]const u8) SymLinkError!void

/// Similar to `symlink`, however, creates a symbolic link named `sym_link_path` which contains the string
/// `target_path` **relative** to `newdirfd` directory handle.
/// A symbolic link (also known as a soft link) may point to an existing file or to a nonexistent
/// one; the latter case is known as a dangling link.
/// On Windows, both paths should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, both paths should be encoded as valid UTF-8.
/// On other platforms, both paths are an opaque sequence of bytes with no particular encoding.
/// If `sym_link_path` exists, it will not be overwritten.
/// See also `symlinkatWasi`, `symlinkatZ` and `symlinkatW`.
pub fn symlinkat(target_path: []const u8, newdirfd: fd_t, sym_link_path: []const u8) SymLinkError!void

/// WASI-only. The same as `symlinkat` but targeting WASI.
/// See also `symlinkat`.
pub fn symlinkatWasi(target_path: []const u8, newdirfd: fd_t, sym_link_path: []const u8) SymLinkError!void

/// The same as `symlinkat` except the parameters are null-terminated pointers.
/// See also `symlinkat`.
pub fn symlinkatZ(target_path: [*:0]const u8, newdirfd: fd_t, sym_link_path: [*:0]const u8) SymLinkError!void

/// On WASI, both paths should be encoded as valid UTF-8.
/// On other platforms, both paths are an opaque sequence of bytes with no particular encoding.
pub fn linkZ(oldpath: [*:0]const u8, newpath: [*:0]const u8) LinkError!void

/// On WASI, both paths should be encoded as valid UTF-8.
/// On other platforms, both paths are an opaque sequence of bytes with no particular encoding.
pub fn link(oldpath: []const u8, newpath: []const u8) LinkError!void

/// On WASI, both paths should be encoded as valid UTF-8.
/// On other platforms, both paths are an opaque sequence of bytes with no particular encoding.
pub fn linkatZ(

/// On WASI, both paths should be encoded as valid UTF-8.
/// On other platforms, both paths are an opaque sequence of bytes with no particular encoding.
pub fn linkat(

/// Delete a name and possibly the file it refers to.
/// On Windows, `file_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `file_path` should be encoded as valid UTF-8.
/// On other platforms, `file_path` is an opaque sequence of bytes with no particular encoding.
/// See also `unlinkZ`.
pub fn unlink(file_path: []const u8) UnlinkError!void

/// Same as `unlink` except the parameter is null terminated.
pub fn unlinkZ(file_path: [*:0]const u8) UnlinkError!void

/// Windows-only. Same as `unlink` except the parameter is null-terminated, WTF16 LE encoded.
pub fn unlinkW(file_path_w: []const u16) UnlinkError!void

/// Delete a file name and possibly the file it refers to, based on an open directory handle.
/// On Windows, `file_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `file_path` should be encoded as valid UTF-8.
/// On other platforms, `file_path` is an opaque sequence of bytes with no particular encoding.
/// Asserts that the path parameter has no null bytes.
pub fn unlinkat(dirfd: fd_t, file_path: []const u8, flags: u32) UnlinkatError!void

/// WASI-only. Same as `unlinkat` but targeting WASI.
/// See also `unlinkat`.
pub fn unlinkatWasi(dirfd: fd_t, file_path: []const u8, flags: u32) UnlinkatError!void

/// Same as `unlinkat` but `file_path` is a null-terminated string.
pub fn unlinkatZ(dirfd: fd_t, file_path_c: [*:0]const u8, flags: u32) UnlinkatError!void

/// Same as `unlinkat` but `sub_path_w` is WTF16LE, NT prefixed. Windows only.
pub fn unlinkatW(dirfd: fd_t, sub_path_w: []const u16, flags: u32) UnlinkatError!void

/// Change the name or location of a file.
/// On Windows, both paths should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, both paths should be encoded as valid UTF-8.
/// On other platforms, both paths are an opaque sequence of bytes with no particular encoding.
pub fn rename(old_path: []const u8, new_path: []const u8) RenameError!void

/// Same as `rename` except the parameters are null-terminated.
pub fn renameZ(old_path: [*:0]const u8, new_path: [*:0]const u8) RenameError!void

/// Same as `rename` except the parameters are null-terminated and WTF16LE encoded.
/// Assumes target is Windows.
pub fn renameW(old_path: [*:0]const u16, new_path: [*:0]const u16) RenameError!void

/// Change the name or location of a file based on an open directory handle.
/// On Windows, both paths should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, both paths should be encoded as valid UTF-8.
/// On other platforms, both paths are an opaque sequence of bytes with no particular encoding.
pub fn renameat(

/// Same as `renameat` except the parameters are null-terminated.
pub fn renameatZ(

/// Same as `renameat` but Windows-only and the path parameters are
/// [WTF-16](https://simonsapin.github.io/wtf-8/#potentially-ill-formed-utf-16) encoded.
pub fn renameatW(

/// On Windows, `sub_dir_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `sub_dir_path` should be encoded as valid UTF-8.
/// On other platforms, `sub_dir_path` is an opaque sequence of bytes with no particular encoding.
pub fn mkdirat(dir_fd: fd_t, sub_dir_path: []const u8, mode: mode_t) MakeDirError!void

pub fn mkdiratWasi(dir_fd: fd_t, sub_dir_path: []const u8, mode: mode_t) MakeDirError!void

/// Same as `mkdirat` except the parameters are null-terminated.
pub fn mkdiratZ(dir_fd: fd_t, sub_dir_path: [*:0]const u8, mode: mode_t) MakeDirError!void

/// Windows-only. Same as `mkdirat` except the parameter WTF16 LE encoded.
pub fn mkdiratW(dir_fd: fd_t, sub_path_w: []const u16, mode: mode_t) MakeDirError!void

/// Create a directory.
/// `mode` is ignored on Windows and WASI.
/// On Windows, `dir_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `dir_path` should be encoded as valid UTF-8.
/// On other platforms, `dir_path` is an opaque sequence of bytes with no particular encoding.
pub fn mkdir(dir_path: []const u8, mode: mode_t) MakeDirError!void

/// Same as `mkdir` but the parameter is null-terminated.
/// On Windows, `dir_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `dir_path` should be encoded as valid UTF-8.
/// On other platforms, `dir_path` is an opaque sequence of bytes with no particular encoding.
pub fn mkdirZ(dir_path: [*:0]const u8, mode: mode_t) MakeDirError!void

/// Windows-only. Same as `mkdir` but the parameters is WTF16LE encoded.
pub fn mkdirW(dir_path_w: []const u16, mode: mode_t) MakeDirError!void

/// Deletes an empty directory.
/// On Windows, `dir_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `dir_path` should be encoded as valid UTF-8.
/// On other platforms, `dir_path` is an opaque sequence of bytes with no particular encoding.
pub fn rmdir(dir_path: []const u8) DeleteDirError!void

/// Same as `rmdir` except the parameter is null-terminated.
/// On Windows, `dir_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `dir_path` should be encoded as valid UTF-8.
/// On other platforms, `dir_path` is an opaque sequence of bytes with no particular encoding.
pub fn rmdirZ(dir_path: [*:0]const u8) DeleteDirError!void

/// Windows-only. Same as `rmdir` except the parameter is WTF-16 LE encoded.
pub fn rmdirW(dir_path_w: []const u16) DeleteDirError!void

/// Changes the current working directory of the calling process.
/// On Windows, `dir_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `dir_path` should be encoded as valid UTF-8.
/// On other platforms, `dir_path` is an opaque sequence of bytes with no particular encoding.
pub fn chdir(dir_path: []const u8) ChangeCurDirError!void

/// Same as `chdir` except the parameter is null-terminated.
/// On Windows, `dir_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `dir_path` should be encoded as valid UTF-8.
/// On other platforms, `dir_path` is an opaque sequence of bytes with no particular encoding.
pub fn chdirZ(dir_path: [*:0]const u8) ChangeCurDirError!void

/// Windows-only. Same as `chdir` except the parameter is WTF16 LE encoded.
pub fn chdirW(dir_path: []const u16) ChangeCurDirError!void

pub fn fchdir(dirfd: fd_t) FchdirError!void

/// Read value of a symbolic link.
/// On Windows, `file_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `file_path` should be encoded as valid UTF-8.
/// On other platforms, `file_path` is an opaque sequence of bytes with no particular encoding.
/// The return value is a slice of `out_buffer` from index 0.
/// On Windows, the result is encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, the result is encoded as UTF-8.
/// On other platforms, the result is an opaque sequence of bytes with no particular encoding.
pub fn readlink(file_path: []const u8, out_buffer: []u8) ReadLinkError![]u8

/// Windows-only. Same as `readlink` except `file_path` is WTF16 LE encoded.
/// The result is encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// See also `readlinkZ`.
pub fn readlinkW(file_path: []const u16, out_buffer: []u8) ReadLinkError![]u8

/// Same as `readlink` except `file_path` is null-terminated.
pub fn readlinkZ(file_path: [*:0]const u8, out_buffer: []u8) ReadLinkError![]u8

/// Similar to `readlink` except reads value of a symbolink link **relative** to `dirfd` directory handle.
/// On Windows, `file_path` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, `file_path` should be encoded as valid UTF-8.
/// On other platforms, `file_path` is an opaque sequence of bytes with no particular encoding.
/// The return value is a slice of `out_buffer` from index 0.
/// On Windows, the result is encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On WASI, the result is encoded as UTF-8.
/// On other platforms, the result is an opaque sequence of bytes with no particular encoding.
/// See also `readlinkatWasi`, `realinkatZ` and `realinkatW`.
pub fn readlinkat(dirfd: fd_t, file_path: []const u8, out_buffer: []u8) ReadLinkError![]u8

/// WASI-only. Same as `readlinkat` but targets WASI.
/// See also `readlinkat`.
pub fn readlinkatWasi(dirfd: fd_t, file_path: []const u8, out_buffer: []u8) ReadLinkError![]u8

/// Windows-only. Same as `readlinkat` except `file_path` is null-terminated, WTF16 LE encoded.
/// The result is encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// See also `readlinkat`.
pub fn readlinkatW(dirfd: fd_t, file_path: []const u16, out_buffer: []u8) ReadLinkError![]u8

/// Same as `readlinkat` except `file_path` is null-terminated.
/// See also `readlinkat`.
pub fn readlinkatZ(dirfd: fd_t, file_path: [*:0]const u8, out_buffer: []u8) ReadLinkError![]u8

pub fn setuid(uid: uid_t) SetIdError!void

pub fn seteuid(uid: uid_t) SetEidError!void

pub fn setreuid(ruid: uid_t, euid: uid_t) SetIdError!void

pub fn setgid(gid: gid_t) SetIdError!void

pub fn setegid(uid: uid_t) SetEidError!void

pub fn setregid(rgid: gid_t, egid: gid_t) SetIdError!void

pub fn setpgid(pid: pid_t, pgid: pid_t) SetPgidError!void

pub fn getuid() uid_t

pub fn geteuid() uid_t

/// Test whether a file descriptor refers to a terminal.
pub fn isatty(handle: fd_t) bool

pub fn socket(domain: u32, socket_type: u32, protocol: u32) SocketError!socket_t

pub const ShutdownHow = enum { recv, send, both };

/// Shutdown socket send/receive operations
pub fn shutdown(sock: socket_t, how: ShutdownHow) ShutdownError!void

/// addr is `*const T` where T is one of the sockaddr
pub fn bind(sock: socket_t, addr: *const sockaddr, len: socklen_t) BindError!void

pub fn listen(sock: socket_t, backlog: u31) ListenError!void

/// Accept a connection on a socket.
/// If `sockfd` is opened in non blocking mode, the function will
/// return error.WouldBlock when EAGAIN is received.
pub fn accept(

pub fn epoll_create1(flags: u32) EpollCreateError!i32

pub fn epoll_ctl(epfd: i32, op: u32, fd: i32, event: ?*system.epoll_event) EpollCtlError!void

/// Waits for an I/O event on an epoll file descriptor.
/// Returns the number of file descriptors ready for the requested I/O,
/// or zero if no file descriptor became ready during the requested timeout milliseconds.
pub fn epoll_wait(epfd: i32, events: []system.epoll_event, timeout: i32) usize

pub fn eventfd(initval: u32, flags: u32) EventFdError!i32

pub fn getsockname(sock: socket_t, addr: *sockaddr, addrlen: *socklen_t) GetSockNameError!void

pub fn getpeername(sock: socket_t, addr: *sockaddr, addrlen: *socklen_t) GetSockNameError!void

/// Initiate a connection on a socket.
/// If `sockfd` is opened in non blocking mode, the function will
/// return error.WouldBlock when EAGAIN or EINPROGRESS is received.
pub fn connect(sock: socket_t, sock_addr: *const sockaddr, len: socklen_t) ConnectError!void

pub fn getsockopt(fd: socket_t, level: i32, optname: u32, opt: []u8) GetSockOptError!void

pub fn getsockoptError(sockfd: fd_t) ConnectError!void

pub const WaitPidResult = struct {

/// Use this version of the `waitpid` wrapper if you spawned your child process using explicit
/// `fork` and `execve` method.
pub fn waitpid(pid: pid_t, flags: u32) WaitPidResult

pub fn wait4(pid: pid_t, flags: u32, ru: ?*rusage) WaitPidResult

/// Return information about a file descriptor.
pub fn fstat(fd: fd_t) FStatError!Stat

/// Similar to `fstat`, but returns stat of a resource pointed to by `pathname`
/// which is relative to `dirfd` handle.
/// On WASI, `pathname` should be encoded as valid UTF-8.
/// On other platforms, `pathname` is an opaque sequence of bytes with no particular encoding.
/// See also `fstatatZ` and `std.os.fstatat_wasi`.
pub fn fstatat(dirfd: fd_t, pathname: []const u8, flags: u32) FStatAtError!Stat

/// Same as `fstatat` but `pathname` is null-terminated.
/// See also `fstatat`.
pub fn fstatatZ(dirfd: fd_t, pathname: [*:0]const u8, flags: u32) FStatAtError!Stat

pub fn kqueue() KQueueError!i32

pub fn kevent(

/// initialize an inotify instance
pub fn inotify_init1(flags: u32) INotifyInitError!i32

/// add a watch to an initialized inotify instance
pub fn inotify_add_watch(inotify_fd: i32, pathname: []const u8, mask: u32) INotifyAddWatchError!i32

/// Same as `inotify_add_watch` except pathname is null-terminated.
pub fn inotify_add_watchZ(inotify_fd: i32, pathname: [*:0]const u8, mask: u32) INotifyAddWatchError!i32

/// remove an existing watch from an inotify instance
pub fn inotify_rm_watch(inotify_fd: i32, wd: i32) void

pub fn fanotify_init(flags: std.os.linux.fanotify.InitFlags, event_f_flags: u32) FanotifyInitError!i32

pub fn fanotify_mark(

pub fn fanotify_markZ(

pub fn mprotect(memory: []align(page_size_min) u8, protection: u32) MProtectError!void

pub fn fork() ForkError!pid_t

/// Map files or devices into memory.
/// `length` does not need to be aligned.
/// Use of a mapped region can result in these signals:
/// * SIGSEGV - Attempted write into a region mapped as read-only.
/// * SIGBUS - Attempted  access to a portion of the buffer that does not correspond to the file
pub fn mmap(

/// Deletes the mappings for the specified address range, causing
/// further references to addresses within the range to generate invalid memory references.
/// Note that while POSIX allows unmapping a region in the middle of an existing mapping,
/// Zig's munmap function does not, for two reasons:
/// * It violates the Zig principle that resource deallocation must succeed.
/// * The Windows function, VirtualFree, has this restriction.
pub fn munmap(memory: []align(page_size_min) const u8) void

pub fn mremap(

pub fn msync(memory: []align(page_size_min) u8, flags: i32) MSyncError!void

/// check user's permissions for a file
///
/// * On Windows, asserts `path` is valid [WTF-8](https://simonsapin.github.io/wtf-8/).
/// * On WASI, invalid UTF-8 passed to `path` causes `error.InvalidUtf8`.
/// * On other platforms, `path` is an opaque sequence of bytes with no particular encoding.
///
/// On Windows, `mode` is ignored. This is a POSIX API that is only partially supported by
/// Windows. See `fs` for the cross-platform file system API.
pub fn access(path: []const u8, mode: u32) AccessError!void

/// Same as `access` except `path` is null-terminated.
pub fn accessZ(path: [*:0]const u8, mode: u32) AccessError!void

/// Check user's permissions for a file, based on an open directory handle.
///
/// * On Windows, asserts `path` is valid [WTF-8](https://simonsapin.github.io/wtf-8/).
/// * On WASI, invalid UTF-8 passed to `path` causes `error.InvalidUtf8`.
/// * On other platforms, `path` is an opaque sequence of bytes with no particular encoding.
///
/// On Windows, `mode` is ignored. This is a POSIX API that is only partially supported by
/// Windows. See `fs` for the cross-platform file system API.
pub fn faccessat(dirfd: fd_t, path: []const u8, mode: u32, flags: u32) AccessError!void

/// Same as `faccessat` except the path parameter is null-terminated.
pub fn faccessatZ(dirfd: fd_t, path: [*:0]const u8, mode: u32, flags: u32) AccessError!void

/// Same as `faccessat` except asserts the target is Windows and the path parameter
/// is NtDll-prefixed, null-terminated, WTF-16 encoded.
pub fn faccessatW(dirfd: fd_t, sub_path_w: [*:0]const u16) AccessError!void

/// Creates a unidirectional data channel that can be used for interprocess communication.
pub fn pipe() PipeError![2]fd_t

pub fn pipe2(flags: O) PipeError![2]fd_t

pub fn sysctl(

pub fn sysctlbynameZ(

pub fn gettimeofday(tv: ?*timeval, tz: ?*timezone) void

/// Repositions read/write file offset relative to the beginning.
pub fn lseek_SET(fd: fd_t, offset: u64) SeekError!void

/// Repositions read/write file offset relative to the current offset.
pub fn lseek_CUR(fd: fd_t, offset: i64) SeekError!void

/// Repositions read/write file offset relative to the end.
pub fn lseek_END(fd: fd_t, offset: i64) SeekError!void

/// Returns the read/write file offset relative to the beginning.
pub fn lseek_CUR_get(fd: fd_t) SeekError!u64

pub fn fcntl(fd: fd_t, cmd: i32, arg: usize) FcntlError!usize

/// Depending on the operating system `flock` may or may not interact with
/// `fcntl` locks made by other processes.
pub fn flock(fd: fd_t, operation: i32) FlockError!void

/// Return the canonicalized absolute pathname.
///
/// Expands all symbolic links and resolves references to `.`, `..`, and
/// extra `/` characters in `pathname`.
///
/// On Windows, `pathname` should be encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
///
/// On other platforms, `pathname` is an opaque sequence of bytes with no particular encoding.
///
/// The return value is a slice of `out_buffer`, but not necessarily from the beginning.
///
/// See also `realpathZ` and `realpathW`.
///
/// * On Windows, the result is encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// * On other platforms, the result is an opaque sequence of bytes with no particular encoding.
///
/// Calling this function is usually a bug.
pub fn realpath(pathname: []const u8, out_buffer: *[max_path_bytes]u8) RealPathError![]u8

/// Same as `realpath` except `pathname` is null-terminated.
///
/// Calling this function is usually a bug.
pub fn realpathZ(pathname: [*:0]const u8, out_buffer: *[max_path_bytes]u8) RealPathError![]u8

/// Same as `realpath` except `pathname` is WTF16LE-encoded.
///
/// The result is encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
///
/// Calling this function is usually a bug.
pub fn realpathW(pathname: []const u16, out_buffer: *[max_path_bytes]u8) RealPathError![]u8

/// Spurious wakeups are possible and no precision of timing is guaranteed.
pub fn nanosleep(seconds: u64, nanoseconds: u64) void

pub fn dl_iterate_phdr(

pub fn clock_gettime(clock_id: clockid_t) ClockGetTimeError!timespec

pub fn clock_getres(clock_id: clockid_t, res: *timespec) ClockGetTimeError!void

pub fn sched_getaffinity(pid: pid_t) SchedGetAffinityError!cpu_set_t

pub fn sigaltstack(ss: ?*stack_t, old_ss: ?*stack_t) SigaltstackError!void

/// Return a filled sigset_t.
pub fn sigfillset() sigset_t

/// Return an empty sigset_t.
pub fn sigemptyset() sigset_t

pub fn sigaddset(set: *sigset_t, sig: u8) void

pub fn sigdelset(set: *sigset_t, sig: u8) void

pub fn sigismember(set: *const sigset_t, sig: u8) bool

/// Examine and change a signal action.
pub fn sigaction(sig: u8, noalias act: ?*const Sigaction, noalias oact: ?*Sigaction) void

/// Sets the thread signal mask.
pub fn sigprocmask(flags: u32, noalias set: ?*const sigset_t, noalias oldset: ?*sigset_t) void

pub fn futimens(fd: fd_t, times: ?*const [2]timespec) FutimensError!void

pub fn gethostname(name_buffer: *[HOST_NAME_MAX]u8) GetHostNameError![]u8

pub fn uname() utsname

pub fn res_mkquery(

pub fn sendmsg(

/// Transmit a message to another socket.
///
/// The `sendto` call may be used only when the socket is in a connected state (so that the intended
/// recipient  is  known). The  following call
///
///     send(sockfd, buf, len, flags);
///
/// is equivalent to
///
///     sendto(sockfd, buf, len, flags, NULL, 0);
///
/// If  sendto()  is used on a connection-mode (`SOCK.STREAM`, `SOCK.SEQPACKET`) socket, the arguments
/// `dest_addr` and `addrlen` are asserted to be `null` and `0` respectively, and asserted
/// that the socket was actually connected.
/// Otherwise, the address of the target is given by `dest_addr` with `addrlen` specifying  its  size.
///
/// If the message is too long to pass atomically through the underlying protocol,
/// `SendError.MessageTooBig` is returned, and the message is not transmitted.
///
/// There is no  indication  of  failure  to  deliver.
///
/// When the message does not fit into the send buffer of  the  socket,  `sendto`  normally  blocks,
/// unless  the socket has been placed in nonblocking I/O mode.  In nonblocking mode it would fail
/// with `SendError.WouldBlock`.  The `select` call may be used  to  determine when it is
/// possible to send more data.
pub fn sendto(

/// Transmit a message to another socket.
///
/// The `send` call may be used only when the socket is in a connected state (so that the intended
/// recipient  is  known).   The  only  difference  between `send` and `write` is the presence of
/// flags.  With a zero flags argument, `send` is equivalent to  `write`.   Also,  the  following
/// call
///
///     send(sockfd, buf, len, flags);
///
/// is equivalent to
///
///     sendto(sockfd, buf, len, flags, NULL, 0);
///
/// There is no  indication  of  failure  to  deliver.
///
/// When the message does not fit into the send buffer of  the  socket,  `send`  normally  blocks,
/// unless  the socket has been placed in nonblocking I/O mode.  In nonblocking mode it would fail
/// with `SendError.WouldBlock`.  The `select` call may be used  to  determine when it is
/// possible to send more data.
pub fn send(

/// Transfer data between file descriptors at specified offsets.
///
/// Returns the number of bytes written, which can less than requested.
///
/// The `copy_file_range` call copies `len` bytes from one file descriptor to another. When possible,
/// this is done within the operating system kernel, which can provide better performance
/// characteristics than transferring data from kernel to user space and back, such as with
/// `pread` and `pwrite` calls.
///
/// `fd_in` must be a file descriptor opened for reading, and `fd_out` must be a file descriptor
/// opened for writing. They may be any kind of file descriptor; however, if `fd_in` is not a regular
/// file system file, it may cause this function to fall back to calling `pread` and `pwrite`, in which case
/// atomicity guarantees no longer apply.
///
/// If `fd_in` and `fd_out` are the same, source and target ranges must not overlap.
/// The file descriptor seek positions are ignored and not updated.
/// When `off_in` is past the end of the input file, it successfully reads 0 bytes.
///
/// `flags` has different meanings per operating system; refer to the respective man pages.
///
/// These systems support in-kernel data copying:
/// * Linux (cross-filesystem from version 5.3)
/// * FreeBSD 13.0
///
/// Other systems fall back to calling `pread` / `pwrite`.
///
/// Maximum offsets on Linux and FreeBSD are `maxInt(i64)`.
pub fn copy_file_range(fd_in: fd_t, off_in: u64, fd_out: fd_t, off_out: u64, len: usize, flags: u32) CopyFileRangeError!usize

pub fn poll(fds: []pollfd, timeout: i32) PollError!usize

pub fn ppoll(fds: []pollfd, timeout: ?*const timespec, mask: ?*const sigset_t) PPollError!usize

pub fn recv(sock: socket_t, buf: []u8, flags: u32) RecvFromError!usize

/// If `sockfd` is opened in non blocking mode, the function will
/// return error.WouldBlock when EAGAIN is received.
pub fn recvfrom(

pub fn dn_expand(

/// Set a socket's options.
pub fn setsockopt(fd: socket_t, level: i32, optname: u32, opt: []const u8) SetSockOptError!void

pub fn memfd_createZ(name: [*:0]const u8, flags: u32) MemFdCreateError!fd_t

pub fn memfd_create(name: []const u8, flags: u32) MemFdCreateError!fd_t

pub fn getrusage(who: i32) rusage

pub fn tcgetattr(handle: fd_t) TermiosGetError!termios

pub fn tcsetattr(handle: fd_t, optional_action: TCSA, termios_p: termios) TermiosSetError!void

/// Returns the process group ID for the TTY associated with the given handle.
pub fn tcgetpgrp(handle: fd_t) TermioGetPgrpError!pid_t

/// Sets the controlling process group ID for given TTY.
/// handle must be valid fd_t to a TTY associated with calling process.
/// pgrp must be a valid process group, and the calling process must be a member
/// of that group.
pub fn tcsetpgrp(handle: fd_t, pgrp: pid_t) TermioSetPgrpError!void

pub fn setsid() SetSidError!pid_t

pub fn signalfd(fd: fd_t, mask: *const sigset_t, flags: u32) !fd_t

/// Write all pending file contents and metadata modifications to all filesystems.
pub fn sync() void

/// Write all pending file contents and metadata modifications to the filesystem which contains the specified file.
pub fn syncfs(fd: fd_t) SyncError!void

/// Write all pending file contents and metadata modifications for the specified file descriptor to the underlying filesystem.
pub fn fsync(fd: fd_t) SyncError!void

/// Write all pending file contents for the specified file descriptor to the underlying filesystem, but not necessarily the metadata.
pub fn fdatasync(fd: fd_t) SyncError!void

pub fn prctl(option: PR, args: anytype) PrctlError!u31

pub fn getrlimit(resource: rlimit_resource) GetrlimitError!rlimit

pub fn setrlimit(resource: rlimit_resource, limits: rlimit) SetrlimitError!void

/// Determine whether pages are resident in memory.
pub fn mincore(ptr: [*]align(page_size_min) u8, length: usize, vec: [*]u8) MincoreError!void

/// Give advice about use of memory.
/// This syscall is optional and is sometimes configured to be disabled.
pub fn madvise(ptr: [*]align(page_size_min) u8, length: usize, advice: u32) MadviseError!void

pub fn perf_event_open(

pub fn timerfd_create(clock_id: system.timerfd_clockid_t, flags: system.TFD) TimerFdCreateError!fd_t

pub fn timerfd_settime(

pub fn timerfd_gettime(fd: i32) TimerFdGetError!system.itimerspec

pub fn ptrace(request: u32, pid: pid_t, addr: usize, signal: usize) PtraceError!void

pub fn name_to_handle_at(

pub fn name_to_handle_atZ(

pub fn ioctl_SIOCGIFINDEX(fd: fd_t, ifr: *ifreq) IoCtl_SIOCGIFINDEX_Error!void

/// Call this when you made a syscall or something that sets errno
/// and you get an unexpected error.
pub fn unexpectedErrno(err: E) UnexpectedError

/// Used to convert a slice to a null terminated slice on the stack.
pub fn toPosixPath(file_path: []const u8) error
