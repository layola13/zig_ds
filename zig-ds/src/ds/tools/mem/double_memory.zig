const std = @import("std");

pub const DoubleMemory = struct {
    _data: []f64,

    pub fn init(allocator: std.mem.Allocator, size_in_doubles: usize) !*DoubleMemory {
        const self = try allocator.create(DoubleMemory);
        self._data = try allocator.alloc(f64, size_in_doubles);
        return self;
    }

    pub fn deinit(self: *DoubleMemory, allocator: std.mem.Allocator) void {
        allocator.free(self._data);
        allocator.destroy(self);
    }

    pub fn get(self: *DoubleMemory, i: usize) f64 {
        return self._data[i];
    }

    pub fn set(self: *DoubleMemory, i: usize, val: f64) void {
        self._data[i] = val;
    }

    pub fn size(self: *DoubleMemory) usize {
        return self._data.len;
    }
};

test "DoubleMemory" {
    const allocator = std.testing.allocator;
    var mem = try DoubleMemory.init(allocator, 10);
    defer mem.deinit(allocator);

    try std.testing.expect(mem.get(0) == 0.0);
    mem.set(0, 123.456789);
    try std.testing.expect(mem.get(0) == 123.456789);
}
