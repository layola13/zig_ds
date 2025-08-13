const std = @import("std");
const HashTable = @import("HashTable.zig").HashTable;
const isHashable = @import("HashTable.zig").isHashable;
const Allocator = std.mem.Allocator;

pub fn HashSet(comptime T: type) type {
    if (!isHashable(T)) {
        @compileError("Type " ++ @typeName(T) ++ " does not meet Hashable requirements.");
    }

    return struct {
        const Self = @This();

        hash_table: HashTable(T, void),

        pub fn init(allocator: Allocator, initial_slots: usize) !Self {
            return Self{
                .hash_table = try HashTable(T, void).init(allocator, initial_slots),
            };
        }

        pub fn deinit(self: *Self) void {
            self.hash_table.deinit();
        }

        pub fn add(self: *Self, item: T) !void {
            try self.hash_table.put(item, {});
        }

        pub fn contains(self: *const Self, item: T) bool {
            return self.hash_table.get(item) != null;
        }

        pub fn remove(self: *Self, item: T) bool {
            return self.hash_table.remove(item);
        }

        pub fn clear(self: *Self) void {
            self.hash_table.clear();
        }

        pub fn count(self: *const Self) usize {
            return self.hash_table.count;
        }
    };
}

const TestItem = @import("HashTable.zig").TestKey;

test "basic hash set" {
    var set = try HashSet(TestItem).init(std.testing.allocator, 16);
    defer set.deinit();

    try set.add(.{ .id = 1 });
    try set.add(.{ .id = 17 }); // Collision
    try set.add(.{ .id = 1 }); // Duplicate, should be ignored implicitly by put

    try std.testing.expectEqual(@as(usize, 2), set.count());
    try std.testing.expect(set.contains(.{ .id = 1 }));
    try std.testing.expect(set.contains(.{ .id = 17 }));
    try std.testing.expect(!set.contains(.{ .id = 2 }));

    try std.testing.expect(set.remove(.{ .id = 17 }));
    try std.testing.expect(!set.contains(.{ .id = 17 }));
    try std.testing.expectEqual(@as(usize, 1), set.count());

    set.clear();
    try std.testing.expectEqual(@as(usize, 0), set.count());
}
