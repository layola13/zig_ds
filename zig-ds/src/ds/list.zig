const std = @import("std");
const Collection = @import("collection.zig").Collection;

/// A generic list interface.
pub fn List(comptime T: type) type {
    return struct {
        const Self = @This();

        context: ?*anyopaque,
        getFn: fn (ctx: ?*anyopaque, i: usize) ?T,
        setFn: fn (ctx: ?*anyopaque, i: usize, val: T) ?T,
        indexOfFn: fn (ctx: ?*anyopaque, val: T) ?usize,
        insertAtFn: fn (ctx: ?*anyopaque, i: usize, val: T) void,
        removeAtFn: fn (ctx: ?*anyopaque, i: usize) ?T,
        collection: Collection(T),

        pub fn get(self: *Self, i: usize) ?T {
            return self.getFn(self.context, i);
        }

        pub fn set(self: *Self, i: usize, val: T) ?T {
            return self.setFn(self.context, i, val);
        }

        pub fn indexOf(self: *Self, val: T) ?usize {
            return self.indexOfFn(self.context, val);
        }

        pub fn insertAt(self: *Self, i: usize, val: T) void {
            self.insertAtFn(self.context, i, val);
        }

        pub fn removeAt(self: *Self, i: usize) ?T {
            return self.removeAtFn(self.context, i);
        }
    };
}

test "List interface" {
    try std.testing.expect(true); // Placeholder
}
