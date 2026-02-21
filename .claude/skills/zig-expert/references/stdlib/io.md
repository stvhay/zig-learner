// Zig 0.15.2 std.io — API signatures + doc comments

pub const Limit = enum(usize) {

    /// `std.math.maxInt(usize)` is interpreted to mean `.unlimited`.
pub fn limited(n: usize) Limit

    /// Any value grater than `std.math.maxInt(usize)` is interpreted to mean
    /// `.unlimited`.
pub fn limited64(n: u64) Limit

pub fn countVec(data: []const []const u8) Limit

pub fn min(a: Limit, b: Limit) Limit

pub fn minInt(l: Limit, n: usize) usize

pub fn minInt64(l: Limit, n: u64) usize

pub fn slice(l: Limit, s: []u8) []u8

pub fn sliceConst(l: Limit, s: []const u8) []const u8

pub fn toInt(l: Limit) ?usize

    /// Reduces a slice to account for the limit, leaving room for one extra
    /// byte above the limit, allowing for the use case of differentiating
    /// between end-of-stream and reaching the limit.
pub fn slice1(l: Limit, non_empty_buffer: []u8) []u8

pub fn nonzero(l: Limit) bool

    /// Return a new limit reduced by `amount` or return `null` indicating
    /// limit would be exceeded.
pub fn subtract(l: Limit, amount: usize) ?Limit

/// Deprecated in favor of `Reader`.
pub fn GenericReader(

pub inline fn read(self: Self, buffer: []u8) Error!usize

pub inline fn readAll(self: Self, buffer: []u8) Error!usize

pub inline fn readAtLeast(self: Self, buffer: []u8, len: usize) Error!usize

pub inline fn readNoEof(self: Self, buf: []u8) NoEofError!void

pub inline fn readAllArrayList(

pub inline fn readAllArrayListAligned(

pub inline fn readAllAlloc(

pub inline fn readUntilDelimiterArrayList(

pub inline fn readUntilDelimiterAlloc(

pub inline fn readUntilDelimiter(

pub inline fn readUntilDelimiterOrEofAlloc(

pub inline fn readUntilDelimiterOrEof(

pub inline fn streamUntilDelimiter(

pub inline fn skipUntilDelimiterOrEof(self: Self, delimiter: u8) Error!void

pub inline fn readByte(self: Self) NoEofError!u8

pub inline fn readByteSigned(self: Self) NoEofError!i8

pub inline fn readBytesNoEof(

pub inline fn readInt(self: Self, comptime T: type, endian: std.builtin.Endian) NoEofError!T

pub inline fn readVarInt(

pub inline fn skipBytes(

pub inline fn isBytes(self: Self, slice: []const u8) NoEofError!bool

pub inline fn readStruct(self: Self, comptime T: type) NoEofError!T

pub inline fn readStructEndian(self: Self, comptime T: type, endian: std.builtin.Endian) NoEofError!T

pub inline fn readEnum(

pub inline fn any(self: *const Self) AnyReader

        /// Helper for bridging to the new `Reader` API while upgrading.
pub fn adaptToNewApi(self: *const Self, buffer: []u8) Adapter

pub const Adapter = struct {

/// Deprecated in favor of `Writer`.
pub fn GenericWriter(

pub inline fn write(self: Self, bytes: []const u8) Error!usize

pub inline fn writeAll(self: Self, bytes: []const u8) Error!void

pub inline fn print(self: Self, comptime format: []const u8, args: anytype) Error!void

pub inline fn writeByte(self: Self, byte: u8) Error!void

pub inline fn writeByteNTimes(self: Self, byte: u8, n: usize) Error!void

pub inline fn writeBytesNTimes(self: Self, bytes: []const u8, n: usize) Error!void

pub inline fn writeInt(self: Self, comptime T: type, value: T, endian: std.builtin.Endian) Error!void

pub inline fn writeStruct(self: Self, value: anytype) Error!void

pub inline fn writeStructEndian(self: Self, value: anytype, endian: std.builtin.Endian) Error!void

pub inline fn any(self: *const Self) AnyWriter

        /// Helper for bridging to the new `Writer` API while upgrading.
pub fn adaptToNewApi(self: *const Self, buffer: []u8) Adapter

pub const Adapter = struct {

pub fn poll(

pub fn Poller(comptime StreamEnum: type) type

pub fn removeAt(self: *@This(), index: u32) void

pub fn deinit(self: *Self) void

pub fn poll(self: *Self) !bool

pub fn pollTimeout(self: *Self, nanoseconds: u64) !bool

pub fn reader(self: *Self, which: StreamEnum) *Reader

pub fn toOwnedSlice(self: *Self, which: StreamEnum) error

/// Given an enum, returns a struct with fields of that enum, each field
/// representing an I/O stream for polling.
pub fn PollFiles(comptime StreamEnum: type) type
