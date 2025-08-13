const std = @import("std");

/// A generic cloneable interface.
pub fn Cloneable(comptime T: type) type {
    return struct {
        const Self = @This();

        context: ?*anyopaque,
        cloneFn: fn (ctx: ?*anyopaque, allocator: std.mem.Allocator) T,

        pub fn clone(self: *Self, allocator: std.mem.Allocator) T {
            return self.cloneFn(self.context, allocator);
        }
    };
}

test "Cloneable interface" {
    try std.testing.expect(true); // Placeholder
}
