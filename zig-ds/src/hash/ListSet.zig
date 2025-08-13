const std = @import("std");
const ds = @import("../ds/ds.zig");

const assert = std.debug.assert;
const Allocator = std.mem.Allocator;

pub fn ListSet(comptime T: type) type {
    return struct {
        const Self = @This();

        list: std.ArrayList(T),

        pub fn init(allocator: *Allocator) Self {
            return .{
                .list = std.ArrayList(T).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.list.deinit();
        }

        pub fn add(self: *Self, item: T) !bool {
            if (self.contains(item)) {
                return false;
            }
            try self.list.append(item);
            return true;
        }

        pub fn contains(self: *const Self, item: T) bool {
            for (self.list.items) |i| {
                if (i == item) {
                    return true;
                }
            }
            return false;
        }

        pub fn remove(self: *Self, item: T) bool {
            for (self.list.items, 0..) |i, j| {
                if (i == item) {
                    _ = self.list.orderedRemove(j);
                    return true;
                }
            }
            return false;
        }

        pub fn count(self: *const Self) usize {
            return self.list.items.len;
        }

        pub fn clear(self: *Self) void {
            self.list.clearRetainingCapacity();
        }

        pub fn iterator(self: *Self) std.ArrayList(T).Iterator {
            return self.list.iterator();
        }
    };
}

test "ListSet" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var set = ListSet(u32).init(allocator);
    defer set.deinit();

    try std.testing.expect(try set.add(1));
    try std.testing.expect(try set.add(2));
    try std.testing.expect(!try set.add(1));

    try std.testing.expectEqual(true, set.contains(1));
    try std.testing.expectEqual(false, set.contains(3));
    try std.testing.expectEqual(@as(usize, 2), set.count());

    try std.testing.expect(set.remove(1));
    try std.testing.expectEqual(false, set.contains(1));
    try std.testing.expectEqual(@as(usize, 1), set.count());

    set.clear();
    try std.testing.expectEqual(@as(usize, 0), set.count());
}
