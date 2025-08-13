const std = @import("std");

pub const INT32_MIN = std.math.minInt(i32);
pub const INT32_MAX = std.math.maxInt(i32);
pub const INT16_MIN = std.math.minInt(i16);
pub const INT16_MAX = std.math.maxInt(i16);
pub const UINT16_MAX = std.math.maxInt(u16);

pub fn isPow2(x: u32) bool {
    return std.math.isPowerOfTwo(x);
}

pub fn min(x: i32, y: i32) i32 {
    return std.math.min(x, y);
}

pub fn max(x: i32, y: i32) i32 {
    return std.math.max(x, y);
}

pub fn abs(x: i32) i32 {
    return std.math.absInt(x) catch @panic("abs failed");
}

pub fn nextPow2(x: u32) u32 {
    return std.math.ceilPowerOfTwo(u32, x) catch @panic("nextPow2 failed");
}

pub fn numDigits(x: f64) u32 {
    if (x == 0) {
        return 1;
    }
    return @floor(std.math.log10(x)) + 1;
}
