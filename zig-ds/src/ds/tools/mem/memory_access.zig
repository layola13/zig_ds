const std = @import("std");
const Hashable = @import("../../hashable.zig").Hashable;
const HashKey = @import("../../hash_key.zig");
const MemoryManager = @import("memory_manager.zig").MemoryManager;

pub const MemoryAccess = struct {
    pub const VTable = struct {
        hashable: Hashable.VTable,
    };

    vtable: *const VTable,
    context: *anyopaque,

    bytes: i32,
    offset: i32,
    name: ?[]const u8,
    mMemory: ?*anyopaque,

    pub fn hashable(self: *@This()) Hashable {
        return .{
            .vtable = &self.vtable.hashable,
            .context = self,
        };
    }

    pub fn key(self: *@This()) i32 {
        return self.hashable().key();
    }

    pub fn init(self: *@This(), bytes: i32, name: ?[]const u8) !void {
        std.debug.assert(bytes > 0);

        self.bytes = bytes;
        self.name = name;

        self.mMemory = try MemoryManager.instance.malloc(self, bytes);
    }

    pub fn deinit(self: *@This()) void {
        std.debug.assert(self.mMemory != null);

        MemoryManager.instance.dealloc(self);
        self.mMemory = null;
    }

    pub fn clear(self: *@This()) void {
        const slice = std.mem.as([*]u8, self.mMemory.?)[self.offset..self.bytes];
        @memset(slice, 0);
    }

    pub fn resize(self: *@This(), byteSize: i32) !void {
        std.debug.assert(byteSize > 0);
        std.debug.assert(self.mMemory != null);

        self.bytes = byteSize;
        try MemoryManager.instance.realloc(self, byteSize);
    }
};
