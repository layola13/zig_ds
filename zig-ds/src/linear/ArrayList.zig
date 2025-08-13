const std = @import("std");
const Allocator = std.mem.Allocator;
const core = @import("../core.zig");
const assert = @import("../tools/assert.zig").assert;

pub fn ArrayList(comptime T: type) type {
    return struct {
        const Self = @This();

        // Directly expose the items array and other std.ArrayList fields to be compatible with the test
        items: []T,
        allocator: Allocator,
        capacity: usize,

        // Internal ArrayList from std
        _list: std.ArrayList(T),

        pub fn init(allocator: Allocator) Self {
            var list = std.ArrayList(T).init(allocator);
            return .{
                .items = list.items,
                .allocator = allocator,
                .capacity = list.capacity,
                ._list = list,
            };
        }

        pub fn deinit(self: *Self) void {
            self.items.deinit();
        }

        pub fn len(self: *const Self) usize {
            return self.items.items.len;
        }

        pub fn get(self: *const Self, index: usize) T {
            assert(index < self.len(), "Index out of bounds");
            return self.items.items[index];
        }

        pub fn set(self: *Self, index: usize, value: T) void {
            assert(index < self.len(), "Index out of bounds");
            self.items.items[index] = value;
        }

        pub fn pushBack(self: *Self, value: T) !void {
            try self.items.append(value);
        }

        pub fn append(self: *Self, value: T) !void {
            return self.pushBack(value);
        }

        pub fn appendSlice(self: *Self, slice: []const T) !void {
            try self.items.appendSlice(slice);
        }

        pub fn resize(self: *Self, new_len: usize, value: T) !void {
            const old_len = self.len();
            if (new_len < old_len) {
                self.items.shrinkRetainingCapacity(new_len);
            } else if (new_len > old_len) {
                try self.items.ensureUnusedCapacity(new_len - old_len);
                for (old_len..new_len) |_| {
                    try self.items.append(value);
                }
            }
        }

        pub fn indexOf(self: *Self, value: T) ?usize {
            for (self.items.items, 0..) |item, i| {
                if (item == value) return i;
            }
            return null;
        }

        pub fn lastIndexOf(self: *Self, value: T, start: ?usize) ?usize {
            const length = self.len();
            if (length == 0) return null;

            const s = start orelse length - 1;
            var i = @min(s, length - 1);
            while (true) {
                if (self.items.items[i] == value) return i;
                if (i == 0) break;
                i -= 1;
            }
            return null;
        }

        pub fn initCapacity(allocator: Allocator, capacity: usize) Self {
            return .{
                .items = std.ArrayList(T).initCapacity(allocator, capacity) catch std.ArrayList(T).init(allocator),
                .allocator = allocator,
            };
        }

        pub fn popBack(self: *Self) ?T {
            if (self.len() == 0) return null;
            return self.items.pop();
        }

        pub fn popFront(self: *Self) ?T {
            if (self.len() == 0) return null;
            return self.items.orderedRemove(0);
        }

        pub fn pushFront(self: *Self, value: T) !void {
            try self.items.insert(0, value);
        }

        pub fn removeAt(self: *Self, index: usize) T {
            assert(index < self.len(), "Index out of bounds");
            return self.items.orderedRemove(index);
        }

        pub fn insert(self: *Self, index: usize, value: T) !void {
            assert(index <= self.len(), "Index out of bounds");
            try self.items.insert(index, value);
        }

        pub fn sort(self: *Self, comptime cmp: fn (T, T) std.math.Order) void {
            std.sort.sort(T, self.items.items, {}, cmp);
        }
    };
}

test "ArrayList" {
    var list = ArrayList(i32).init(std.testing.allocator);
    defer list.deinit();

    try list.pushBack(10);
    try list.pushBack(20);

    try std.testing.expectEqual(@as(usize, 2), list.len());
    try std.testing.expectEqual(@as(i32, 10), list.get(0));
    try std.testing.expectEqual(@as(i32, 20), list.get(1));

    try list.pushFront(5);
    try std.testing.expectEqual(@as(usize, 3), list.len());
    try std.testing.expectEqual(@as(i32, 5), list.get(0));
    try std.testing.expectEqual(@as(i32, 10), list.get(1));

    const front = list.popFront();
    try std.testing.expectEqual(@as(i32, 5), front.?);
    try std.testing.expectEqual(@as(usize, 2), list.len());

    try list.insert(1, 15);
    try std.testing.expectEqual(@as(usize, 3), list.len());
    try std.testing.expectEqual(@as(i32, 15), list.get(1));
    try std.testing.expectEqual(@as(i32, 20), list.get(2));

    const removed = list.removeAt(1);
    try std.testing.expectEqual(@as(i32, 15), removed);
    try std.testing.expectEqual(@as(usize, 2), list.len());

    list.sort(std.sort.asc(i32));
    try std.testing.expectEqual(@as(i32, 10), list.get(0));
    try std.testing.expectEqual(@as(i32, 20), list.get(1));
}
