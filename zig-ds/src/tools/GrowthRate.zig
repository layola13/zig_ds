const std = @import("std");

pub const GrowthRate = enum {
    FIXED,
    MILD,
    NORMAL,
    DOUBLE,
};

pub fn compute(rate: GrowthRate, capacity: usize) usize {
    return switch (rate) {
        .FIXED => @panic("out of space"),
        .MILD => {
            const new_size = capacity + 1;
            var cap = (new_size >> 3) + (if (new_size < 9) 3 else 6);
            cap += new_size;
            return cap;
        },
        .NORMAL => return ((capacity * 3) >> 1) + 1,
        .DOUBLE => return capacity << 1,
    };
}
