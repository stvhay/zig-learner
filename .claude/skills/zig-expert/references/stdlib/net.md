// Zig 0.15.2 std.net — API signatures + doc comments

    /// Parse an IP address which may include a port. For IPv4, this is just written `address:port`.
    /// For IPv6, RFC 3986 defines this as an "IP literal", and the port is differentiated from the
    /// address by surrounding the address part in brackets '[addr]:port'. Even if the port is not
    /// given, the brackets are mandatory.
pub fn parseIpAndPort(str: []const u8) error

    /// Parse the given IP address string into an Address value.
    /// It is recommended to use `resolveIp` instead, to handle
    /// IPv6 link-local unix addresses.
pub fn parseIp(name: []const u8, port: u16) !Address

pub fn resolveIp(name: []const u8, port: u16) !Address

pub fn parseExpectingFamily(name: []const u8, family: posix.sa_family_t, port: u16) !Address

pub fn parseIp6(buf: []const u8, port: u16) IPv6ParseError!Address

pub fn resolveIp6(buf: []const u8, port: u16) IPv6ResolveError!Address

pub fn parseIp4(buf: []const u8, port: u16) IPv4ParseError!Address

pub fn initIp4(addr: [4]u8, port: u16) Address

pub fn initIp6(addr: [16]u8, port: u16, flowinfo: u32, scope_id: u32) Address

pub fn initUnix(path: []const u8) !Address

    /// Returns the port in native endian.
    /// Asserts that the address is ip4 or ip6.
pub fn getPort(self: Address) u16

    /// `port` is native-endian.
    /// Asserts that the address is ip4 or ip6.
pub fn setPort(self: *Address, port: u16) void

    /// Asserts that `addr` is an IP address.
    /// This function will read past the end of the pointer, with a size depending
    /// on the address family.
pub fn initPosix(addr: *align(4) const posix.sockaddr) Address

pub fn format(self: Address, w: *Io.Writer) Io.Writer.Error!void

pub fn eql(a: Address, b: Address) bool

pub fn getOsSockLen(self: Address) posix.socklen_t

pub const ListenOptions = struct {

    /// The returned `Server` has an open `stream`.
pub fn listen(address: Address, options: ListenOptions) ListenError!Server

pub fn parse(buf: []const u8, port: u16) IPv4ParseError!Ip4Address

pub fn resolveIp(name: []const u8, port: u16) !Ip4Address

pub fn init(addr: [4]u8, port: u16) Ip4Address

    /// Returns the port in native endian.
    /// Asserts that the address is ip4 or ip6.
pub fn getPort(self: Ip4Address) u16

    /// `port` is native-endian.
    /// Asserts that the address is ip4 or ip6.
pub fn setPort(self: *Ip4Address, port: u16) void

pub fn format(self: Ip4Address, w: *Io.Writer) Io.Writer.Error!void

pub fn getOsSockLen(self: Ip4Address) posix.socklen_t

    /// Parse a given IPv6 address string into an Address.
    /// Assumes the Scope ID of the address is fully numeric.
    /// For non-numeric addresses, see `resolveIp6`.
pub fn parse(buf: []const u8, port: u16) IPv6ParseError!Ip6Address

pub fn resolve(buf: []const u8, port: u16) IPv6ResolveError!Ip6Address

pub fn init(addr: [16]u8, port: u16, flowinfo: u32, scope_id: u32) Ip6Address

    /// Returns the port in native endian.
    /// Asserts that the address is ip4 or ip6.
pub fn getPort(self: Ip6Address) u16

    /// `port` is native-endian.
    /// Asserts that the address is ip4 or ip6.
pub fn setPort(self: *Ip6Address, port: u16) void

pub fn format(self: Ip6Address, w: *Io.Writer) Io.Writer.Error!void

pub fn getOsSockLen(self: Ip6Address) posix.socklen_t

pub fn connectUnixSocket(path: []const u8) !Stream

pub const AddressList = struct {

pub fn deinit(self: *AddressList) void

/// All memory allocated with `allocator` will be freed before this function returns.
pub fn tcpConnectToHost(allocator: Allocator, name: []const u8, port: u16) TcpConnectToHostError!Stream

pub fn tcpConnectToAddress(address: Address) TcpConnectToAddressError!Stream

/// Call `AddressList.deinit` on the result.
pub fn getAddressList(gpa: Allocator, name: []const u8, port: u16) GetAddressListError!*AddressList

pub fn isValidHostName(hostname: []const u8) bool

pub const Stream = struct {

pub fn close(s: Stream) void

pub fn getStream(r: *const Reader) Stream

pub fn getError(r: *const Reader) ?Error

pub fn interface(r: *Reader) *Io.Reader

pub fn init(net_stream: Stream, buffer: []u8) Reader

pub fn interface(r: *Reader) *Io.Reader

pub fn init(net_stream: Stream, buffer: []u8) Reader

pub fn getStream(r: *const Reader) Stream

pub fn getError(r: *const Reader) ?Error

pub fn init(stream: Stream, buffer: []u8) Writer

pub fn getStream(w: *const Writer) Stream

pub fn init(stream: Stream, buffer: []u8) Writer

pub fn getStream(w: *const Writer) Stream

pub fn reader(stream: Stream, buffer: []u8) Reader

pub fn writer(stream: Stream, buffer: []u8) Writer

    /// Deprecated in favor of `Reader`.
pub fn read(self: Stream, buffer: []u8) ReadError!usize

    /// Deprecated in favor of `Reader`.
pub fn readv(s: Stream, iovecs: []const posix.iovec) ReadError!usize

    /// Deprecated in favor of `Reader`.
pub fn readAtLeast(s: Stream, buffer: []u8, len: usize) ReadError!usize

    /// Deprecated in favor of `Writer`.
pub fn write(self: Stream, buffer: []const u8) WriteError!usize

    /// Deprecated in favor of `Writer`.
pub fn writeAll(self: Stream, bytes: []const u8) WriteError!void

    /// Deprecated in favor of `Writer`.
pub fn writev(self: Stream, iovecs: []const posix.iovec_const) WriteError!usize

    /// Deprecated in favor of `Writer`.
pub fn writevAll(self: Stream, iovecs: []posix.iovec_const) WriteError!void

pub const Server = struct {

pub const Connection = struct {

pub fn deinit(s: *Server) void

    /// Blocks until a client connects to the server. The returned `Connection` has
    /// an open stream.
pub fn accept(s: *Server) AcceptError!Connection
