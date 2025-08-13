const std = @import("std");
const Collection = @import("collection.zig").Collection;

/// A generic stack interface.
pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        context: ?*anyopaque,
        pushFn: fn (ctx: ?*anyopaque, val: T) void,
        popFn: fn (ctx: ?*anyopaque) ?T,
        peekFn: fn (ctx: ?*anyopaque) ?T,
        collection: Collection(T),

        pub fn push(self: *Self, val: T) void {
            self.pushFn(self.context, val);
        }

        pub fn pop(self: *Self) ?T {
            return self.popFn(self.context);
        }

        pub fn peek(self: *Self) ?T {
            return self.peekFn(self.context);
        }
    };
}

test "Stack interface" {
    try std.testing.expect(true); // Placeholder
}
