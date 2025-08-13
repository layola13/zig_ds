const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

/// Defines the requirements for a type to be storable in a PriorityQueue.
/// It must have a `position: usize` field and a `priority: f64` field.
pub fn isPrioritizable(comptime T: type) bool {
    return @hasField(T, "position") and
        comptime mem.eql(u8, @typeName(@TypeOf(@field(T, "position"))), "usize") and
            @hasField(T, "priority") and
            @TypeOf(@field(T, "priority")) == f64;
}

pub fn PriorityQueue(comptime T: type, comptime inverse: bool) type {
    if (!isPrioritizable(T)) {
        @compileError("Type " ++ @typeName(T) ++ " does not meet Prioritizable requirements.");
    }

    return struct {
        const Self = @This();

        items: std.ArrayList(?T),

        pub fn init(allocator: Allocator) !Self {
            var list = std.ArrayList(?T).init(allocator);
            try list.append(null); // Reserve index 0
            return Self{
                .items = list,
            };
        }

        pub fn deinit(self: *Self) void {
            self.items.deinit();
        }

        pub fn count(self: *const Self) usize {
            return self.items.items.len - 1;
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.count() == 0;
        }

        pub fn enqueue(self: *Self, item: T) !void {
            try self.items.append(item);
            const i = self.count();
            self.items.items[i].?.position = i;
            self.upheap(i);
        }

        pub fn dequeue(self: *Self) ?T {
            if (self.isEmpty()) return null;

            const result = self.items.items[1];
            const last = self.items.pop();

            if (self.isEmpty()) return result;

            self.items.items[1] = last;
            last.?.position = 1;
            self.downheap(1);

            return result;
        }

        pub fn peek(self: *const Self) ?T {
            if (self.isEmpty()) return null;
            return self.items.items[1];
        }

        fn compare(a: T, b: T) std.math.Order {
            if (inverse) {
                return std.math.order(b.priority, a.priority);
            } else {
                return std.math.order(a.priority, b.priority);
            }
        }

        fn upheap(self: *Self, i: usize) void {
            var current_i = i;
            var parent_i = current_i / 2;

            if (current_i <= 1) return;

            const current_item = self.items.items[current_i].?;

            while (parent_i > 0) {
                const parent_item = self.items.items[parent_i].?;
                if (Self.compare(current_item, parent_item) == .gt) {
                    self.swap(current_i, parent_i);
                    current_i = parent_i;
                    parent_i = current_i / 2;
                } else {
                    break;
                }
            }
        }

        fn downheap(self: *Self, i: usize) void {
            var current_i = i;

            while (true) {
                const child_i = current_i * 2;
                if (child_i > self.count()) break;

                var child_to_swap_i = child_i;
                const right_child_i = child_i + 1;

                if (right_child_i <= self.count()) {
                    const left = self.items.items[child_i].?;
                    const right = self.items.items[right_child_i].?;
                    if (Self.compare(right, left) == .gt) {
                        child_to_swap_i = right_child_i;
                    }
                }

                const current_item = self.items.items[current_i].?;
                const child_to_swap = self.items.items[child_to_swap_i].?;

                if (Self.compare(child_to_swap, current_item) == .gt) {
                    self.swap(current_i, child_to_swap_i);
                    current_i = child_to_swap_i;
                } else {
                    break;
                }
            }
        }

        fn swap(self: *Self, i: usize, j: usize) void {
            var item_i = self.items.items[i].?;
            var item_j = self.items.items[j].?;

            item_i.position = j;
            item_j.position = i;

            self.items.items[i] = item_j;
            self.items.items[j] = item_i;
        }
    };
}

const TestItem = struct {
    priority: f64,
    position: usize = 0,
};

test "basic priority queue" {
    var pq = PriorityQueue(TestItem, false).init(std.testing.allocator);
    defer pq.deinit();

    try pq.enqueue(.{ .priority = 3 });
    try pq.enqueue(.{ .priority = 0 });
    try pq.enqueue(.{ .priority = 5 });

    try std.testing.expectEqual(@as(usize, 3), pq.count());
    try std.testing.expectEqual(@as(f64, 5), pq.peek().?.priority);

    var item = pq.dequeue().?;
    try std.testing.expectEqual(@as(f64, 5), item.priority);
    try std.testing.expectEqual(@as(f64, 3), pq.peek().?.priority);

    item = pq.dequeue().?;
    try std.testing.expectEqual(@as(f64, 3), item.priority);
    try std.testing.expectEqual(@as(f64, 0), pq.peek().?.priority);
}

test "inverse priority queue" {
    var pq = PriorityQueue(TestItem, true).init(std.testing.allocator);
    defer pq.deinit();

    try pq.enqueue(.{ .priority = 3 });
    try pq.enqueue(.{ .priority = 0 });
    try pq.enqueue(.{ .priority = 5 });

    try std.testing.expectEqual(@as(usize, 3), pq.count());
    try std.testing.expectEqual(@as(f64, 0), pq.peek().?.priority);

    var item = pq.dequeue().?;
    try std.testing.expectEqual(@as(f64, 0), item.priority);
    try std.testing.expectEqual(@as(f64, 3), pq.peek().?.priority);

    item = pq.dequeue().?;
    try std.testing.expectEqual(@as(f64, 3), item.priority);
    try std.testing.expectEqual(@as(f64, 5), pq.peek().?.priority);
}
