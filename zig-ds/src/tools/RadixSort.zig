const std = @import("std");

pub const RadixSort = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    inp: []u32,
    out: []u32,
    num: [256]u32,
    bin: [512]u32,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
            .inp = &[_]u32{},
            .out = &[_]u32{},
            .num = undefined,
            .bin = undefined,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.inp);
        self.allocator.free(self.out);
    }

    pub fn sort(self: *Self, input: []u32) !void {
        const l = input.len;
        if (self.inp.len < l) {
            self.allocator.free(self.inp);
            self.allocator.free(self.out);
            self.inp = try self.allocator.alloc(u32, l);
            self.out = try self.allocator.alloc(u32, l);
        }

        @memcpy(self.inp[0..l], input);

        var mask: u32 = 255;
        var shr: u32 = 0;
        var flip = false;

        while (mask != 0) {
            std.mem.set(u32, &self.num, 0);

            for (self.inp[0..l]) |val| {
                const j = (val & mask) >> shr;
                self.num[j] += 1;
            }

            self.bin[0] = 0;
            self.bin[256] = 0;
            for (1..256) |i| {
                const k = self.bin[i - 1] + self.num[i - 1];
                self.bin[i] = k;
                self.bin[i + 256] = k;
            }

            for (self.inp[0..l]) |val| {
                const j = (val & mask) >> shr;
                const k = self.bin[j + 256];
                self.bin[j + 256] = k + 1;
                self.out[k] = val;
            }

            mask <<= 8;
            shr += 8;
            flip = !flip;
            const tmp = self.inp;
            self.inp = self.out;
            self.out = tmp;
        }

        if (flip) {
            @memcpy(input, self.out[0..l]);
        } else {
            @memcpy(input, self.inp[0..l]);
        }
    }
};
