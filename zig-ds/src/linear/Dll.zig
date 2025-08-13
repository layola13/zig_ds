const std = @import("std");
const DllNode = @import("DllNode.zig");
const List = @import("../ds/list.zig").List;
const Collection = @import("../ds/collection.zig").Collection;

pub fn Dll(comptime T: type, allocator: std.mem.Allocator) type {
    return struct {
        const Self = @This();
        const Node = DllNode(T);

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
                new_node.prev = tail_node;
            } else {
                self.head = new_node;
            }
            self.tail = new_node;

            if (self.is_circular) {
                new_node.next = self.head;
                self.head.?.prev = new_node;
            }

            self.size += 1;
        }

        pub fn prepend(self: *Self, val: T) !void {
            var new_node = try allocator.create(Node);
            new_node.* = Node.init(val);

            if (self.head) |head_node| {
                head_node.prev = new_node;
                new_node.next = head_node;
            } else {
                self.tail = new_node;
            }
            self.head = new_node;

            if (self.is_circular) {
                if (self.tail) |tail_node| {
                    tail_node.next = self.head;
                    self.head.?.prev = tail_node;
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
                if (current == self.head) break;
            }
            self.head = null;
            self.tail = null;
            self.size = 0;
        }
    };
}

test "Dll" {
    var list = Dll(i32, std.testing.allocator).init();
    defer list.deinit();

    try list.append(10);
    try list.append(20);
    try list.prepend(0);

    try std.testing.expectEqual(@as(usize, 3), list.size);
    try std.testing.expectEqual(@as(i32, 0), list.head.?.val);
    try std.testing.expectEqual(@as(i32, 20), list.tail.?.val);
    try std.testing.expectEqual(@as(i32, 10), list.head.?.next.?.val);
    try std.testing.expectEqual(@as(i32, 10), list.tail.?.prev.?.val);
}
