const std = @import("std");
const Stack = @import("../ds/stack.zig").Stack;
const Collection = @import("../ds/collection.zig").Collection;

pub fn ArrayedStack(comptime T: type, allocator: std.mem.Allocator) type {
    return struct {
        const Self = @This();

        items: std.ArrayList(T),

        pub fn init() Self {
            return .{
                .items = std.ArrayList(T).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.items.deinit();
        }

        pub fn push(self: *Self, item: T) !void {
            try self.items.append(item);
        }

        pub fn pop(self: *Self) ?T {
            return self.items.popOrNull();
        }

        pub fn top(self: *const Self) ?T {
            if (self.items.items.len == 0) {
                return null;
            }
            return self.items.items[self.items.items.len - 1];
        }

        pub fn size(self: *const Self) usize {
            return self.items.items.len;
        }
    };
}

test "ArrayedStack" {
    var stack = ArrayedStack(i32, std.testing.allocator).init();
    defer stack.deinit();

    try stack.push(10);
    try stack.push(20);
    try stack.push(30);

    try std.testing.expectEqual(@as(usize, 3), stack.size());
    try std.testing.expectEqual(@as(i32, 30), stack.top().?);

    const popped = stack.pop();
    try std.testing.expectEqual(@as(i32, 30), popped.?);
    try std.testing.expectEqual(@as(usize, 2), stack.size());
    try std.testing.expectEqual(@as(i32, 20), stack.top().?);
}
