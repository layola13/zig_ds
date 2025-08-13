const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

/// Defines the requirements for a type to be storable in a Heap.
/// It must have a `position: usize` field for efficient updates
/// and a `compare(self: *const Self, other: *const Self) std.math.Order` method.
pub fn isHeapable(comptime T: type) bool {
    return @hasField(T, "position") and
        comptime mem.eql(u8, @typeName(@TypeOf(@field(T, "position"))), "usize") and
            @hasDecl(T, "compare") and
            @typeInfo(@TypeOf(T.compare)).Fn.return_type == std.math.Order;
}

pub fn Heap(comptime T: type) type {
    if (!isHeapable(T)) {
        @compileError("Type " ++ @typeName(T) ++ " does not meet Heapable requirements.");
    }

    return struct {
        const Self = @This();

        // Underlying array. Index 0 is unused to simplify parent/child calculations.
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

        pub fn add(self: *Self, item: T) !void {
            try self.items.append(item);
            const i = self.count();
            self.items.items[i].?.position = i;
            self.upheap(i);
        }

        pub fn pop(self: *Self) ?T {
            if (self.isEmpty()) return null;

            const result = self.items.items[1];
            const last = self.items.pop();

            if (self.isEmpty()) return result;

            self.items.items[1] = last;
            last.?.position = 1;
            self.downheap(1);

            return result;
        }

        pub fn top(self: *const Self) ?T {
            if (self.isEmpty()) return null;
            return self.items.items[1];
        }

        pub fn change(self: *Self, item: *T, hint: std.math.Order) void {
            // TODO: This is not a correct implementation of change, as it doesn't use the item value.
            // It assumes the position is correct and the hint is accurate.
            switch (hint) {
                .eq => {},
                .lt => self.downheap(item.position),
                .gt => self.upheap(item.position),
            }
        }

        fn upheap(self: *Self, i: usize) void {
            var current_i = i;
            var parent_i = current_i / 2;

            if (current_i <= 1) return;

            var current_item = self.items.items[current_i].?;

            while (parent_i > 0) {
                var parent_item = self.items.items[parent_i].?;
                if (current_item.compare(&parent_item) == .gt) {
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
                    var left = self.items.items[child_i].?;
                    var right = self.items.items[right_child_i].?;
                    if (right.compare(&left) == .gt) {
                        child_to_swap_i = right_child_i;
                    }
                }

                var current_item = self.items.items[current_i].?;
                var child_to_swap = self.items.items[child_to_swap_i].?;

                if (current_item.compare(&child_to_swap) == .lt) {
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
    id: i32,
    position: usize = 0,

    pub fn compare(self: *const TestItem, other: *const TestItem) std.math.Order {
        return std.math.order(self.id, other.id);
    }
};

test "basic heap operations" {
    var heap = Heap(TestItem).init(std.testing.allocator);
    defer heap.deinit();

    try heap.add(.{ .id = 64 });
    try heap.add(.{ .id = 13 });
    try heap.add(.{ .id = 1 });
    try heap.add(.{ .id = 37 });

    try std.testing.expectEqual(@as(usize, 4), heap.count());
    try std.testing.expectEqual(@as(i32, 64), heap.top().?.id);

    var item = heap.pop().?;
    try std.testing.expectEqual(@as(i32, 64), item.id);
    try std.testing.expectEqual(@as(usize, 3), heap.count());
    try std.testing.expectEqual(@as(i32, 37), heap.top().?.id);

    item = heap.pop().?;
    try std.testing.expectEqual(@as(i32, 37), item.id);
    try std.testing.expectEqual(@as(usize, 2), heap.count());
    try std.testing.expectEqual(@as(i32, 13), heap.top().?.id);

    item = heap.pop().?;
    try std.testing.expectEqual(@as(i32, 13), item.id);
    try std.testing.expectEqual(@as(usize, 1), heap.count());
    try std.testing.expectEqual(@as(i32, 1), heap.top().?.id);

    item = heap.pop().?;
    try std.testing.expectEqual(@as(i32, 1), item.id);
    try std.testing.expect(heap.isEmpty());
}
