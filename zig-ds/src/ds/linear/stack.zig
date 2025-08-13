const std = @import("std");
const Collection = @import("../collection.zig").Collection;

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        vtable: *const VTable,
        context: *anyopaque,

        pub const VTable = struct {
            push: fn (self: Self, val: T) void,
            pop: fn (self: Self) T,
            top: fn (self: Self) T,
            collection: Collection(T).VTable,
        };

        pub fn push(self: Self, val: T) void {
            self.vtable.push(self, val);
        }

        pub fn pop(self: Self) T {
            return self.vtable.pop(self);
        }

        pub fn top(self: Self) T {
            return self.vtable.top(self);
        }

        pub fn collection(self: Self) Collection(T) {
            return .{
                .vtable = &self.vtable.collection,
                .context = self.context,
            };
        }
    };
}
