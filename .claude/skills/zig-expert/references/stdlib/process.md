// Zig 0.15.2 std.process — API signatures + doc comments

/// The result is a slice of `out_buffer`, from index `0`.
/// On Windows, the result is encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On other platforms, the result is an opaque sequence of bytes with no particular encoding.
pub fn getCwd(out_buffer: []u8) ![]u8

/// Caller must free the returned memory.
/// On Windows, the result is encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On other platforms, the result is an opaque sequence of bytes with no particular encoding.
pub fn getCwdAlloc(allocator: Allocator) ![]u8

pub const EnvMap = struct {

pub const EnvNameHashContext = struct {

pub fn hash(self: @This(), s: []const u8) u64

pub fn eql(self: @This(), a: []const u8, b: []const u8) bool

    /// Create a EnvMap backed by a specific allocator.
    /// That allocator will be used for both backing allocations
    /// and string deduplication.
pub fn init(allocator: Allocator) EnvMap

    /// Free the backing storage of the map, as well as all
    /// of the stored keys and values.
pub fn deinit(self: *EnvMap) void

    /// Same as `put` but the key and value become owned by the EnvMap rather
    /// than being copied.
    /// If `putMove` fails, the ownership of key and value does not transfer.
    /// On Windows `key` must be a valid [WTF-8](https://simonsapin.github.io/wtf-8/) string.
pub fn putMove(self: *EnvMap, key: []u8, value: []u8) !void

    /// `key` and `value` are copied into the EnvMap.
    /// On Windows `key` must be a valid [WTF-8](https://simonsapin.github.io/wtf-8/) string.
pub fn put(self: *EnvMap, key: []const u8, value: []const u8) !void

    /// Find the address of the value associated with a key.
    /// The returned pointer is invalidated if the map resizes.
    /// On Windows `key` must be a valid [WTF-8](https://simonsapin.github.io/wtf-8/) string.
pub fn getPtr(self: EnvMap, key: []const u8) ?*[]const u8

    /// Return the map's copy of the value associated with
    /// a key.  The returned string is invalidated if this
    /// key is removed from the map.
    /// On Windows `key` must be a valid [WTF-8](https://simonsapin.github.io/wtf-8/) string.
pub fn get(self: EnvMap, key: []const u8) ?[]const u8

    /// Removes the item from the map and frees its value.
    /// This invalidates the value returned by get() for this key.
    /// On Windows `key` must be a valid [WTF-8](https://simonsapin.github.io/wtf-8/) string.
pub fn remove(self: *EnvMap, key: []const u8) void

    /// Returns the number of KV pairs stored in the map.
pub fn count(self: EnvMap) HashMap.Size

    /// Returns an iterator over entries in the map.
pub fn iterator(self: *const EnvMap) HashMap.Iterator

/// Returns a snapshot of the environment variables of the current process.
/// Any modifications to the resulting EnvMap will not be reflected in the environment, and
/// likewise, any future modifications to the environment will not be reflected in the EnvMap.
/// Caller owns resulting `EnvMap` and should call its `deinit` fn when done.
pub fn getEnvMap(allocator: Allocator) GetEnvMapError!EnvMap

/// Caller must free returned memory.
/// On Windows, if `key` is not valid [WTF-8](https://simonsapin.github.io/wtf-8/),
/// then `error.InvalidWtf8` is returned.
/// On Windows, the value is encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On other platforms, the value is an opaque sequence of bytes with no particular encoding.
pub fn getEnvVarOwned(allocator: Allocator, key: []const u8) GetEnvVarOwnedError![]u8

/// On Windows, `key` must be valid WTF-8.
pub fn hasEnvVarConstant(comptime key: []const u8) bool

/// On Windows, `key` must be valid WTF-8.
pub fn hasNonEmptyEnvVarConstant(comptime key: []const u8) bool

/// Parses an environment variable as an integer.
///
/// Since the key is comptime-known, no allocation is needed.
///
/// On Windows, `key` must be valid WTF-8.
pub fn parseEnvVarInt(comptime key: []const u8, comptime I: type, base: u8) ParseEnvVarIntError!I

/// On Windows, if `key` is not valid [WTF-8](https://simonsapin.github.io/wtf-8/),
/// then `error.InvalidWtf8` is returned.
pub fn hasEnvVar(allocator: Allocator, key: []const u8) HasEnvVarError!bool

/// On Windows, if `key` is not valid [WTF-8](https://simonsapin.github.io/wtf-8/),
/// then `error.InvalidWtf8` is returned.
pub fn hasNonEmptyEnvVar(allocator: Allocator, key: []const u8) HasEnvVarError!bool

/// Windows-only. Get an environment variable with a null-terminated, WTF-16 encoded name.
///
/// This function performs a Unicode-aware case-insensitive lookup using RtlEqualUnicodeString.
///
/// See also:
/// * `std.posix.getenv`
/// * `getEnvMap`
/// * `getEnvVarOwned`
/// * `hasEnvVarConstant`
/// * `hasEnvVar`
pub fn getenvW(key: [*:0]const u16) ?[:0]const u16

pub const ArgIteratorPosix = struct {

pub fn init() ArgIteratorPosix

pub fn next(self: *ArgIteratorPosix) ?[:0]const u8

pub fn skip(self: *ArgIteratorPosix) bool

pub const ArgIteratorWasi = struct {

    /// You must call deinit to free the internal buffer of the
    /// iterator after you are done.
pub fn init(allocator: Allocator) InitError!ArgIteratorWasi

pub fn next(self: *ArgIteratorWasi) ?[:0]const u8

pub fn skip(self: *ArgIteratorWasi) bool

    /// Call to free the internal buffer of the iterator.
pub fn deinit(self: *ArgIteratorWasi) void

/// Iterator that implements the Windows command-line parsing algorithm.
/// The implementation is intended to be compatible with the post-2008 C runtime,
/// but is *not* intended to be compatible with `CommandLineToArgvW` since
/// `CommandLineToArgvW` uses the pre-2008 parsing rules.
///
/// This iterator faithfully implements the parsing behavior observed from the C runtime with
/// one exception: if the command-line string is empty, the iterator will immediately complete
/// without returning any arguments (whereas the C runtime will return a single argument
/// representing the name of the current executable).
///
/// The essential parts of the algorithm are described in Microsoft's documentation:
///
/// - https://learn.microsoft.com/en-us/cpp/cpp/main-function-command-line-args?view=msvc-170#parsing-c-command-line-arguments
///
/// David Deley explains some additional undocumented quirks in great detail:
///
/// - https://daviddeley.com/autohotkey/parameters/parameters.htm#WINCRULES
pub const ArgIteratorWindows = struct {

    /// `cmd_line_w` *must* be a WTF16-LE-encoded string.
    ///
    /// The iterator stores and uses `cmd_line_w`, so its memory must be valid for
    /// at least as long as the returned ArgIteratorWindows.
pub fn init(allocator: Allocator, cmd_line_w: []const u16) InitError!ArgIteratorWindows

    /// Returns the next argument and advances the iterator. Returns `null` if at the end of the
    /// command-line string. The iterator owns the returned slice.
    /// The result is encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
pub fn next(self: *ArgIteratorWindows) ?[:0]const u8

    /// Skips the next argument and advances the iterator. Returns `true` if an argument was
    /// skipped, `false` if at the end of the command-line string.
pub fn skip(self: *ArgIteratorWindows) bool

    /// Frees the iterator's copy of the command-line string and all previously returned
    /// argument slices.
pub fn deinit(self: *ArgIteratorWindows) void

/// Optional parameters for `ArgIteratorGeneral`
pub const ArgIteratorGeneralOptions = struct {

/// A general Iterator to parse a string into a set of arguments
pub fn ArgIteratorGeneral(comptime options: ArgIteratorGeneralOptions) type

        /// cmd_line_utf8 MUST remain valid and constant while using this instance
pub fn init(allocator: Allocator, cmd_line_utf8: []const u8) InitError!Self

        /// cmd_line_utf8 will be free'd (with the allocator) on deinit()
pub fn initTakeOwnership(allocator: Allocator, cmd_line_utf8: []const u8) InitError!Self

pub fn skip(self: *Self) bool

        /// Returns a slice of the internal buffer that contains the next argument.
        /// Returns null when it reaches the end.
pub fn next(self: *Self) ?[:0]const u8

        /// Call to free the internal buffer of the iterator.
pub fn deinit(self: *Self) void

/// Cross-platform command line argument iterator.
pub const ArgIterator = struct {

    /// Initialize the args iterator. Consider using initWithAllocator() instead
    /// for cross-platform compatibility.
pub fn init() ArgIterator

    /// You must deinitialize iterator's internal buffers by calling `deinit` when done.
pub fn initWithAllocator(allocator: Allocator) InitError!ArgIterator

    /// Get the next argument. Returns 'null' if we are at the end.
    /// Returned slice is pointing to the iterator's internal buffer.
    /// On Windows, the result is encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
    /// On other platforms, the result is an opaque sequence of bytes with no particular encoding.
pub fn next(self: *ArgIterator) ?([:0]const u8)

    /// Parse past 1 argument without capturing it.
    /// Returns `true` if skipped an arg, `false` if we are at the end.
pub fn skip(self: *ArgIterator) bool

    /// Call this to free the iterator's internal buffer if the iterator
    /// was created with `initWithAllocator` function.
pub fn deinit(self: *ArgIterator) void

/// Holds the command-line arguments, with the program name as the first entry.
/// Use argsWithAllocator() for cross-platform code.
pub fn args() ArgIterator

/// You must deinitialize iterator's internal buffers by calling `deinit` when done.
pub fn argsWithAllocator(allocator: Allocator) ArgIterator.InitError!ArgIterator

/// Caller must call argsFree on result.
/// On Windows, the result is encoded as [WTF-8](https://simonsapin.github.io/wtf-8/).
/// On other platforms, the result is an opaque sequence of bytes with no particular encoding.
pub fn argsAlloc(allocator: Allocator) ![][:0]u8

pub fn argsFree(allocator: Allocator, args_alloc: []const [:0]u8) void

pub const UserInfo = struct {

/// POSIX function which gets a uid from username.
pub fn getUserInfo(name: []const u8) !UserInfo

/// TODO this reads /etc/passwd. But sometimes the user/id mapping is in something else
/// like NIS, AD, etc. See `man nss` or look at an strace for `id myuser`.
pub fn posixGetUserInfo(name: []const u8) !UserInfo

pub fn getBaseAddress() usize

/// Replaces the current process image with the executed process.
/// This function must allocate memory to add a null terminating bytes on path and each arg.
/// It must also convert to KEY=VALUE\0 format for environment variables, and include null
/// pointers after the args and after the environment variables.
/// `argv[0]` is the executable path.
/// This function also uses the PATH environment variable to get the full path to the executable.
/// Due to the heap-allocation, it is illegal to call this function in a fork() child.
/// For that use case, use the `std.posix` functions directly.
pub fn execv(allocator: Allocator, argv: []const []const u8) ExecvError

/// Replaces the current process image with the executed process.
/// This function must allocate memory to add a null terminating bytes on path and each arg.
/// It must also convert to KEY=VALUE\0 format for environment variables, and include null
/// pointers after the args and after the environment variables.
/// `argv[0]` is the executable path.
/// This function also uses the PATH environment variable to get the full path to the executable.
/// Due to the heap-allocation, it is illegal to call this function in a fork() child.
/// For that use case, use the `std.posix` functions directly.
pub fn execve(

/// Returns the total system memory, in bytes as a u64.
/// We return a u64 instead of usize due to PAE on ARM
/// and Linux's /proc/meminfo reporting more memory when
/// using QEMU user mode emulation.
pub fn totalSystemMemory() TotalSystemMemoryError!u64

/// Indicate that we are now terminating with a successful exit code.
/// In debug builds, this is a no-op, so that the calling code's
/// cleanup mechanisms are tested and so that external tools that
/// check for resource leaks can be accurate. In release builds, this
/// calls exit(0), and does not return.
pub fn cleanExit() void

/// Raise the open file descriptor limit.
///
/// On some systems, this raises the limit before seeing ProcessFdQuotaExceeded
/// errors. On other systems, this does nothing.
pub fn raiseFileDescriptorLimit() void

pub const CreateEnvironOptions = struct {

/// Creates a null-delimited environment variable block in the format
/// expected by POSIX, from a hash map plus options.
pub fn createEnvironFromMap(

/// Creates a null-delimited environment variable block in the format
/// expected by POSIX, from a hash map plus options.
pub fn createEnvironFromExisting(

pub fn createNullDelimitedEnvMap(arena: mem.Allocator, env_map: *const EnvMap) Allocator.Error![:null]?[*:0]u8

/// Caller must free result.
pub fn createWindowsEnvBlock(allocator: mem.Allocator, env_map: *const EnvMap) ![]u16

/// Logs an error and then terminates the process with exit code 1.
pub fn fatal(comptime format: []const u8, format_arguments: anytype) noreturn
