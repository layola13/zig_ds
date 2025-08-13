const std = @import("std");

/// A generic hashable interface.
pub fn Hashable(comptime _: type) type {
    return struct {
        const Self = @This();

        context: ?*anyopaque,
        keyFn: fn (ctx: ?*anyopaque) u64,

        pub fn key(self: *Self) u64 {
            return self.keyFn(self.context);
        }
    };
}

test "Hashable interface" {
    try std.testing.expect(true); // Placeholder
}
