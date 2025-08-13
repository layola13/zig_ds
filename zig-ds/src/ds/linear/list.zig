const std = @import("std");
const Collection = @import("../collection.zig").Collection;
const Itr = @import("../itr.zig").Itr;

pub fn List(comptime T: type) type {
    return struct {
        const Self = @This();

        vtable: *const VTable,
        context: *anyopaque,

        pub const VTable = struct {
            get: fn (self: Self, index: i32) T,
            set: fn (self: Self, index: i32, val: T) void,
            add: fn (self: Self, val: T) void,
            insert: fn (self: Self, index: i32, val: T) void,
            removeAt: fn (self: Self, index: i32) T,
            indexOf: fn (self: Self, val: T) i32,
            getRange: fn (self: Self, fromIndex: i32, toIndex: i32) List(T),
            collection: Collection(T).VTable,
        };

        pub fn get(self: Self, index: i32) T {
            return self.vtable.get(self, index);
        }

        pub fn set(self: Self, index: i32, val: T) void {
            self.vtable.set(self, index, val);
        }

        pub fn add(self: Self, val: T) void {
            self.vtable.add(self, val);
        }

        pub fn insert(self: Self, index: i32, val: T) void {
            self.vtable.insert(self, index, val);
        }

        pub fn removeAt(self: Self, index: i32) T {
            return self.vtable.removeAt(self, index);
        }

        pub fn indexOf(self: Self, val: T) i32 {
            return self.vtable.indexOf(self, val);
        }

        pub fn getRange(self: Self, fromIndex: i32, toIndex: i32) List(T) {
            return self.vtable.getRange(self, fromIndex, toIndex);
        }

        pub fn collection(self: Self) Collection(T) {
            return .{
                .vtable = &self.vtable.collection,
                .context = self.context,
            };
        }
    };
}
