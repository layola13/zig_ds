const std = @import("std");
const lib = @import("zig-ds");
const ArrayList = lib.ArrayList;
const Shuffle = lib.ds.Shuffle;
const HashSet = lib.ds.HashSet;

const E = struct {
    x: i32,

    pub fn compare(context: void, a: E, b: E) std.math.Order {
        _ = context;
        return std.math.order(a.x, b.x);
    }
};

test "basic" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();

    for (0..20) |i| {
        try a.append(@intCast(i));
    }

    for (0..20) |i| {
        try std.testing.expectEqual(@as(i32, i), a.get(@intCast(i)));
    }
    try std.testing.expectEqual(@as(usize, 20), a.len());
}

test "popBack" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    var x: i32 = 0;
    try a.append(x);
    try std.testing.expectEqual(@as(usize, 1), a.len());
    try std.testing.expectEqual(x, a.get(0));
    try std.testing.expectEqual(x, a.popBack().?);
    try std.testing.expectEqual(@as(usize, 0), a.len());
    x = 1;
    try a.append(x);
    try std.testing.expectEqual(@as(usize, 1), a.len());
    try std.testing.expectEqual(x, a.get(0));
    try std.testing.expectEqual(x, a.popBack().?);
    try std.testing.expectEqual(@as(usize, 0), a.len());
}

test "removeAt" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    for (0..3) |i| {
        try a.append(@intCast(i));
    }

    for (0..3) |i| {
        try std.testing.expectEqual(@as(i32, i), a.removeAt(0));
        try std.testing.expectEqual(3 - i - 1, a.len());
    }
    try std.testing.expectEqual(@as(usize, 0), a.len());

    for (0..3) |i| {
        try a.append(@intCast(i));
    }

    var size: usize = 3;
    while (a.len() > 0) {
        _ = a.removeAt(@intCast(a.len() - 1));
        size -= 1;
        try std.testing.expectEqual(size, a.len());
    }
}