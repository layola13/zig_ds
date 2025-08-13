const std = @import("std");
const Deque = @import("../ds/deque.zig").Deque;
const Collection = @import("../ds/collection.zig").Collection;

pub fn ArrayedDeque(comptime T: type, allocator: std.mem.Allocator) type {
    return struct {
        const Self = @This();

        blocks: std.ArrayList([]T),
        head: usize,
        tail: usize,
        block_size: usize,

        pub fn init(block_size: usize) !Self {
            var self = Self{
                .blocks = std.ArrayList([]T).init(allocator),
                .head = 0,
                .tail = 1,
                .block_size = block_size,
            };
            try self.blocks.append(try allocator.alloc(T, block_size));
            return self;
        }

        pub fn deinit(self: *Self) void {
            for (self.blocks.items) |block| {
                allocator.free(block);
            }
            self.blocks.deinit();
        }

        pub fn pushFront(self: *Self, item: T) !void {
            if (self.head == 0) {
                try self.blocks.insert(0, try allocator.alloc(T, self.block_size));
                self.head = self.block_size;
            }
            self.head -= 1;
            self.blocks.items[0][self.head] = item;
        }

        pub fn popFront(self: *Self) ?T {
            if (self.size() == 0) return null;

            const item = self.blocks.items[0][self.head];
            self.head += 1;
            if (self.head == self.block_size) {
                allocator.free(self.blocks.orderedRemove(0));
                self.head = 0;
            }
            return item;
        }

        pub fn pushBack(self: *Self, item: T) !void {
            if (self.tail == self.block_size) {
                try self.blocks.append(try allocator.alloc(T, self.block_size));
                self.tail = 0;
            }
            self.blocks.items[self.blocks.items.len - 1][self.tail] = item;
            self.tail += 1;
        }

        pub fn popBack(self: *Self) ?T {
            if (self.size() == 0) return null;

            if (self.tail == 0) {
                allocator.free(self.blocks.pop());
                self.tail = self.block_size;
            }
            self.tail -= 1;
            return self.blocks.items[self.blocks.items.len - 1][self.tail];
        }

        pub fn size(self: *const Self) usize {
            if (self.blocks.items.len == 0) return 0;
            if (self.blocks.items.len == 1) return self.tail - self.head - 1;
            return (self.block_size - self.head - 1) + ((self.blocks.items.len - 2) * self.block_size) + self.tail;
        }

        pub fn front(self: *const Self) ?T {
            if (self.size() == 0) return null;
            return self.blocks.items[0][self.head];
        }

        pub fn back(self: *const Self) ?T {
            if (self.size() == 0) return null;
            if (self.tail == 0) {
                return self.blocks.items[self.blocks.items.len - 2][self.block_size - 1];
            }
            return self.blocks.items[self.blocks.items.len - 1][self.tail - 1];
        }

        pub fn getFront(self: *const Self, i: usize) ?T {
            if (i >= self.size()) return null;
            const c = self.head + 1 + i;
            const b = c / self.block_size;
            return self.blocks.items[b][c % self.block_size];
        }

        pub fn getBack(self: *const Self, i: usize) ?T {
            if (i >= self.size()) return null;
            const s = self.size();
            return self.getFront(s - 1 - i);
        }

        pub fn contains(self: *const Self, val: T) bool {
            for (0..self.size()) |i| {
                if (self.getFront(i).? == val) {
                    return true;
                }
            }
            return false;
        }

        pub fn indexOfFront(self: *const Self, val: T) ?usize {
            for (0..self.size()) |i| {
                if (self.getFront(i).? == val) {
                    return i;
                }
            }
            return null;
        }

        pub fn iterator(self: *const Self) Iterator {
            return .{ .deque = self, .index = 0 };
        }

        pub const Iterator = struct {
            deque: *const Self,
            index: usize,

            pub fn next(it: *Iterator) ?T {
                if (it.index >= it.deque.size()) {
                    return null;
                }
                const item = it.deque.getFront(it.index);
                it.index += 1;
                return item;
            }
        };

        pub fn isEmpty(self: *const Self) bool {
            return self.size() == 0;
        }

        pub fn clear(self: *Self) void {
            for (self.blocks.items) |block| {
                self.allocator.free(block);
            }
            self.blocks.clearRetainingCapacity();
            self.blocks.append(self.allocator.alloc(T, self.block_size) catch @panic("oom")) catch @panic("oom");
            self.head = 0;
            self.tail = 1;
        }

        pub fn toArray(self: *const Self, a: std.mem.Allocator) ![]T {
            const array = try a.alloc(T, self.size());
            var i: usize = 0;
            var it = self.iterator();
            while (it.next()) |item| {
                array[i] = item;
                i += 1;
            }
            return array;
        }
        pub fn remove(self: *Self, val: T) bool {
            const index = self.indexOfFront(val);
            if (index) |i| {
                _ = self.removeAt(i);
                return true;
            }
            return false;
        }

        pub fn removeAt(self: *Self, i: usize) ?T {
            if (i >= self.size()) return null;

            const item = self.getFront(i).?;
            for (i..self.size() - 1) |j| {
                self.set(j, self.getFront(j + 1).?);
            }
            _ = self.popBack();
            return item;
        }

        fn set(self: *Self, i: usize, val: T) void {
            if (i >= self.size()) return;
            const c = self.head + 1 + i;
            const b = c / self.block_size;
            self.blocks.items[b][c % self.block_size] = val;
        }

        pub fn clone(self: *const Self, a: std.mem.Allocator) !Self {
            var new_deque = try Self.init(self.block_size);
            try new_deque.blocks.ensureTotalCapacity(self.blocks.items.len);
            for (self.blocks.items) |block| {
                const new_block = try a.alloc(T, self.block_size);
                @memcpy(new_block, block);
                try new_deque.blocks.append(new_block);
            }
            new_deque.head = self.head;
            new_deque.tail = self.tail;
            return new_deque;
        }
    };
}

comptime {
    _ = @import("std").testing.refAllDecls(@This());
}

test "ArrayedDeque" {
    var deque = try ArrayedDeque(i32, std.testing.allocator).init(4);
    defer deque.deinit();

    try deque.pushFront(10);
    try deque.pushFront(20);
    try deque.pushBack(30);
    try deque.pushBack(40);

    try std.testing.expectEqual(@as(usize, 4), deque.size());
    try std.testing.expectEqual(@as(i32, 20), deque.front().?);
    try std.testing.expectEqual(@as(i32, 40), deque.back().?);
    try std.testing.expectEqual(@as(i32, 20), deque.popFront().?);
    try std.testing.expectEqual(@as(i32, 40), deque.popBack().?);
    try std.testing.expectEqual(@as(usize, 2), deque.size());
    try std.testing.expectEqual(@as(i32, 10), deque.front().?);
    try std.testing.expectEqual(@as(i32, 30), deque.back().?);

    try std.testing.expectEqual(@as(i32, 10), deque.getFront(0).?);
    try std.testing.expectEqual(@as(i32, 30), deque.getFront(1).?);
    try std.testing.expectEqual(null, deque.getFront(2));

    try std.testing.expectEqual(@as(i32, 30), deque.getBack(0).?);
    try std.testing.expectEqual(@as(i32, 10), deque.getBack(1).?);
    try std.testing.expectEqual(null, deque.getBack(2));

    try std.testing.expect(deque.contains(10));
    try std.testing.expect(deque.contains(30));
    try std.testing.expect(!deque.contains(20));
    try std.testing.expect(!deque.contains(40));

    try std.testing.expectEqual(@as(usize, 0), deque.indexOfFront(10).?);
    try std.testing.expectEqual(@as(usize, 1), deque.indexOfFront(30).?);
    try std.testing.expectEqual(null, deque.indexOfFront(20));

    var it = deque.iterator();
    try std.testing.expectEqual(@as(i32, 10), it.next().?);
    try std.testing.expectEqual(@as(i32, 30), it.next().?);
    try std.testing.expectEqual(null, it.next());

    try std.testing.expect(!deque.isEmpty());
    deque.clear();
    try std.testing.expect(deque.isEmpty());
    try std.testing.expectEqual(@as(usize, 0), deque.size());

    try deque.pushBack(100);
    try deque.pushBack(200);
    const array = try deque.toArray(std.testing.allocator);
    defer std.testing.allocator.free(array);
    try std.testing.expectEqualSlices(i32, &.{ 100, 200 }, array);

    try deque.pushFront(50);
    try std.testing.expect(deque.remove(100));
    try std.testing.expectEqual(@as(usize, 2), deque.size());
    try std.testing.expectEqual(@as(i32, 50), deque.getFront(0).?);
    try std.testing.expectEqual(@as(i32, 200), deque.getFront(1).?);
    _ = deque.removeAt(0);
    try std.testing.expectEqual(@as(usize, 1), deque.size());
    try std.testing.expectEqual(@as(i32, 200), deque.front().?);

    const cloned = try deque.clone(std.testing.allocator);
    defer cloned.deinit();
    try std.testing.expectEqualSlices(i32, &.{200}, try cloned.toArray(std.testing.allocator));
}
