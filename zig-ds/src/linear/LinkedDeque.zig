const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

pub const LinkedDequeNode = @import("DllNode.zig").DllNode;

pub fn LinkedDeque(comptime T: type) type {
    return struct {
        const Self = @This();
        const Node = LinkedDequeNode(T);

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

        pub fn pushFront(self: *Self, value: T) !void {
            const node = try self.allocator.create(Node);
            node.* = .{ .data = value, .prev = null, .next = self.head };

            if (self.head) |head| {
                head.prev = node;
            } else {
                self.tail = node;
            }
            self.head = node;
            self.len += 1;
        }

        pub fn popFront(self: *Self) ?T {
            if (self.head) |head| {
                const value = head.data;
                self.head = head.next;
                if (self.head) |new_head| {
                    new_head.prev = null;
                } else {
                    self.tail = null;
                }
                self.allocator.destroy(head);
                self.len -= 1;
                return value;
            }
            return null;
        }

        pub fn pushBack(self: *Self, value: T) !void {
            const node = try self.allocator.create(Node);
            node.* = .{ .data = value, .prev = self.tail, .next = null };

            if (self.tail) |tail| {
                tail.next = node;
            } else {
                self.head = node;
            }
            self.tail = node;
            self.len += 1;
        }

        pub fn popBack(self: *Self) ?T {
            if (self.tail) |tail| {
                const value = tail.data;
                self.tail = tail.prev;
                if (self.tail) |new_tail| {
                    new_tail.next = null;
                } else {
                    self.head = null;
                }
                self.allocator.destroy(tail);
                self.len -= 1;
                return value;
            }
            return null;
        }

        pub fn front(self: *const Self) ?*const T {
            if (self.head) |head| {
                return &head.data;
            }
            return null;
        }

        pub fn back(self: *const Self) ?*const T {
            if (self.tail) |tail| {
                return &tail.data;
            }
            return null;
        }

        pub fn clear(self: *Self) void {
            while (self.popFront() != null) {}
        }

        pub fn count(self: *const Self) usize {
            return self.len;
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.len == 0;
        }
    };
}

test "basic linked deque" {
    var deque = LinkedDeque(i32).init(std.testing.allocator);
    defer deque.deinit();

    try std.testing.expect(deque.isEmpty());
    try std.testing.expectEqual(@as(usize, 0), deque.count());

    // push front
    try deque.pushFront(10);
    try std.testing.expect(!deque.isEmpty());
    try std.testing.expectEqual(@as(usize, 1), deque.count());
    try std.testing.expectEqual(@as(i32, 10), deque.front().?.*);
    try std.testing.expectEqual(@as(i32, 10), deque.back().?.*);

    // push front again
    try deque.pushFront(20);
    try std.testing.expectEqual(@as(usize, 2), deque.count());
    try std.testing.expectEqual(@as(i32, 20), deque.front().?.*);
    try std.testing.expectEqual(@as(i32, 10), deque.back().?.*);

    // push back
    try deque.pushBack(30);
    try std.testing.expectEqual(@as(usize, 3), deque.count());
    try std.testing.expectEqual(@as(i32, 20), deque.front().?.*);
    try std.testing.expectEqual(@as(i32, 30), deque.back().?.*);

    // pop front
    const val1 = deque.popFront();
    try std.testing.expectEqual(@as(i32, 20), val1.?);
    try std.testing.expectEqual(@as(usize, 2), deque.count());
    try std.testing.expectEqual(@as(i32, 10), deque.front().?.*);
    try std.testing.expectEqual(@as(i32, 30), deque.back().?.*);

    // pop back
    const val2 = deque.popBack();
    try std.testing.expectEqual(@as(i32, 30), val2.?);
    try std.testing.expectEqual(@as(usize, 1), deque.count());
    try std.testing.expectEqual(@as(i32, 10), deque.front().?.*);
    try std.testing.expectEqual(@as(i32, 10), deque.back().?.*);

    // pop remaining
    const val3 = deque.popFront();
    try std.testing.expectEqual(@as(i32, 10), val3.?);
    try std.testing.expect(deque.isEmpty());

    // pop from empty
    const val4 = deque.popBack();
    try std.testing.expect(val4 == null);
}

test "linked deque clear" {
    var deque = LinkedDeque(i32).init(std.testing.allocator);
    defer deque.deinit();

    try deque.pushFront(1);
    try deque.pushBack(2);
    try deque.pushFront(3);
    try std.testing.expectEqual(@as(usize, 3), deque.count());

    deque.clear();
    try std.testing.expectEqual(@as(usize, 0), deque.count());
    try std.testing.expect(deque.isEmpty());
    try std.testing.expect(deque.popFront() == null);
    try std.testing.expect(deque.popBack() == null);
}
