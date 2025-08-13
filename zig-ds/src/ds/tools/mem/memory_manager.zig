const std = @import("std");

pub const MemoryManager = struct {
    pub const instance = @This();

    pub fn malloc(self: *@This(), access: *anyopaque, bytes: i32) !*anyopaque {
        _ = self;
        _ = access;
        const buf = try std.heap.c_allocator.alloc(u8, @as(usize, @intCast(bytes)));
        return @as(*anyopaque, @ptrFromInt(@intFromPtr(buf.ptr)));
    }

    pub fn dealloc(self: *@This(), access: *anyopaque, bytes: i32) void {
        _ = self;
        const buf = @as([*]u8, @ptrFromInt(@intFromPtr(access)))[0..@as(usize, @intCast(bytes))];
        std.heap.c_allocator.free(buf);
    }

    pub fn realloc(self: *@This(), access: *anyopaque, old_bytes: i32, new_bytes: i32) !*anyopaque {
        _ = self;
        const buf = @as([*]u8, @ptrFromInt(@intFromPtr(access)))[0..@as(usize, @intCast(old_bytes))];
        const new_buf = try std.heap.c_allocator.realloc(buf, @as(usize, @intCast(new_bytes)));
        return @as(*anyopaque, @ptrFromInt(@intFromPtr(new_buf.ptr)));
    }
};
