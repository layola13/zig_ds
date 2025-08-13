const std = @import("std");
const Allocator = std.mem.Allocator;
const core = @import("../core.zig");
const assert = @import("../tools/assert.zig").assert;

pub fn HashMap(comptime K: type, comptime V: type) type {
    return struct {
        const Self = @This();

        map: std.HashMap(K, V, std.hash_map.DefaultContext, std.hash_map.default_max_load_percentage),
        allocator: Allocator,

        pub fn init(allocator: Allocator) Self {
            return .{
                .map = std.HashMap(K, V, std.hash_map.DefaultContext, std.hash_map.default_max_load_percentage).init(allocator),
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.map.deinit();
        }

        pub fn put(self: *Self, key: K, value: V) !void {
            try self.map.put(key, value);
        }

        pub fn get(self: *const Self, key: K) ?V {
            return self.map.get(key);
        }

        pub fn has(self: *const Self, key: K) bool {
            return self.map.has(key);
        }

        pub fn remove(self: *Self, key: K) ?V {
            return self.map.remove(key);
        }

        pub fn count(self: *const Self) usize {
            return self.map.count();
        }
    };
}

test "HashMap" {
    var map = HashMap(i32, []const u8).init(std.testing.allocator);
    defer map.deinit();

    try map.put(1, "one");
    try map.put(2, "two");

    try std.testing.expect(map.has(1));
    try std.testing.expectEqualStrings("two", map.get(2).?);
    try std.testing.expectEqual(@as(usize, 2), map.count());
}