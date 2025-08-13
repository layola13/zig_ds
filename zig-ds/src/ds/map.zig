const std = @import("std");
const Collection = @import("collection.zig").Collection;
const Itr = @import("itr.zig").Itr;

/// A generic map interface.
pub fn Map(comptime K: type, comptime V: type) type {
    return struct {
        const Self = @This();

        context: ?*anyopaque,
        hasFn: fn (ctx: ?*anyopaque, val: V) bool,
        hasKeyFn: fn (ctx: ?*anyopaque, key: K) bool,
        getFn: fn (ctx: ?*anyopaque, key: K) ?V,
        setFn: fn (ctx: ?*anyopaque, key: K, val: V) bool,
        unsetFn: fn (ctx: ?*anyopaque, key: K) bool,
        keysFn: fn (ctx: ?*anyopaque) Itr(K),
        collection: Collection(V),

        pub fn has(self: *Self, val: V) bool {
            return self.hasFn(self.context, val);
        }

        pub fn hasKey(self: *Self, key: K) bool {
            return self.hasKeyFn(self.context, key);
        }

        pub fn get(self: *Self, key: K) ?V {
            return self.getFn(self.context, key);
        }

        pub fn set(self: *Self, key: K, val: V) bool {
            return self.setFn(self.context, key, val);
        }

        pub fn unset(self: *Self, key: K) bool {
            return self.unsetFn(self.context, key);
        }

        pub fn keys(self: *Self) Itr(K) {
            return self.keysFn(self.context);
        }
    };
}

test "Map interface" {
    try std.testing.expect(true); // Placeholder
}
