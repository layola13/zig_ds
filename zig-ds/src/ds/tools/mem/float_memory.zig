const std = @import("std");

pub const FloatMemory = struct {
    _data: []f32,

    pub fn init(allocator: std.mem.Allocator, size_in_floats: usize) !*FloatMemory {
        const self = try allocator.create(FloatMemory);
        self._data = try allocator.alloc(f32, size_in_floats);
        return self;
    }

    pub fn deinit(self: *FloatMemory, allocator: std.mem.Allocator) void {
        allocator.free(self._data);
        allocator.destroy(self);
    }

    pub fn get(self: *FloatMemory, i: usize) f32 {
        return self._data[i];
    }

    pub fn set(self: *FloatMemory, i: usize, val: f32) void {
        self._data[i] = val;
    }

    pub fn size(self: *FloatMemory) usize {
        return self._data.len;
    }
};

test "FloatMemory" {
    const allocator = std.testing.allocator;
    var mem = try FloatMemory.init(allocator, 10);
    defer mem.deinit(allocator);

    try std.testing.expect(mem.get(0) == 0.0);
    mem.set(0, 123.456);
    try std.testing.expect(mem.get(0) == 123.456);
}
