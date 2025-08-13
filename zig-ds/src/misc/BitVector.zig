const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

const BITS_PER_WORD = 32;

pub const BitVector = struct {
    const Self = @This();

    allocator: Allocator,
    words: []u32,
    num_bits: usize,

    pub fn init(allocator: Allocator, num_bits: usize) !Self {
        const num_words = (num_bits + BITS_PER_WORD - 1) / BITS_PER_WORD;
        const words = try allocator.alloc(u32, num_words);
        mem.set(u32, words, 0);

        return Self{
            .allocator = allocator,
            .words = words,
            .num_bits = num_bits,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.words);
    }

    pub fn get(self: *const Self, i: usize) bool {
        std.debug.assert(i < self.num_bits);
        const word_index = i / BITS_PER_WORD;
        const bit_index = i % BITS_PER_WORD;
        return (self.words[word_index] & (@as(u32, 1) << @intCast(bit_index))) != 0;
    }

    pub fn set(self: *Self, i: usize) void {
        std.debug.assert(i < self.num_bits);
        const word_index = i / BITS_PER_WORD;
        const bit_index = i % BITS_PER_WORD;
        self.words[word_index] |= (@as(u32, 1) << @intCast(bit_index));
    }

    pub fn clear(self: *Self, i: usize) void {
        std.debug.assert(i < self.num_bits);
        const word_index = i / BITS_PER_WORD;
        const bit_index = i % BITS_PER_WORD;
        self.words[word_index] &= ~(@as(u32, 1) << @intCast(bit_index));
    }

    pub fn clearAll(self: *Self) void {
        mem.set(u32, self.words, 0);
    }

    pub fn setAll(self: *Self) void {
        mem.set(u32, self.words, 0xFFFFFFFF);

        // Clear the bits in the last word that are beyond num_bits
        const remainder = self.num_bits % BITS_PER_WORD;
        if (remainder != 0) {
            const mask = (@as(u32, 1) << @intCast(remainder)) - 1;
            self.words[self.words.len - 1] &= mask;
        }
    }

    pub fn ones(self: *const Self) usize {
        var count: usize = 0;
        for (self.words) |word| {
            count += @popCount(word);
        }
        return count;
    }
};

test "basic bitvector" {
    var bv = try BitVector.init(std.testing.allocator, 40);
    defer bv.deinit();

    try std.testing.expectEqual(@as(usize, 40), bv.num_bits);
    try std.testing.expectEqual(@as(usize, 2), bv.words.len);

    bv.set(5);
    try std.testing.expect(bv.get(5));
    try std.testing.expect(!bv.get(6));

    bv.set(35);
    try std.testing.expect(bv.get(35));

    bv.clear(5);
    try std.testing.expect(!bv.get(5));

    try std.testing.expectEqual(@as(usize, 1), bv.ones());
}

test "bitvector clearAll and setAll" {
    var bv = try BitVector.init(std.testing.allocator, 65);
    defer bv.deinit();

    bv.set(1);
    bv.set(33);
    bv.set(64);
    try std.testing.expectEqual(@as(usize, 3), bv.ones());

    bv.clearAll();
    try std.testing.expectEqual(@as(usize, 0), bv.ones());
    try std.testing.expect(!bv.get(1));
    try std.testing.expect(!bv.get(33));
    try std.testing.expect(!bv.get(64));

    bv.setAll();
    try std.testing.expectEqual(@as(usize, 65), bv.ones());
}
