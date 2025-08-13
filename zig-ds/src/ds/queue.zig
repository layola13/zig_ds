const std = @import("std");
const Collection = @import("collection.zig").Collection;

/// A generic queue interface.
pub fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();

        context: ?*anyopaque,
        addFn: fn (ctx: ?*anyopaque, val: T) void,
        frontFn: fn (ctx: ?*anyopaque) ?T,
        removeFn: fn (ctx: ?*anyopaque) ?T,
        collection: Collection(T),

        pub fn add(self: *Self, val: T) void {
            self.addFn(self.context, val);
        }

        pub fn front(self: *Self) ?T {
            return self.frontFn(self.context);
        }

        pub fn remove(self: *Self) ?T {
            return self.removeFn(self.context);
        }
    };
}

test "Queue interface" {
    try std.testing.expect(true); // Placeholder
}
