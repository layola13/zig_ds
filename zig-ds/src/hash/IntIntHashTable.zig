const std = @import("std");
const ds = @import("../ds/ds.zig");

const assert = std.debug.assert;
const Allocator = std.mem.Allocator;

pub fn IntIntHashTable() type {
    return struct {
        const Self = @This();

        hash_table: ds.HashTable(i64, i64),

        pub fn init(allocator: *Allocator) Self {
            return .{
                .hash_table = ds.HashTable(i64, i64).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.hash_table.deinit();
        }

        pub fn put(self: *Self, key: i64, value: i64) !void {
            return self.hash_table.put(key, value);
        }

        pub fn get(self: *Self, key: i64) ?i64 {
            return self.hash_table.get(key);
        }

        pub fn contains(self: *Self, key: i64) bool {
            return self.hash_table.contains(key);
        }

        pub fn remove(self: *Self, key: i64) ?i64 {
            return self.hash_table.remove(key);
        }

        pub fn count(self: *const Self) usize {
            return self.hash_table.count();
        }

        pub fn clear(self: *Self) void {
            self.hash_table.clear();
        }

        pub fn iterator(self: *Self) ds.HashTable(i64, i64).Iterator {
            return self.hash_table.iterator();
        }
    };
}

test "IntIntHashTable" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var table = IntIntHashTable().init(allocator);
    defer table.deinit();

    try table.put(1, 100);
    try table.put(2, 200);

    try std.testing.expectEqual(@as(?i64, 100), table.get(1));
    try std.testing.expectEqual(@as(?i64, 200), table.get(2));
    try std.testing.expectEqual(true, table.contains(1));
    try std.testing.expectEqual(false, table.contains(3));
    try std.testing.expectEqual(@as(usize, 2), table.count());

    _ = table.remove(1);
    try std.testing.expectEqual(false, table.contains(1));
    try std.testing.expectEqual(@as(usize, 1), table.count());

    table.clear();
    try std.testing.expectEqual(@as(usize, 0), table.count());
}
