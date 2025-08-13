const std = @import("std");
const Queue = @import("queue.zig").Queue;

/// A generic deque interface.
pub fn Deque(comptime T: type) type {
    return struct {
        const Self = @This();

        context: ?*anyopaque,
        addFrontFn: fn (ctx: ?*anyopaque, val: T) void,
        removeBackFn: fn (ctx: ?*anyopaque) ?T,
        backFn: fn (ctx: ?*anyopaque) ?T,
        queue: Queue(T),

        pub fn addFront(self: *Self, val: T) void {
            self.addFrontFn(self.context, val);
        }

        pub fn removeBack(self: *Self) ?T {
            return self.removeBackFn(self.context);
        }

        pub fn back(self: *Self) ?T {
            return self.backFn(self.context);
        }
    };
}

test "Deque interface" {
    try std.testing.expect(true); // Placeholder
}
