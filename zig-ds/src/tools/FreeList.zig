const std = @import("std");

pub fn FreeList(comptime T: type) type {
    return struct {
        const Self = @This();

        var data: std.ArrayList(T) = undefined;
        var free: std.ArrayList(usize) = undefined;
        var allocator: std.mem.Allocator = undefined;

        pub fn init(allocator_param: std.mem.Allocator) Self {
            return Self{
                .data = std.ArrayList(T).init(allocator_param),
                .free = std.ArrayList(usize).init(allocator_param),
                .allocator = allocator_param,
            };
        }

        pub fn deinit(self: *Self) void {
            self.data.deinit();
            self.free.deinit();
        }

        pub fn next(self: *Self) usize {
            if (self.free.items.len > 0) {
                return self.free.pop();
            } else {
                const i = self.data.items.len;
                self.data.append(undefined) catch @panic("failed to append to free list");
                return i;
            }
        }

        pub fn get(self: Self, i: usize) T {
            return self.data.items[i];
        }

        pub fn set(self: *Self, i: usize, val: T) void {
            self.data.items[i] = val;
        }

        pub fn put(self: *Self, i: usize) void {
            self.free.append(i) catch @panic("failed to append to free list");
        }
    };
}
