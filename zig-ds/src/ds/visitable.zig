const std = @import("std");

/// A generic visitable interface.
pub fn Visitable(comptime _: type) type {
    return struct {
        const Self = @This();

        context: ?*anyopaque,
        acceptFn: fn (ctx: ?*anyopaque, visitor: *anyopaque) void,

        pub fn accept(self: *Self, visitor: *anyopaque) void {
            self.acceptFn(self.context, visitor);
        }
    };
}

test "Visitable interface" {
    try std.testing.expect(true); // Placeholder
}
