const std = @import("std");
const SllNode = @import("SllNode.zig");
const List = @import("../ds/list.zig").List;
const Collection = @import("../ds/collection.zig").Collection;

pub fn Sll(comptime T: type, allocator: std.mem.Allocator) type {
    return struct {
        const Self = @This();
        const Node = SllNode(T);

        head: ?*Node,
        tail: ?*Node,
        size: usize,
        is_circular: bool,

        pub fn init() Self {
            return .{
                .head = null,
                .tail = null,
                .size = 0,
                .is_circular = false,
            };
        }

        pub fn deinit(self: *Self) void {
            self.clear();
        }

        pub fn append(self: *Self, val: T) !void {
            var new_node = try allocator.create(Node);
            new_node.* = Node.init(val);

            if (self.tail) |tail_node| {
                tail_node.next = new_node;
            } else {
                self.head = new_node;
            }
            self.tail = new_node;

            if (self.is_circular) {
                new_node.next = self.head;
            }

            self.size += 1;
        }

        pub fn prepend(self: *Self, val: T) !void {
            var new_node = try allocator.create(Node);
            new_node.* = Node.init(val);

            if (self.head) |head_node| {
                new_node.next = head_node;
            } else {
                self.tail = new_node;
            }
            self.head = new_node;

            if (self.is_circular) {
                if (self.tail) |tail_node| {
                    tail_node.next = self.head;
                }
            }

            self.size += 1;
        }

        pub fn clear(self: *Self) void {
            var current = self.head;
            while (current) |node| {
                const next = node.next;
                allocator.destroy(node);
                current = next;
                if (current == self.head) break; // Avoid infinite loop in circular list
            }
            self.head = null;
            self.tail = null;
            self.size = 0;
        }

        pub fn removeHead(self: *Self) ?T {
            if (self.head) |head_node| {
                const val = head_node.val;
                self.head = head_node.next;
                if (self.head == null) {
                    self.tail = null;
                }
                allocator.destroy(head_node);
                self.size -= 1;
                return val;
            }
            return null;
        }

        pub fn removeTail(self: *Self) ?T {
            if (self.tail) |tail_node| {
                const val = tail_node.val;
                if (self.head == self.tail) {
                    allocator.destroy(tail_node);
                    self.head = null;
                    self.tail = null;
                    self.size = 0;
                    return val;
                }

                var current = self.head;
                while (current) |node| {
                    if (node.next == self.tail) {
                        node.next = null;
                        self.tail = node;
                        allocator.destroy(tail_node);
                        self.size -= 1;
                        return val;
                    }
                    current = node.next;
                }
            }
            return null;
        }

        pub fn get(self: *Self, index: usize) ?T {
            if (index >= self.size) return null;
            var current = self.head;
            var i: usize = 0;
            while (current) |node| {
                if (i == index) {
                    return node.val;
                }
                current = node.next;
                i += 1;
            }
            return null;
        }

        pub fn set(self: *Self, index: usize, val: T) void {
            if (index >= self.size) return;
            var current = self.head;
            var i: usize = 0;
            while (current) |node| {
                if (i == index) {
                    node.val = val;
                    return;
                }
                current = node.next;
                i += 1;
            }
        }

        pub fn indexOf(self: *Self, val: T) ?usize {
            var current = self.head;
            var i: usize = 0;
            while (current) |node| {
                if (std.meta.eql(node.val, val)) {
                    return i;
                }
                current = node.next;
                i += 1;
            }
            return null;
        }

        pub fn insertAt(self: *Self, index: usize, val: T) !void {
            if (index > self.size) return;
            if (index == 0) {
                return self.prepend(val);
            }
            if (index == self.size) {
                return self.append(val);
            }

            var current = self.head;
            var i: usize = 0;
            while (current) |node| {
                if (i == index - 1) {
                    var new_node = try allocator.create(Node);
                    new_node.* = Node.init(val);
                    new_node.next = node.next;
                    node.next = new_node;
                    self.size += 1;
                    return;
                }
                current = node.next;
                i += 1;
            }
        }

        pub fn removeAt(self: *Self, index: usize) ?T {
            if (index >= self.size) return null;
            if (index == 0) {
                return self.removeHead();
            }
            if (index == self.size - 1) {
                return self.removeTail();
            }

            var current = self.head;
            var i: usize = 0;
            while (current) |node| {
                if (i == index - 1) {
                    const to_remove = node.next.?;
                    const val = to_remove.val;
                    node.next = to_remove.next;
                    allocator.destroy(to_remove);
                    self.size -= 1;
                    return val;
                }
                current = node.next;
                i += 1;
            }
            return null;
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.size == 0;
        }

        pub fn contains(self: *const Self, val: T) bool {
            return self.indexOf(val) != null;
        }

        pub fn remove(self: *Self, val: T) bool {
            var removed = false;
            var current = self.head;
            var prev: ?*Node = null;
            while (current) |node| {
                if (std.meta.eql(node.val, val)) {
                    if (prev) |prev_node| {
                        prev_node.next = node.next;
                        if (node.next == null) {
                            self.tail = prev_node;
                        }
                    } else {
                        self.head = node.next;
                        if (node.next == null) {
                            self.tail = null;
                        }
                    }
                    allocator.destroy(node);
                    self.size -= 1;
                    removed = true;
                    current = if (prev) prev.?.next else self.head;
                } else {
                    prev = node;
                    current = node.next;
                }
            }
            return removed;
        }

        pub fn toArray(self: *const Self, a: std.mem.Allocator) ![]T {
            const arr = try a.alloc(T, self.size);
            var current = self.head;
            var i: usize = 0;
            while (current) |node| {
                arr[i] = node.val;
                current = node.next;
                i += 1;
            }
            return arr;
        }
    };
}

test "Sll" {
    var list = Sll(i32, std.testing.allocator).init();
    defer list.deinit();

    try list.append(10);
    try list.append(20);
    try list.prepend(0);

    try std.testing.expectEqual(@as(usize, 3), list.size);
    try std.testing.expectEqual(@as(i32, 0), list.head.?.val);
    try std.testing.expectEqual(@as(i32, 20), list.tail.?.val);

    const removed_head = list.removeHead();
    try std.testing.expectEqual(@as(i32, 0), removed_head.?);
    try std.testing.expectEqual(@as(usize, 2), list.size);
    try std.testing.expectEqual(@as(i32, 10), list.head.?.val);

    const removed_tail = list.removeTail();
    try std.testing.expectEqual(@as(i32, 20), removed_tail.?);
    try std.testing.expectEqual(@as(usize, 1), list.size);
    try std.testing.expectEqual(@as(i32, 10), list.tail.?.val);

    list.clear();
    try list.append(0);
    try list.append(1);
    try list.append(2);

    try std.testing.expectEqual(@as(i32, 1), list.get(1).?);
    list.set(1, 100);
    try std.testing.expectEqual(@as(i32, 100), list.get(1).?);
    try std.testing.expectEqual(@as(usize, 1), list.indexOf(100).?);

    try list.insertAt(1, 50);
    try std.testing.expectEqual(@as(i32, 50), list.get(1).?);
    try std.testing.expectEqual(@as(usize, 4), list.size);

    const removed_at = list.removeAt(1);
    try std.testing.expectEqual(@as(i32, 50), removed_at.?);
    try std.testing.expectEqual(@as(usize, 3), list.size);

    try std.testing.expect(list.contains(100));
    try std.testing.expect(!list.contains(50));
    try std.testing.expect(!list.isEmpty());
    list.clear();
    try std.testing.expect(list.isEmpty());

    try list.append(10);
    try list.append(20);
    try list.append(10);
    try list.append(30);
    try std.testing.expect(list.remove(10));
    try std.testing.expectEqual(@as(usize, 2), list.size);
    try std.testing.expectEqual(@as(i32, 20), list.head.?.val);
    try std.testing.expectEqual(@as(i32, 30), list.tail.?.val);

    const arr = try list.toArray(std.testing.allocator);
    defer std.testing.allocator.free(arr);
    try std.testing.expectEqualSlices(i32, &.{ 20, 30 }, arr);
}
