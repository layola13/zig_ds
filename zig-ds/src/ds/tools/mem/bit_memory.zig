const std = @import("std");

pub const BitMemory = struct {
    _data: []u8,
    _size: usize,

    pub fn init(allocator: std.mem.Allocator, size_in_bits: usize) !*BitMemory {
        const self = try allocator.create(BitMemory);
        const num_bytes = std.math.divCeil(usize, size_in_bits, 8) catch unreachable;
        self._data = try allocator.alloc(u8, num_bytes);
        self._size = size_in_bits;
        return self;
    }

    pub fn deinit(self: *BitMemory, allocator: std.mem.Allocator) void {
        allocator.free(self._data);
        allocator.destroy(self);
    }

    pub fn get(self: *BitMemory, i: usize) bool {
        const byte_index = i / 8;
        const bit_index = i % 8;
        return (self._data[byte_index] & (1 << bit_index)) != 0;
    }

    pub fn set(self: *BitMemory, i: usize, val: bool) void {
        const byte_index = i / 8;
        const bit_index = i % 8;
        if (val) {
            self._data[byte_index] |= (1 << bit_index);
        } else {
            self._data[byte_index] &= ~(1 << bit_index);
        }
    }

    pub fn size(self: *BitMemory) usize {
        return self._size;
    }
};

test "BitMemory" {
    const allocator = std.testing.allocator;
    var mem = try BitMemory.init(allocator, 10);
    defer mem.deinit(allocator);

    try std.testing.expect(!mem.get(0));
    mem.set(0, true);
    try std.testing.expect(mem.get(0));

    try std.testing.expect(!mem.get(9));
    mem.set(9, true);
    try std.testing.expect(mem.get(9));
}
