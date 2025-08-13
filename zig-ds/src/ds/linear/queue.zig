const std = @import("std");
const Collection = @import("../collection.zig").Collection;

pub fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();

        vtable: *const VTable,
        context: *anyopaque,

        pub const VTable = struct {
            enqueue: fn (self: Self, val: T) void,
            dequeue: fn (self: Self) T,
            peek: fn (self: Self) T,
            back: fn (self: Self) T,
            collection: Collection(T).VTable,
        };

        pub fn enqueue(self: Self, val: T) void {
            self.vtable.enqueue(self, val);
        }

        pub fn dequeue(self: Self) T {
            return self.vtable.dequeue(self);
        }

        pub fn peek(self: Self) T {
            return self.vtable.peek(self);
        }

        pub fn back(self: Self) T {
            return self.vtable.back(self);
        }

        pub fn collection(self: Self) Collection(T) {
            return .{
                .vtable = &self.vtable.collection,
                .context = self.context,
            };
        }
    };
}
