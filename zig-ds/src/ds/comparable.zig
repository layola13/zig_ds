const std = @import("std");

/// A generic comparable interface.
pub fn Comparable(comptime T: type) type {
    return struct {
        const Self = @This();

        context: ?*anyopaque,
        compareFn: fn (ctx: ?*anyopaque, other: T) std.math.Order,

        pub fn compare(self: *Self, other: T) std.math.Order {
            return self.compareFn(self.context, other);
        }
    };
}

test "Comparable interface" {
    try std.testing.expect(true); // Placeholder
}
