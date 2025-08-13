const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

/// Defines the requirements for a type to be a key in a HashTable.
/// It must have a `hash() u64` method and an `eql(other: *const Self) bool` method.
pub fn isHashable(comptime T: type) bool {
    return @hasDecl(T, "hash") and
        @typeInfo(@TypeOf(T.hash)).Fn.return_type == u64 and
        @hasDecl(T, "eql") and
        @typeInfo(@TypeOf(T.eql)).Fn.return_type == bool;
}

pub fn HashTable(comptime K: type, comptime V: type) type {
    if (!isHashable(K)) {
        @compileError("Key type " ++ @typeName(K) ++ " does not meet Hashable requirements.");
    }

    return struct {
        const Self = @This();
        const Entry = struct {
            key: K,
            value: V,
            next: ?*Entry,
        };

        allocator: Allocator,
        buckets: []*?Entry,
        count: usize = 0,

        pub fn init(allocator: Allocator, initial_slots: usize) !Self {
            const num_slots = std.math.ceilPowerOfTwo(u64, initial_slots) catch initial_slots;
            const buckets = try allocator.alloc(?*Entry, num_slots);
            mem.set(?*Entry, buckets, null);

            return Self{
                .allocator = allocator,
                .buckets = buckets,
            };
        }

        pub fn deinit(self: *Self) void {
            self.clear();
            self.allocator.free(self.buckets);
        }

        pub fn put(self: *Self, key: K, value: V) !void {
            const hash = key.hash();
            const index = @as(usize, @intCast(hash & (self.buckets.len - 1)));

            var entry = self.buckets[index];
            while (entry) |e| {
                if (e.key.eql(&key)) {
                    e.value = value;
                    return;
                }
                entry = e.next;
            }

            // Key not found, create a new entry
            const new_entry = try self.allocator.create(Entry);
            new_entry.* = .{
                .key = key,
                .value = value,
                .next = self.buckets[index],
            };
            self.buckets[index] = new_entry;
            self.count += 1;
        }

        pub fn get(self: *const Self, key: K) ?V {
            const hash = key.hash();
            const index = @as(usize, @intCast(hash & (self.buckets.len - 1)));

            var entry = self.buckets[index];
            while (entry) |e| {
                if (e.key.eql(&key)) {
                    return e.value;
                }
                entry = e.next;
            }
            return null;
        }

        pub fn remove(self: *Self, key: K) bool {
            const hash = key.hash();
            const index = @as(usize, @intCast(hash & (self.buckets.len - 1)));

            var maybe_entry = self.buckets[index];
            var prev: ?*Entry = null;
            while (maybe_entry) |entry| {
                if (entry.key.eql(&key)) {
                    if (prev) |p| {
                        p.next = entry.next;
                    } else {
                        self.buckets[index] = entry.next;
                    }
                    self.allocator.destroy(entry);
                    self.count -= 1;
                    return true;
                }
                prev = entry;
                maybe_entry = entry.next;
            }
            return false;
        }

        pub fn clear(self: *Self) void {
            for (0..self.buckets.len) |i| {
                var entry = self.buckets[i];
                while (entry) |e| {
                    const next = e.next;
                    self.allocator.destroy(e);
                    entry = next;
                }
                self.buckets[i] = null;
            }
            self.count = 0;
        }
    };
}

const TestKey = struct {
    id: i32,

    pub fn hash(self: *const TestKey) u64 {
        return std.hash.Wyhash.hash(0, std.mem.asBytes(&self.id));
    }

    pub fn eql(self: *const TestKey, other: *const TestKey) bool {
        return self.id == other.id;
    }
};

test "basic hash table" {
    var table = try HashTable(TestKey, i32).init(std.testing.allocator, 16);
    defer table.deinit();

    try table.put(.{ .id = 1 }, 100);
    try table.put(.{ .id = 17 }, 200); // Should collide with 1 in a 16-slot table
    try table.put(.{ .id = 2 }, 300);

    try std.testing.expectEqual(@as(usize, 3), table.count);
    try std.testing.expectEqual(@as(i32, 100), table.get(.{ .id = 1 }).?);
    try std.testing.expectEqual(@as(i32, 200), table.get(.{ .id = 17 }).?);
    try std.testing.expectEqual(@as(i32, 300), table.get(.{ .id = 2 }).?);

    // Update value
    try table.put(.{ .id = 1 }, 101);
    try std.testing.expectEqual(@as(i32, 101), table.get(.{ .id = 1 }).?);

    // Remove
    try std.testing.expect(table.remove(.{ .id = 17 }));
    try std.testing.expectEqual(@as(usize, 2), table.count);
    try std.testing.expect(table.get(.{ .id = 17 }) == null);

    // Clear
    table.clear();
    try std.testing.expectEqual(@as(usize, 0), table.count);
    try std.testing.expect(table.get(.{ .id = 1 }) == null);
}
