const std = @import("std");
const Allocator = std.mem.Allocator;
const core = @import("../core.zig");
const assert = @import("../tools/assert.zig").assert;

pub fn ArrayList(comptime T: type) type {
    return struct {
        const Self = @This();

        // Internal ArrayList from std
        _list: std.ArrayList(T),

        pub fn init(allocator: Allocator) Self {
            return .{
                ._list = std.ArrayList(T).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self._list.deinit();
        }

        pub fn len(self: *const Self) usize {
            return self._list.items.len;
        }

        pub fn capacity(self: *const Self) usize {
            return self._list.capacity;
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.len() == 0;
        }

        pub fn front(self: *const Self) ?T {
            if (self.isEmpty()) return null;
            return self._list.items[0];
        }

        pub fn back(self: *const Self) ?T {
            if (self.isEmpty()) return null;
            return self._list.items[self.len() - 1];
        }

        pub fn get(self: *const Self, index: usize) T {
            assert(index < self.len(), "Index out of bounds");
            return self._list.items[index];
        }

        pub fn set(self: *Self, index: usize, value: T) void {
            assert(index < self.len(), "Index out of bounds");
            self._list.items[index] = value;
        }

        pub fn pushBack(self: *Self, value: T) !void {
            try self._list.append(value);
        }

        pub fn append(self: *Self, value: T) !void {
            try self._list.append(value);
        }

        pub fn appendSlice(self: *Self, slice: []const T) !void {
            try self._list.appendSlice(slice);
        }

        pub fn resize(self: *Self, new_len: usize) !void {
            try self._list.resize(new_len);
        }

        pub fn indexOf(self: *const Self, value: T) ?usize {
            // Assuming T is comparable
            for (self._list.items, 0..) |item, i| {
                if (item == value) return i;
            }
            return null;
        }

        pub fn lastIndexOf(self: *const Self, value: T, start: ?usize) ?usize {
            const length = self.len();
            if (length == 0) return null;

            const s = start orelse length - 1;
            var i = @min(s, length - 1);
            while (true) {
                if (self._list.items[i] == value) return i;
                if (i == 0) break;
                i -= 1;
            }
            return null;
        }

        pub fn contains(self: *const Self, value: T) bool {
            return self.indexOf(value) != null;
        }

        pub fn clear(self: *Self) void {
            self._list.clearRetainingCapacity();
        }

        pub fn toArray(self: *const Self) []const T {
            return self._list.items;
        }

        pub fn clone(self: *const Self) !Self {
            const new_list = try self._list.clone();
            return .{ ._list = new_list };
        }

        pub fn reserve(self: *Self, n: usize) !void {
            try self._list.ensureTotalCapacity(n);
        }

        pub fn pack(self: *Self) void {
            self._list.shrink(0);
        }

        pub fn swap(self: *Self, i: usize, j: usize) void {
            assert(i < self.len(), "Index i out of bounds");
            assert(j < self.len(), "Index j out of bounds");
            std.mem.swap(T, &self._list.items[i], &self._list.items[j]);
        }

        pub fn swapPop(self: *Self, index: usize) T {
            assert(index < self.len(), "Index out of bounds");
            return self._list.swapRemove(index);
        }

        pub fn initCapacity(allocator: Allocator, initial_capacity: usize) !Self {
            const list = try std.ArrayList(T).initCapacity(allocator, initial_capacity);
            return .{
                ._list = list,
            };
        }

        pub fn popBack(self: *Self) ?T {
            if (self.len() == 0) return null;
            return self._list.pop();
        }

        pub fn popFront(self: *Self) ?T {
            if (self.len() == 0) return null;
            return self._list.orderedRemove(0);
        }

        pub fn pushFront(self: *Self, value: T) !void {
            try self._list.insert(0, value);
        }

        pub fn removeAt(self: *Self, index: usize) T {
            assert(index < self.len(), "Index out of bounds");
            return self._list.orderedRemove(index);
        }

        pub fn insert(self: *Self, index: usize, value: T) !void {
            assert(index <= self.len(), "Index out of bounds");
            try self._list.insert(index, value);
        }

        pub fn sort(self: *Self, comptime lessThan: fn (context: anytype, lhs: T, rhs: T) bool, context: anytype) void {
            std.sort.sort(T, self._list.items, context, lessThan);
        }

        pub fn iterator(self: *const Self) Iterator {
            return Iterator.init(self);
        }

        pub const Iterator = struct {
            list: *const Self,
            index: usize,

            pub fn init(list: *const Self) @This() {
                return .{
                    .list = list,
                    .index = 0,
                };
            }

            pub fn next(self: *@This()) ?T {
                if (self.index < self.list.len()) {
                    const item = self.list.get(self.index);
                    self.index += 1;
                    return item;
                }
                return null;
            }

            pub fn reset(self: *@This()) void {
                self.index = 0;
            }
        };
    };
}

test "ArrayList" {
    var list = ArrayList(i32).init(std.testing.allocator);
    defer list.deinit();

    try std.testing.expect(list.isEmpty());
    try std.testing.expectEqual(@as(?i32, null), list.front());
    try std.testing.expectEqual(@as(?i32, null), list.back());

    try list.pushBack(10);
    try list.pushBack(20);

    try std.testing.expect(!list.isEmpty());
    try std.testing.expectEqual(@as(usize, 2), list.len());
    try std.testing.expectEqual(@as(i32, 10), list.get(0));
    try std.testing.expectEqual(@as(i32, 20), list.get(1));
    try std.testing.expectEqual(@as(i32, 10), list.front().?);
    try std.testing.expectEqual(@as(i32, 20), list.back().?);

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

    try std.testing.expect(list.contains(10));
    try std.testing.expect(!list.contains(99));

    const arr = list.toArray();
    try std.testing.expectEqualSlices(i32, &.{ 10, 20 }, arr);

    var cloned_list = try list.clone();
    defer cloned_list.deinit();
    try std.testing.expectEqualSlices(i32, list.toArray(), cloned_list.toArray());
    try cloned_list.pushBack(30);
    try std.testing.expect(!std.meta.eql(list.toArray(), cloned_list.toArray()));

    list.clear();
    try std.testing.expect(list.isEmpty());
    try std.testing.expect(list.capacity() > 0);

    try list.pushBack(1);
    try list.pushBack(2);
    try list.pushBack(3);
    list.swap(0, 2);
    try std.testing.expectEqualSlices(i32, &.{ 3, 2, 1 }, list.toArray());

    const popped = list.swapPop(0);
    try std.testing.expectEqual(@as(i32, 3), popped);
    try std.testing.expectEqualSlices(i32, &.{ 1, 2 }, list.toArray());

    try list.reserve(10);
    try std.testing.expect(list.capacity() >= 10);
    list.pack();
    try std.testing.expect(list.capacity() == list.len());

    var it = list.iterator();
    var sum: i32 = 0;
    while (it.next()) |val| {
        sum += val;
    }
    try std.testing.expectEqual(@as(i32, 3), sum);

    it.reset();
    sum = 0;
    while (it.next()) |val| {
        sum += val;
    }
    try std.testing.expectEqual(@as(i32, 3), sum);
}