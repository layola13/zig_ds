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
    };
}

test "ArrayedDeque" {
    var deque = try ArrayedDeque(i32, std.testing.allocator).init(4);
    defer deque.deinit();

    try deque.pushFront(10);
    try deque.pushFront(20);
    try deque.pushBack(30);
    try deque.pushBack(40);

    try std.testing.expectEqual(@as(usize, 4), deque.size());
    try std.testing.expectEqual(@as(i32, 20), deque.popFront().?);
    try std.testing.expectEqual(@as(i32, 40), deque.popBack().?);
    try std.testing.expectEqual(@as(usize, 2), deque.size());
}
