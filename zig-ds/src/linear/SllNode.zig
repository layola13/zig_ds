const std = @import("std");

pub fn SllNode(comptime T: type) type {
    return struct {
        pub const Self = @This();

        val: T,
        next: ?*Self,

        pub fn init(val: T) Self {
            return .{
                .val = val,
                .next = null,
            };
        }
    };
}
