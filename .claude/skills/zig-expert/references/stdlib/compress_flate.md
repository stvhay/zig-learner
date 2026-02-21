// Zig 0.15.2 std.compress.flate — API signatures + doc comments

/// Container of the deflate bit stream body. Container adds header before
/// deflate bit stream and footer after. It can bi gzip, zlib or raw (no header,
/// no footer, raw bit stream).
///
/// Zlib format is defined in rfc 1950. Header has 2 bytes and footer 4 bytes
/// addler 32 checksum.
///
/// Gzip format is defined in rfc 1952. Header has 10+ bytes and footer 4 bytes
/// crc32 checksum and 4 bytes of uncompressed data length.
///
/// rfc 1950: https://datatracker.ietf.org/doc/html/rfc1950#page-4
/// rfc 1952: https://datatracker.ietf.org/doc/html/rfc1952#page-5
pub const Container = enum {

pub fn size(w: Container) usize

pub fn headerSize(w: Container) usize

pub fn footerSize(w: Container) usize

pub fn header(container: Container) []const u8

pub const Hasher = union(Container) {

pub fn init(containter: Container) Hasher

pub fn container(h: Hasher) Container

pub fn update(h: *Hasher, buf: []const u8) void

pub fn writeFooter(hasher: *Hasher, writer: *std.Io.Writer) std.Io.Writer.Error!void

pub const Metadata = union(Container) {

pub fn init(containter: Container) Metadata

pub fn container(m: Metadata) Container
