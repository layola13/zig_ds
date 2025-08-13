const std = @import("std");

pub fn DllNode(comptime T: type) type {
    return struct {
        pub const Self = @This();

        val: T,
        next: ?*Self,
        prev: ?*Self,

        pub fn init(val: T) Self {
            return .{
                .val = val,
                .next = null,
                .prev = null,
            };
        }
    };
}
