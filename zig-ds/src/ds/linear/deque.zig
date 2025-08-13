const std = @import("std");
const Collection = @import("../collection.zig").Collection;

pub fn Deque(comptime T: type) type {
    return struct {
        const Self = @This();

        vtable: *const VTable,
        context: *anyopaque,

        pub const VTable = struct {
            front: fn (self: Self) T,
            pushFront: fn (self: Self, val: T) void,
            popFront: fn (self: Self) T,
            back: fn (self: Self) T,
            pushBack: fn (self: Self, val: T) void,
            popBack: fn (self: Self) T,
            collection: Collection(T).VTable,
        };

        pub fn front(self: Self) T {
            return self.vtable.front(self);
        }

        pub fn pushFront(self: Self, val: T) void {
            self.vtable.pushFront(self, val);
        }

        pub fn popFront(self: Self) T {
            return self.vtable.popFront(self);
        }

        pub fn back(self: Self) T {
            return self.vtable.back(self);
        }

        pub fn pushBack(self: Self, val: T) void {
            self.vtable.pushBack(self, val);
        }

        pub fn popBack(self: Self) T {
            return self.vtable.popBack(self);
        }

        pub fn collection(self: Self) Collection(T) {
            return .{
                .vtable = &self.vtable.collection,
                .context = self.context,
            };
        }
    };
}
