const std = @import("std");

pub const PrintfError = error{
    BufferTooSmall,
};

pub fn printf(
    buffer: []u8,
    comptime format: []const u8,
    args: anytype,
) PrintfError![]u8 {
    return std.fmt.format(buffer, format, args);
}

test "printf" {
    var buf: [100]u8 = undefined;
    const s = try printf(&buf, "Hello, {s}!", .{"world"});
    try std.testing.expectEqualStrings("Hello, world!", s);

    const i = try printf(&buf, "Value: {d}", .{123});
    try std.testing.expectEqualStrings("Value: 123", i);
}
