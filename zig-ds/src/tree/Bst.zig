const std = @import("std");
const ds = @import("../ds/ds.zig");

const assert = std.debug.assert;
const Allocator = std.mem.Allocator;

pub fn Bst(comptime T: type) type {
    return struct {
        const Self = @This();
        const Node = ds.BinaryTreeNode(T);

        root: ?*Node,
        allocator: *Allocator,
        size: usize,

        pub fn init(allocator: *Allocator) Self {
            return .{
                .root = null,
                .allocator = allocator,
                .size = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            if (self.root) |root_node| {
                root_node.deinit(self.allocator);
            }
        }

        pub fn insert(self: *Self, val: T) !void {
            const new_node = try Node.init(self.allocator, val);
            if (self.root) |root_node| {
                var current = root_node;
                while (true) {
                    if (val.compare(current.val) == .lt) {
                        if (current.left) |left_child| {
                            current = left_child;
                        } else {
                            current.setLeft(new_node);
                            break;
                        }
                    } else {
                        if (current.right) |right_child| {
                            current = right_child;
                        } else {
                            current.setRight(new_node);
                            break;
                        }
                    }
                }
            } else {
                self.root = new_node;
            }
            self.size += 1;
        }
    };
}

const TestContext = struct {
    val: u32,

    pub fn compare(self: TestContext, other: TestContext) std.math.Order {
        return std.math.order(self.val, other.val);
    }
};

test "Bst" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var bst = Bst(TestContext).init(allocator);
    defer bst.deinit();

    try bst.insert(.{ .val = 5 });
    try bst.insert(.{ .val = 3 });
    try bst.insert(.{ .val = 7 });

    try std.testing.expectEqual(@as(usize, 3), bst.size);
    try std.testing.expectEqual(@as(u32, 5), bst.root.?.val.val);
    try std.testing.expectEqual(@as(u32, 3), bst.root.?.left.?.val.val);
    try std.testing.expectEqual(@as(u32, 7), bst.root.?.right.?.val.val);
}
