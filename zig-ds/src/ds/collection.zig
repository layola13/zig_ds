const std = @import("std");
const Itr = @import("itr.zig").Itr;

/// A generic collection interface.
pub fn Collection(comptime T: type) type {
    return struct {
        const Self = @This();

        context: ?*anyopaque,
        sizeFn: fn (ctx: ?*anyopaque) usize,
        freeFn: fn (ctx: ?*anyopaque) void,
        containsFn: fn (ctx: ?*anyopaque, val: T) bool,
        removeFn: fn (ctx: ?*anyopaque, val: T) bool,
        clearFn: fn (ctx: ?*anyopaque) void,
        iteratorFn: fn (ctx: ?*anyopaque) Itr(T),
        isEmptyFn: fn (ctx: ?*anyopaque) bool,
        toArrayFn: fn (ctx: ?*anyopaque, allocator: std.mem.Allocator) []T,
        cloneFn: fn (ctx: ?*anyopaque, allocator: std.mem.Allocator) Self,

        pub fn size(self: *Self) usize {
            return self.sizeFn(self.context);
        }

        pub fn free(self: *Self) void {
            self.freeFn(self.context);
        }

        pub fn contains(self: *Self, val: T) bool {
            return self.containsFn(self.context, val);
        }

        pub fn remove(self: *Self, val: T) bool {
            return self.removeFn(self.context, val);
        }

        pub fn clear(self: *Self) void {
            self.clearFn(self.context);
        }

        pub fn iterator(self: *Self) Itr(T) {
            return self.iteratorFn(self.context);
        }

        pub fn isEmpty(self: *Self) bool {
            return self.isEmptyFn(self.context);
        }

        pub fn toArray(self: *Self, allocator: std.mem.Allocator) []T {
            return self.toArrayFn(self.context, allocator);
        }

        pub fn clone(self: *Self, allocator: std.mem.Allocator) Self {
            return self.cloneFn(self.context, allocator);
        }
    };
}

test "Collection interface" {
    try std.testing.expect(true); // Placeholder
}
