const std = @import("std");
const ds = @import("../ds/ds.zig");

const assert = std.debug.assert;
const Allocator = std.mem.Allocator;

pub fn IntHashSet() type {
    return struct {
        const Self = @This();

        hash_set: ds.HashSet(i64),

        pub fn init(allocator: *Allocator) Self {
            return .{
                .hash_set = ds.HashSet(i64).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.hash_set.deinit();
        }

        pub fn add(self: *Self, key: i64) !void {
            return self.hash_set.add(key);
        }

        pub fn contains(self: *Self, key: i64) bool {
            return self.hash_set.contains(key);
        }

        pub fn remove(self: *Self, key: i64) bool {
            return self.hash_set.remove(key);
        }

        pub fn count(self: *const Self) usize {
            return self.hash_set.count();
        }

        pub fn clear(self: *Self) void {
            self.hash_set.clear();
        }

        pub fn iterator(self: *Self) ds.HashSet(i64).Iterator {
            return self.hash_set.iterator();
        }
    };
}

test "IntHashSet" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var set = IntHashSet().init(allocator);
    defer set.deinit();

    try set.add(1);
    try set.add(2);

    try std.testing.expectEqual(true, set.contains(1));
    try std.testing.expectEqual(false, set.contains(3));
    try std.testing.expectEqual(@as(usize, 2), set.count());

    _ = set.remove(1);
    try std.testing.expectEqual(false, set.contains(1));
    try std.testing.expectEqual(@as(usize, 1), set.count());

    set.clear();
    try std.testing.expectEqual(@as(usize, 0), set.count());
}
