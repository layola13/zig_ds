const std = @import("std");
const ds = @import("../ds/ds.zig");

const assert = std.debug.assert;
const Allocator = std.mem.Allocator;

pub fn TreeNode(comptime T: type) type {
    return struct {
        const Self = @This();

        val: T,
        parent: ?*Self,
        children: ?*Self,
        prev: ?*Self,
        next: ?*Self,

        pub fn init(allocator: *Allocator, val: T) !*Self {
            const self = try allocator.create(Self);
            self.* = .{
                .val = val,
                .parent = null,
                .children = null,
                .prev = null,
                .next = null,
            };
            return self;
        }

        pub fn deinit(self: *Self, allocator: *Allocator) void {
            var child = self.children;
            while (child) |c| {
                const next = c.next;
                c.deinit(allocator);
                child = next;
            }
            allocator.destroy(self);
        }

        pub fn append(self: *Self, child: *Self) void {
            child.parent = self;
            if (self.children) |last_child| {
                var current = last_child;
                while (current.next) |next_child| {
                    current = next_child;
                }
                current.next = child;
                child.prev = current;
            } else {
                self.children = child;
            }
        }
    };
}

test "TreeNode" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var root = try TreeNode(u32).init(allocator, 0);
    defer root.deinit(allocator);

    const child1 = try TreeNode(u32).init(allocator, 1);
    const child2 = try TreeNode(u32).init(allocator, 2);

    root.append(child1);
    root.append(child2);

    try std.testing.expectEqual(@as(?*TreeNode(u32), child1), root.children);
    try std.testing.expectEqual(@as(?*TreeNode(u32), child2), child1.next);
}
