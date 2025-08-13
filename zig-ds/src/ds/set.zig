const std = @import("std");
const Collection = @import("collection.zig").Collection;

/// A generic set interface.
pub fn Set(comptime T: type) type {
    return struct {
        const Self = @This();

        context: ?*anyopaque,
        setFn: fn (ctx: ?*anyopaque, val: T) bool,
        collection: Collection(T),

        pub fn set(self: *Self, val: T) bool {
            return self.setFn(self.context, val);
        }
    };
}

test "Set interface" {
    try std.testing.expect(true); // Placeholder
}
