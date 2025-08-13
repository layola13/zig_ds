const std = @import("std");

pub const MASK_LUT = [_]u32{
    0x0, 0x1, 0x3, 0x7, 0xF, 0x1F, 0x3F, 0x7F, 0xFF, 0x1FF, 0x3FF, 0x7FF, 0xFFF, 0x1FFF, 0x3FFF, 0x7FFF, 0xFFFF, 0x1FFFF, 0x3FFFF, 0x7FFFF, 0xFFFFF, 0x1FFFFF, 0x3FFFFF, 0x7FFFFF, 0xFFFFFF, 0x1FFFFFF, 0x3FFFFFF, 0x7FFFFFF, 0xFFFFFFF, 0x1FFFFFFF, 0x3FFFFFFF, 0x7FFFFFFF, 0xFFFFFFFF,
};

pub fn mask(n: u32) u32 {
    std.debug.assert(n >= 1 and n <= 32);
    return MASK_LUT[n];
}

pub fn ones(x: u32) u32 {
    var x_mut = x;
    x_mut -= ((x_mut >> 1) & 0x55555555);
    x_mut = (((x_mut >> 2) & 0x33333333) + (x_mut & 0x33333333));
    x_mut = (((x_mut >> 4) + x_mut) & 0x0F0F0F0F);
    x_mut += (x_mut >> 8);
    x_mut += (x_mut >> 16);
    return (x_mut & 0x0000003F);
}

pub fn ntz(x: u32) u32 {
    return @ctz(x);
}

pub fn nlz(x: u32) u32 {
    return @clz(x);
}

pub fn msb(x: u32) u32 {
    var x_mut = x;
    x_mut |= (x_mut >> 1);
    x_mut |= (x_mut >> 2);
    x_mut |= (x_mut >> 4);
    x_mut |= (x_mut >> 8);
    x_mut |= (x_mut >> 16);
    return (x_mut & ~(x_mut >> 1));
}

pub fn rol(x: u32, n: u32) u32 {
    return (x << n) | (x >> (32 - n));
}

pub fn ror(x: u32, n: u32) u32 {
    return (x >> n) | (x << (32 - n));
}

pub fn reverse(x: u32) u32 {
    return @bitReverse(x);
}

pub fn flipWORD(x: u16) u16 {
    return @byteSwap(x);
}

pub fn flipDWORD(x: u32) u32 {
    return @byteSwap(x);
}

pub fn swap(x: u32, i: u32, j: u32) u32 {
    const t = ((x >> i) ^ (x >> j)) & 0x01;
    return x ^ ((t << i) | (t << j));
}
