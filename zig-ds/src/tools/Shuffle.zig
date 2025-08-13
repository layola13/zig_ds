const std = @import("std");

pub fn shuffle(comptime T: type, array: []T, rnd: std.rand.Random) void {
    var i = array.len;
    while (i > 1) {
        const j = rnd.intRangeAtMost(usize, 0, i - 1);
        i -= 1;
        const tmp = array[i];
        array[i] = array[j];
        array[j] = tmp;
    }
}
