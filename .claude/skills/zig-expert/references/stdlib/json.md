// Zig 0.15.2 std.json — API signatures + doc comments

/// Returns a formatter that formats the given value using stringify.
pub fn fmt(value: anytype, options: Stringify.Options) Formatter(@TypeOf(value))

/// Formats the given value using stringify.
pub fn Formatter(comptime T: type) type

pub fn format(self: @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void
