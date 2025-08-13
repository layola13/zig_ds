const std = @import("std");
const ds = @import("../ds/ds.zig");

pub fn GraphArc(comptime T: type) type {
    return struct {
        const Self = @This();

        pub var node: *ds.graph.GraphNode(T) = undefined;
        pub var weight: f32 = 0;
        pub var next: ?*Self = null;
        pub var prev: ?*Self = null;

        pub fn init(node_param: *ds.graph.GraphNode(T), weight_param: f32) *Self {
            const allocator = std.heap.c_allocator;
            const self = allocator.create(Self) catch @panic("failed to create graph arc");
            self.* = .{
                .node = node_param,
                .weight = weight_param,
                .next = null,
                .prev = null,
            };
            return self;
        }

        pub fn deinit(self: *Self) void {
            const allocator = std.heap.c_allocator;
            allocator.destroy(self);
        }
    };
}
