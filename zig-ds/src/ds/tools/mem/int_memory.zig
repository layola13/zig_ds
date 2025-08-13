const std = @import("std");

pub const IntMemory = struct {
    _data: []i32,

    pub fn init(allocator: std.mem.Allocator, size_in_ints: usize) !*IntMemory {
        const self = try allocator.create(IntMemory);
        self._data = try allocator.alloc(i32, size_in_ints);
        return self;
    }

    pub fn deinit(self: *IntMemory, allocator: std.mem.Allocator) void {
        allocator.free(self._data);
        allocator.destroy(self);
    }

    pub fn get(self: *IntMemory, i: usize) i32 {
        return self._data[i];
    }

    pub fn set(self: *IntMemory, i: usize, val: i32) void {
        self._data[i] = val;
    }

    pub fn size(self: *IntMemory) usize {
        return self._data.len;
    }
};

test "IntMemory" {
    const allocator = std.testing.allocator;
    var mem = try IntMemory.init(allocator, 10);
    defer mem.deinit(allocator);

    try std.testing.expect(mem.get(0) == 0);
    mem.set(0, 123456789);
    try std.testing.expect(mem.get(0) == 123456789);
}
