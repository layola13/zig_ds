const std = @import("std");
const ds = @import("../ds/ds.zig");

pub fn Graph(comptime T: type) type {
    return struct {
        const Self = @This();
        const Node = ds.graph.GraphNode(T);
        const Arc = ds.graph.GraphArc(T);

        var node_list: ?*Node = null;
        var size: i32 = 0;
        var allocator: std.mem.Allocator = undefined;

        pub fn init(allocator_param: std.mem.Allocator) Self {
            return Self{
                .node_list = null,
                .size = 0,
                .allocator = allocator_param,
            };
        }

        pub fn deinit(self: *Self) void {
            var current = self.node_list;
            while (current) |node| {
                const next = node.next;
                self.removeNode(node);
                current = next;
            }
        }

        pub fn addNode(self: *Self, node: *Node) *Node {
            if (node.graph != null) {
                return node;
            }

            self.size += 1;
            node.next = self.node_list;
            if (node.next) |next_node| {
                next_node.prev = node;
            }
            self.node_list = node;
            node.graph = self;
            return node;
        }

        pub fn removeNode(self: *Self, node: *Node) void {
            if (self.size == 0 or node.graph == null) {
                return;
            }

            self.unlink(node);

            if (node.prev) |prev_node| {
                prev_node.next = node.next;
            }
            if (node.next) |next_node| {
                next_node.prev = node.prev;
            }
            if (self.node_list == node) {
                self.node_list = node.next;
            }
            self.size -= 1;
            node.graph = null;
            node.next = null;
            node.prev = null;
            node.deinit();
        }

        pub fn addSingleArc(self: *Self, source: *Node, target: *Node, weight: f32) void {
            var arc = self.allocator.create(Arc) catch @panic("failed to create arc");
            arc.* = Arc.init(target, weight);

            arc.next = source.arc_list;
            if (source.arc_list) |arc_list| {
                arc_list.prev = arc;
            }
            source.arc_list = arc;
            source.num_arcs += 1;
        }

        pub fn addMutualArc(self: *Self, source: *Node, target: *Node, weight: f32) void {
            self.addSingleArc(source, target, weight);
            self.addSingleArc(target, source, weight);
        }

        pub fn unlink(self: *Self, node: *Node) void {
            var current_arc = node.arc_list;
            while (current_arc) |arc| {
                const next_arc = arc.next;
                var other_node = arc.node;

                var other_arc = other_node.arc_list;
                while (other_arc) |oa| {
                    const next_oa = oa.next;
                    if (oa.node == node) {
                        if (oa.prev) |prev_oa| {
                            prev_oa.next = next_oa;
                        }
                        if (next_oa) |next_oa_val| {
                            next_oa_val.prev = oa.prev;
                        }
                        if (other_node.arc_list == oa) {
                            other_node.arc_list = next_oa;
                        }
                        self.allocator.destroy(oa);
                        other_node.num_arcs -= 1;
                    }
                    other_arc = next_oa;
                }

                if (arc.prev) |prev_arc| {
                    prev_arc.next = next_arc;
                }
                if (next_arc) |next_arc_val| {
                    next_arc_val.prev = arc.prev;
                }
                if (node.arc_list == arc) {
                    node.arc_list = next_arc;
                }
                self.allocator.destroy(arc);
                node.num_arcs -= 1;

                current_arc = next_arc;
            }
            node.arc_list = null;
        }
    };
}
