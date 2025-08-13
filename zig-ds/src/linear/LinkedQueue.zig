const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

pub const LinkedQueueNode = @import("SllNode.zig").SllNode;

pub fn LinkedQueue(comptime T: type) type {
    return struct {
        const Self = @This();
        const Node = LinkedQueueNode(T);

        head: ?*Node = null,
        tail: ?*Node = null,
        allocator: Allocator,
        len: usize = 0,

        pub fn init(allocator: Allocator) Self {
            return Self{
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.clear();
        }

        pub fn enqueue(self: *Self, value: T) !void {
            const node = try self.allocator.create(Node);
            node.* = .{ .data = value, .next = null };

            if (self.tail) |tail| {
                tail.next = node;
                self.tail = node;
            } else {
                self.head = node;
                self.tail = node;
            }
            self.len += 1;
        }

        pub fn dequeue(self: *Self) ?T {
            if (self.head) |head| {
                const value = head.data;
                self.head = head.next;
                if (self.head == null) {
                    self.tail = null;
                }
                self.allocator.destroy(head);
                self.len -= 1;
                return value;
            }
            return null;
        }

        pub fn peek(self: *const Self) ?*const T {
            if (self.head) |head| {
                return &head.data;
            }
            return null;
        }

        pub fn clear(self: *Self) void {
            while (self.dequeue() != null) {}
        }

        pub fn count(self: *const Self) usize {
            return self.len;
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.len == 0;
        }
    };
}

test "basic linked queue" {
    var queue = LinkedQueue(i32).init(std.testing.allocator);
    defer queue.deinit();

    try std.testing.expect(queue.isEmpty());
    try std.testing.expectEqual(@as(usize, 0), queue.count());

    try queue.enqueue(10);
    try std.testing.expect(!queue.isEmpty());
    try std.testing.expectEqual(@as(usize, 1), queue.count());
    try std.testing.expectEqual(@as(i32, 10), queue.peek().?.*);

    try queue.enqueue(20);
    try std.testing.expectEqual(@as(usize, 2), queue.count());
    try std.testing.expectEqual(@as(i32, 10), queue.peek().?.*);

    const val1 = queue.dequeue();
    try std.testing.expectEqual(@as(i32, 10), val1.?);
    try std.testing.expectEqual(@as(usize, 1), queue.count());
    try std.testing.expectEqual(@as(i32, 20), queue.peek().?.*);

    const val2 = queue.dequeue();
    try std.testing.expectEqual(@as(i32, 20), val2.?);
    try std.testing.expectEqual(@as(usize, 0), queue.count());
    try std.testing.expect(queue.isEmpty());

    const val3 = queue.dequeue();
    try std.testing.expect(val3 == null);
}

test "linked queue clear" {
    var queue = LinkedQueue(i32).init(std.testing.allocator);
    defer queue.deinit();

    try queue.enqueue(1);
    try queue.enqueue(2);
    try queue.enqueue(3);
    try std.testing.expectEqual(@as(usize, 3), queue.count());

    queue.clear();
    try std.testing.expectEqual(@as(usize, 0), queue.count());
    try std.testing.expect(queue.isEmpty());
    try std.testing.expect(queue.dequeue() == null);
}
