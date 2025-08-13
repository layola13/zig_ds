const std = @import("std");
const ds = @import("../ds/ds.zig");

const assert = std.debug.assert;
const Allocator = std.mem.Allocator;

pub fn TreeBuilder(comptime T: type) type {
    return struct {
        const Self = @This();
        const Node = ds.TreeNode(T);

        allocator: *Allocator,
        node: *Node,
        child: ?*Node,

        pub fn init(allocator: *Allocator, root: *Node) Self {
            return .{
                .allocator = allocator,
                .node = root,
                .child = root.children,
            };
        }

        pub fn append(self: *Self, val: T) !*Node {
            const new_node = try Node.init(self.allocator, val);
            self.node.append(new_node);
            self.child = new_node;
            return new_node;
        }

        pub fn down(self: *Self) bool {
            if (self.child) |child_node| {
                self.node = child_node;
                self.child = self.node.children;
                return true;
            }
            return false;
        }

        pub fn up(self: *Self) bool {
            if (self.node.parent) |parent_node| {
                self.node = parent_node;
                self.child = self.node.children;
                return true;
            }
            return false;
        }
    };
}

test "TreeBuilder" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var root = try ds.TreeNode(u32).init(allocator, 0);
    defer root.deinit(allocator);

    var builder = TreeBuilder(u32).init(allocator, root);
    _ = try builder.append(1);
    _ = builder.down();
    _ = try builder.append(2);

    try std.testing.expectEqual(@as(u32, 0), root.val);
    try std.testing.expectEqual(@as(u32, 1), root.children.?.val);
    try std.testing.expectEqual(@as(u32, 2), root.children.?.children.?.val);
}
