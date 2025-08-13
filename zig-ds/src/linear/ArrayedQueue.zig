const std = @import("std");
const Queue = @import("../ds/queue.zig").Queue;
const Collection = @import("../ds/collection.zig").Collection;

pub fn ArrayedQueue(comptime T: type, allocator: std.mem.Allocator) type {
    return struct {
        const Self = @This();

        items: []T,
        size: usize,
        front: usize,

        pub fn init(initial_capacity: usize) !Self {
            return .{
                .items = try allocator.alloc(T, initial_capacity),
                .size = 0,
                .front = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            allocator.free(self.items);
        }

        pub fn enqueue(self: *Self, item: T) !void {
            if (self.size == self.items.len) {
                const new_capacity = self.items.len * 2;
                const new_items = try allocator.alloc(T, new_capacity);
                @memcpy(new_items[0..self.size], self.items[self.front..]);
                if (self.front > 0) {
                    @memcpy(new_items[self.items.len - self.front ..], self.items[0..self.front]);
                }
                allocator.free(self.items);
                self.items = new_items;
                self.front = 0;
            }
            const index = (self.front + self.size) % self.items.len;
            self.items[index] = item;
            self.size += 1;
        }

        pub fn dequeue(self: *Self) ?T {
            if (self.size == 0) {
                return null;
            }
            const item = self.items[self.front];
            self.front = (self.front + 1) % self.items.len;
            self.size -= 1;
            return item;
        }

        pub fn peek(self: *const Self) ?T {
            if (self.size == 0) {
                return null;
            }
            return self.items[self.front];
        }
    };
}

test "ArrayedQueue" {
    var queue = try ArrayedQueue(i32, std.testing.allocator).init(4);
    defer queue.deinit();

    try queue.enqueue(10);
    try queue.enqueue(20);
    try queue.enqueue(30);

    try std.testing.expectEqual(@as(usize, 3), queue.size);
    try std.testing.expectEqual(@as(i32, 10), queue.peek().?);

    const dequeued = queue.dequeue();
    try std.testing.expectEqual(@as(i32, 10), dequeued.?);
    try std.testing.expectEqual(@as(usize, 2), queue.size);
    try std.testing.expectEqual(@as(i32, 20), queue.peek().?);
}
