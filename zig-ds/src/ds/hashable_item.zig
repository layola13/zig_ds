const std = @import("std");
const hash_key = @import("hash_key.zig");

pub const HashableItem = struct {
    key: u64,

    pub fn init() @This() {
        return .{ .key = hash_key.next() };
    }
};

test "HashableItem" {
    const item1 = HashableItem.init();
    const item2 = HashableItem.init();
    try std.testing.expect(item1.key != item2.key);
}
