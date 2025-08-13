const std = @import("std");

var gKey: u64 = 0;

pub fn next() u64 {
    gKey += 1;
    return gKey;
}

test "HashKey" {
    const key1 = next();
    const key2 = next();
    try std.testing.expect(key1 == 1);
    try std.testing.expect(key2 == 2);
}
