const std = @import("std");
const ds = @import("../ds/ds.zig");

pub fn GraphNode(comptime T: type) type {
    return struct {
        const Self = @This();

        pub var val: T = undefined;
        pub var parent: ?*Self = null;
        pub var depth: i32 = 0;
        pub var next: ?*Self = null;
        pub var prev: ?*Self = null;
        pub var arc_list: ?*ds.graph.GraphArc(T) = null;
        pub var marked: bool = false;
        pub var visible: bool = true;
        pub var num_arcs: i32 = 0;
        pub var graph: ?*ds.graph.Graph(T) = null;

        pub fn init(val_param: T) *Self {
            const allocator = std.heap.c_allocator;
            const self = allocator.create(Self) catch @panic("failed to create graph node");
            self.* = .{
                .val = val_param,
                .parent = null,
                .depth = 0,
                .next = null,
                .prev = null,
                .arc_list = null,
                .marked = false,
                .visible = true,
                .num_arcs = 0,
                .graph = null,
            };
            return self;
        }

        pub fn deinit(self: *Self) void {
            const allocator = std.heap.c_allocator;
            allocator.destroy(self);
        }
    };
}
