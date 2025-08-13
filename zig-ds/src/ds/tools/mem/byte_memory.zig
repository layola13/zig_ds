const std = @import("std");

pub const ByteMemory = struct {
    _data: []u8,

    pub fn init(allocator: std.mem.Allocator, size_in_bytes: usize) !*ByteMemory {
        const self = try allocator.create(ByteMemory);
        self._data = try allocator.alloc(u8, size_in_bytes);
        return self;
    }

    pub fn deinit(self: *ByteMemory, allocator: std.mem.Allocator) void {
        allocator.free(self._data);
        allocator.destroy(self);
    }

    pub fn get(self: *ByteMemory, i: usize) u8 {
        return self._data[i];
    }

    pub fn set(self: *ByteMemory, i: usize, val: u8) void {
        self._data[i] = val;
    }

    pub fn size(self: *ByteMemory) usize {
        return self._data.len;
    }
};

test "ByteMemory" {
    const allocator = std.testing.allocator;
    var mem = try ByteMemory.init(allocator, 10);
    defer mem.deinit(allocator);

    try std.testing.expect(mem.get(0) == 0);
    mem.set(0, 123);
    try std.testing.expect(mem.get(0) == 123);
}
