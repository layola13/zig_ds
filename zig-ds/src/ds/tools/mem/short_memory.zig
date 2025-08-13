const std = @import("std");

pub const ShortMemory = struct {
    _data: []i16,

    pub fn init(allocator: std.mem.Allocator, size_in_shorts: usize) !*ShortMemory {
        const self = try allocator.create(ShortMemory);
        self._data = try allocator.alloc(i16, size_in_shorts);
        return self;
    }

    pub fn deinit(self: *ShortMemory, allocator: std.mem.Allocator) void {
        allocator.free(self._data);
        allocator.destroy(self);
    }

    pub fn get(self: *ShortMemory, i: usize) i16 {
        return self._data[i];
    }

    pub fn set(self: *ShortMemory, i: usize, val: i16) void {
        self._data[i] = val;
    }

    pub fn size(self: *ShortMemory) usize {
        return self._data.len;
    }
};

test "ShortMemory" {
    const allocator = std.testing.allocator;
    var mem = try ShortMemory.init(allocator, 10);
    defer mem.deinit(allocator);

    try std.testing.expect(mem.get(0) == 0);
    mem.set(0, 12345);
    try std.testing.expect(mem.get(0) == 12345);
}
