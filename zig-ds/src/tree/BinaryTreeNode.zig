const std = @import("std");
const ds = @import("../ds/ds.zig");

const assert = std.debug.assert;
const Allocator = std.mem.Allocator;

pub fn BinaryTreeNode(comptime T: type) type {
    return struct {
        const Self = @This();

        val: T,
        parent: ?*Self,
        left: ?*Self,
        right: ?*Self,

        pub fn init(allocator: *Allocator, val: T) !*Self {
            const self = try allocator.create(Self);
            self.* = .{
                .val = val,
                .parent = null,
                .left = null,
                .right = null,
            };
            return self;
        }

        pub fn deinit(self: *Self, allocator: *Allocator) void {
            if (self.left) |left_child| {
                left_child.deinit(allocator);
            }
            if (self.right) |right_child| {
                right_child.deinit(allocator);
            }
            allocator.destroy(self);
        }

        pub fn setLeft(self: *Self, child: *Self) void {
            self.left = child;
            child.parent = self;
        }

        pub fn setRight(self: *Self, child: *Self) void {
            self.right = child;
            child.parent = self;
        }
    };
}

test "BinaryTreeNode" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var root = try BinaryTreeNode(u32).init(allocator, 0);
    defer root.deinit(allocator);

    const child1 = try BinaryTreeNode(u32).init(allocator, 1);
    const child2 = try BinaryTreeNode(u32).init(allocator, 2);

    root.setLeft(child1);
    root.setRight(child2);

    try std.testing.expectEqual(@as(?*BinaryTreeNode(u32), child1), root.left);
    try std.testing.expectEqual(@as(?*BinaryTreeNode(u32), child2), root.right);
}
