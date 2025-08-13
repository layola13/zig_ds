const std = @import("std");

/// A generic iterator interface.
pub fn Itr(comptime T: type) type {
    return struct {
        const Self = @This();

        context: ?*anyopaque,
        nextFn: fn (ctx: ?*anyopaque) ?T,
        resetFn: fn (ctx: ?*anyopaque) void,
        removeFn: fn (ctx: ?*anyopaque) void,

        pub fn next(self: *Self) ?T {
            return self.nextFn(self.context);
        }

        pub fn reset(self: *Self) void {
            self.resetFn(self.context);
        }

        pub fn remove(self: *Self) void {
            self.removeFn(self.context);
        }
    };
}

// A test requires a concrete iterator implementation.
// We will add a proper test when we implement an iterator for a collection.
test "Itr interface" {
    try std.testing.expect(true); // Placeholder
}
