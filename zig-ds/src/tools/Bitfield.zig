const std = @import("std");

pub const Bitfield = struct {
    val: u32,

    pub fn init() Bitfield {
        return Bitfield{ .val = 0 };
    }

    pub fn ofMask(numBits: u32) Bitfield {
        return Bitfield{ .val = (1 << numBits) - 1 };
    }

    pub fn set(self: *Bitfield, i: u32) void {
        self.val |= (1 << i);
    }

    pub fn unset(self: *Bitfield, i: u32) void {
        self.val &= ~(1 << i);
    }

    pub fn any(self: Bitfield, i: u32) bool {
        return (self.val & (1 << i)) != 0;
    }

    pub fn all(self: Bitfield, i: u32) bool {
        return (self.val & (1 << i)) == (1 << i);
    }

    pub fn flip(self: *Bitfield, i: u32) void {
        self.val ^= (1 << i);
    }

    pub fn get(self: Bitfield, i: u32) bool {
        return (self.val & (1 << i)) != 0;
    }

    pub fn setVal(self: *Bitfield, i: u32, b: bool) void {
        if (b) {
            self.set(i);
        } else {
            self.unset(i);
        }
    }
};
