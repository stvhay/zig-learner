// Zig 0.15.2 std.fmt — API signatures + doc comments

pub const Alignment = enum {

pub const Case = enum { lower, upper };

pub const Options = struct {

pub fn toNumber(o: Options, mode: Number.Mode, case: Case) Number

pub const Number = struct {

pub const Mode = enum {

pub fn base(mode: Mode) ?u8

/// Deprecated in favor of `Writer.print`.
pub fn format(writer: anytype, comptime fmt: []const u8, args: anytype) !void

pub const Placeholder = struct {

pub fn parse(comptime bytes: []const u8) Placeholder

pub const Specifier = union(enum) {

/// A stream based parser for format strings.
///
/// Allows to implement formatters compatible with std.fmt without replicating
/// the standard library behavior.
pub const Parser = struct {

pub fn number(self: *@This()) ?usize

pub fn until(self: *@This(), delimiter: u8) []const u8

pub fn char(self: *@This()) ?u8

pub fn maybe(self: *@This(), byte: u8) bool

pub fn specifier(self: *@This()) !Specifier

pub fn peek(self: *@This(), i: usize) ?u8

pub const ArgState = struct {

pub fn hasUnusedArgs(self: *@This()) bool

pub fn nextArg(self: *@This(), arg_index: ?usize) ?usize

/// Asserts the rendered integer value fits in `buffer`.
/// Returns the end index within `buffer`.
pub fn printInt(buffer: []u8, value: anytype, base: u8, case: Case, options: Options) usize

/// Converts values in the range [0, 100) to a base 10 string.
pub fn digits2(value: u8) [2]u8

/// Creates a type suitable for instantiating and passing to a "{f}" placeholder.
pub fn Alt(

pub inline fn format(self: @This(), writer: *Writer) Writer.Error!void

/// Helper for calling alternate format methods besides one named "format".
pub fn alt(

pub fn other(ex: @This(), w: *Writer) Writer.Error!void

/// Parses the string `buf` as signed or unsigned representation in the
/// specified base of an integral value of type `T`.
///
/// When `base` is zero the string prefix is examined to detect the true base:
///  * A prefix of "0b" implies base=2,
///  * A prefix of "0o" implies base=8,
///  * A prefix of "0x" implies base=16,
///  * Otherwise base=10 is assumed.
///
/// Ignores '_' character in `buf`.
/// See also `parseUnsigned`.
pub fn parseInt(comptime T: type, buf: []const u8, base: u8) ParseIntError!T

/// Like `parseInt`, but with a generic `Character` type.
pub fn parseIntWithGenericCharacter(

/// Parses the string `buf` as unsigned representation in the specified base
/// of an integral value of type `T`.
///
/// When `base` is zero the string prefix is examined to detect the true base:
///  * A prefix of "0b" implies base=2,
///  * A prefix of "0o" implies base=8,
///  * A prefix of "0x" implies base=16,
///  * Otherwise base=10 is assumed.
///
/// Ignores '_' character in `buf`.
/// See also `parseInt`.
pub fn parseUnsigned(comptime T: type, buf: []const u8, base: u8) ParseIntError!T

/// Parses a number like '2G', '2Gi', or '2GiB'.
pub fn parseIntSizeSuffix(buf: []const u8, digit_base: u8) ParseIntError!usize

pub fn charToDigit(c: u8, base: u8) (error

pub fn digitToChar(digit: u8, case: Case) u8

/// Print a Formatter string into `buf`. Returns a slice of the bytes printed.
pub fn bufPrint(buf: []u8, comptime fmt: []const u8, args: anytype) BufPrintError![]u8

pub fn bufPrintZ(buf: []u8, comptime fmt: []const u8, args: anytype) BufPrintError![:0]u8

/// Count the characters needed for format.
pub fn count(comptime fmt: []const u8, args: anytype) usize

pub fn allocPrint(gpa: Allocator, comptime fmt: []const u8, args: anytype) Allocator.Error![]u8

pub fn allocPrintSentinel(

pub inline fn comptimePrint(comptime fmt: []const u8, args: anytype) *const [count(fmt, args):0]u8

pub fn format(s: @This(), writer: *Writer) Writer.Error!void

/// Encodes a sequence of bytes as hexadecimal digits.
/// Returns an array containing the encoded bytes.
pub fn bytesToHex(input: anytype, case: Case) [input.len * 2]u8

/// Decodes the sequence of bytes represented by the specified string of
/// hexadecimal characters.
/// Returns a slice of the output buffer containing the decoded bytes.
pub fn hexToBytes(out: []u8, input: []const u8) ![]u8

/// Converts an unsigned integer of any multiple of u8 to an array of lowercase
/// hex bytes, little endian.
pub fn hex(x: anytype) [@sizeOf(@TypeOf(x)) * 2]u8
