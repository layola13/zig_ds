const std = @import("std");
const ds = @import("../ds/ds.zig");

pub fn ObjectPool(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        pool: std.ArrayList(T),
        factory: *const fn () T,
        dispose: *const fn (T) void,
        max_size: usize,
        growth_rate: ds.GrowthRate,

        pub fn init(
            allocator: std.mem.Allocator,
            factory: *const fn () T,
            dispose: *const fn (T) void,
            max_size: usize,
        ) Self {
            return Self{
                .allocator = allocator,
                .pool = std.ArrayList(T).init(allocator),
                .factory = factory,
                .dispose = dispose,
                .max_size = max_size,
                .growth_rate = ds.GrowthRate.MILD,
            };
        }

        pub fn deinit(self: *Self) void {
            for (self.pool.items) |item| {
                self.dispose(item);
            }
            self.pool.deinit();
        }

        pub fn preallocate(self: *Self, num_objects: usize) !void {
            try self.pool.ensureTotalCapacity(num_objects);
            for (0..num_objects) |_| {
                try self.pool.append(self.factory());
            }
        }

        pub fn get(self: *Self) T {
            if (self.pool.items.len > 0) {
                return self.pool.pop();
            } else {
                return self.factory();
            }
        }

        pub fn put(self: *Self, obj: T) !void {
            if (self.pool.items.len >= self.max_size) {
                self.dispose(obj);
            } else {
                if (self.pool.items.len == self.pool.capacity) {
                    const new_capacity = ds.GrowthRate.compute(self.growth_rate, self.pool.capacity);
                    try self.pool.ensureTotalCapacity(new_capacity);
                }
                try self.pool.append(obj);
            }
        }
    };
}
