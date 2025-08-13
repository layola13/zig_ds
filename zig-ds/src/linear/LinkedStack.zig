const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

pub const LinkedStackNode = @import("SllNode.zig").SllNode;

pub fn LinkedStack(comptime T: type) type {
    return struct {
        const Self = @This();
        const Node = LinkedStackNode(T);

        head: ?*Node = null,
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

        pub fn push(self: *Self, value: T) !void {
            const node = try self.allocator.create(Node);
            node.* = .{ .data = value, .next = self.head };
            self.head = node;
            self.len += 1;
        }

        pub fn pop(self: *Self) ?T {
            if (self.head) |head| {
                const value = head.data;
                self.head = head.next;
                self.allocator.destroy(head);
                self.len -= 1;
                return value;
            }
            return null;
        }

        pub fn top(self: *const Self) ?*const T {
            if (self.head) |head| {
                return &head.data;
            }
            return null;
        }

        pub fn clear(self: *Self) void {
            while (self.pop() != null) {}
        }

        pub fn count(self: *const Self) usize {
            return self.len;
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.len == 0;
        }
    };
}

test "basic linked stack" {
    var stack = LinkedStack(i32).init(std.testing.allocator);
    defer stack.deinit();

    try std.testing.expect(stack.isEmpty());
    try std.testing.expectEqual(@as(usize, 0), stack.count());

    try stack.push(10);
    try std.testing.expect(!stack.isEmpty());
    try std.testing.expectEqual(@as(usize, 1), stack.count());
    try std.testing.expectEqual(@as(i32, 10), stack.top().?.*);

    try stack.push(20);
    try std.testing.expectEqual(@as(usize, 2), stack.count());
    try std.testing.expectEqual(@as(i32, 20), stack.top().?.*);

    const val1 = stack.pop();
    try std.testing.expectEqual(@as(i32, 20), val1.?);
    try std.testing.expectEqual(@as(usize, 1), stack.count());
    try std.testing.expectEqual(@as(i32, 10), stack.top().?.*);

    const val2 = stack.pop();
    try std.testing.expectEqual(@as(i32, 10), val2.?);
    try std.testing.expectEqual(@as(usize, 0), stack.count());
    try std.testing.expect(stack.isEmpty());

    const val3 = stack.pop();
    try std.testing.expect(val3 == null);
}

test "linked stack clear" {
    var stack = LinkedStack(i32).init(std.testing.allocator);
    defer stack.deinit();

    try stack.push(1);
    try stack.push(2);
    try stack.push(3);
    try std.testing.expectEqual(@as(usize, 3), stack.count());

    stack.clear();
    try std.testing.expectEqual(@as(usize, 0), stack.count());
    try std.testing.expect(stack.isEmpty());
    try std.testing.expect(stack.pop() == null);
}
