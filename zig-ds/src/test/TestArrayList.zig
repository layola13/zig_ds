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
        try a.append(i);
    }

    for (0..20) |i| {
        try std.testing.expectEqual(i, a.items[i]);
    }
    try std.testing.expectEqual(@as(usize, 20), a.items.len);
    try std.testing.expect(a.capacity >= a.items.len);
}

test "reserve" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();

    for (0..5) |i| {
        try a.append(5 - i);
    }
    try a.ensureTotalCapacity(100);

    try std.testing.expectEqual(@as(usize, 100), a.capacity);
    try std.testing.expectEqual(@as(usize, 5), a.items.len);

    for (0..95) |i| {
        try a.append(i);
    }
    for (0..5) |i| {
        try std.testing.expectEqual(5 - i, a.items[i]);
    }
    for (0..95) |i| {
        try std.testing.expectEqual(i, a.items[5 + i]);
    }
}

test "init" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.resize(5, 10);

    try std.testing.expectEqual(@as(usize, 5), a.items.len);
    for (0..5) |i| {
        try std.testing.expectEqual(10, a.items[i]);
    }

    var b = ArrayList(i32).initCapacity(std.testing.allocator, 2);
    defer b.deinit();
    try b.resize(10, 10);
    try std.testing.expectEqual(@as(usize, 10), b.items.len);
    try std.testing.expectEqual(@as(usize, 10), b.capacity);
    for (0..10) |i| {
        try std.testing.expectEqual(10, b.items[i]);
    }
}

test "pack" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.resize(20, 0);
    a.pack();
    try std.testing.expectEqual(@as(usize, 20), a.items.len);
    try std.testing.expectEqual(@as(usize, 20), a.capacity);
    for (0..10) |i| {
        try a.append(i);
    }
    try std.testing.expectEqual(@as(usize, 30), a.items.len);

    var b = ArrayList(i32).init(std.testing.allocator);
    defer b.deinit();
    try b.resize(20, 0);
    b.clearRetainingCapacity();
    b.pack();
    try std.testing.expectEqual(@as(usize, 0), b.items.len);
    try std.testing.expect(b.capacity >= 0);
}

test "iter" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.resize(20, 0);
    for (a.items, 0..) |*e, i| {
        e.* = @intCast(i);
    }
    try std.testing.expectEqual(@as(usize, 20), a.items.len);
    for (0..20) |i| {
        try std.testing.expectEqual(i, a.items[i]);
    }
}

test "swap" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.append(2);
    try a.append(3);
    try std.testing.expectEqual(@as(i32, 2), a.items[0]);
    try std.testing.expectEqual(@as(i32, 3), a.items[1]);
    a.swap(0, 1);
    try std.testing.expectEqual(@as(i32, 3), a.items[0]);
    try std.testing.expectEqual(@as(i32, 2), a.items[1]);
}

test "copy" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.append(2);
    try a.append(3);
    a.items[1] = a.items[0];
    try std.testing.expectEqual(@as(i32, 2), a.items[0]);
    try std.testing.expectEqual(@as(i32, 2), a.items[1]);
}

test "front" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();

    try a.append(0);
    try std.testing.expectEqual(@as(i32, 0), a.items[0]);
    try std.testing.expectEqual(@as(usize, 1), a.items.len);

    try a.append(1);
    try std.testing.expectEqual(@as(i32, 0), a.items[0]);

    try a.insert(0, 1);
    try std.testing.expectEqual(@as(i32, 1), a.items[0]);
}

test "back" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();

    try a.append(0);
    try std.testing.expectEqual(@as(i32, 0), a.items[a.items.len - 1]);
    try std.testing.expectEqual(@as(usize, 1), a.items.len);

    try a.append(1);
    try std.testing.expectEqual(@as(i32, 1), a.items[a.items.len - 1]);
}

test "popFront" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.resize(5, 0);
    for (a.items, 0..) |*e, i| {
        e.* = @intCast(i);
    }
    const x = a.orderedRemove(0);
    try std.testing.expectEqual(@as(i32, 0), x);
    try std.testing.expectEqual(@as(usize, 4), a.items.len);
    for (0..4) |i| {
        try std.testing.expectEqual(i + 1, a.items[i]);
    }

    var b = ArrayList(i32).init(std.testing.allocator);
    defer b.deinit();
    try b.append(1);
    const y = b.orderedRemove(0);
    try std.testing.expectEqual(@as(i32, 1), y);
    try std.testing.expectEqual(@as(usize, 0), b.items.len);
}

test "pushFront" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.resize(5, 0);
    for (a.items, 0..) |*e, i| {
        e.* = @intCast(i);
    }
    try a.insert(0, 10);
    try std.testing.expectEqual(@as(usize, 6), a.items.len);
    try std.testing.expectEqual(@as(i32, 10), a.items[0]);
    for (0..5) |i| {
        try std.testing.expectEqual(i, a.items[i + 1]);
    }

    var b = ArrayList(i32).init(std.testing.allocator);
    defer b.deinit();
    try b.insert(0, 10);
    try std.testing.expectEqual(@as(usize, 1), b.items.len);
    try std.testing.expectEqual(@as(i32, 10), b.items[0]);
}

test "pushBack" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.append(1);
    try std.testing.expectEqual(@as(i32, 1), a.items[a.items.len - 1]);
    try std.testing.expectEqual(@as(usize, 1), a.items.len);
    try a.append(2);
    try std.testing.expectEqual(@as(i32, 2), a.items[a.items.len - 1]);
    try std.testing.expectEqual(@as(usize, 2), a.items.len);
    try a.append(3);
    try std.testing.expectEqual(@as(i32, 3), a.items[a.items.len - 1]);
    try std.testing.expectEqual(@as(usize, 3), a.items.len);
    try std.testing.expectEqual(@as(i32, 3), a.pop());
    try std.testing.expectEqual(@as(i32, 2), a.items[a.items.len - 1]);
    try std.testing.expectEqual(@as(i32, 2), a.pop());
    try std.testing.expectEqual(@as(i32, 1), a.items[a.items.len - 1]);
    try std.testing.expectEqual(@as(i32, 1), a.pop());
    try std.testing.expectEqual(@as(usize, 0), a.items.len);
}

test "popBack" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    var x: i32 = 0;
    try a.append(x);
    try std.testing.expectEqual(@as(usize, 1), a.items.len);
    try std.testing.expectEqual(x, a.items[0]);
    try std.testing.expectEqual(x, a.pop());
    try std.testing.expectEqual(@as(usize, 0), a.items.len);
    x = 1;
    try a.append(x);
    try std.testing.expectEqual(@as(usize, 1), a.items.len);
    try std.testing.expectEqual(x, a.items[0]);
    try std.testing.expectEqual(x, a.pop());
    try std.testing.expectEqual(@as(usize, 0), a.items.len);
}

test "swapPop" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.resize(5, 0);
    for (a.items, 0..) |*e, i| {
        e.* = @intCast(i);
    }
    const x = a.swapRemove(0);
    try std.testing.expectEqual(@as(i32, 0), x);
    try std.testing.expectEqual(@as(usize, 4), a.items.len);
    try std.testing.expectEqual(@as(i32, 1), a.items[1]);
    try std.testing.expectEqual(@as(i32, 2), a.items[2]);
    try std.testing.expectEqual(@as(i32, 3), a.items[3]);

    var b = ArrayList(i32).init(std.testing.allocator);
    defer b.deinit();
    try b.append(0);
    _ = b.swapRemove(0);
    try std.testing.expectEqual(@as(usize, 0), b.items.len);

    var c = ArrayList(i32).init(std.testing.allocator);
    defer c.deinit();
    try c.append(0);
    try c.append(1);
    _ = c.swapRemove(0);
    try std.testing.expectEqual(@as(usize, 1), c.items.len);
    try std.testing.expectEqual(@as(i32, 1), c.items[0]);

    var d = ArrayList(i32).init(std.testing.allocator);
    defer d.deinit();
    try d.append(0);
    try d.append(1);
    try d.append(2);
    _ = d.swapRemove(1);
    try std.testing.expectEqual(@as(usize, 2), d.items.len);
    try std.testing.expectEqual(@as(i32, 0), d.items[0]);
    try std.testing.expectEqual(@as(i32, 2), d.items[1]);
}

test "trim" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.resize(20, 0);
    for (a.items, 0..) |*e, i| {
        e.* = @intCast(i);
    }
    a.shrink(10);
    try std.testing.expectEqual(@as(usize, 10), a.items.len);
    for (0..10) |i| {
        try std.testing.expectEqual(i, a.items[i]);
    }
}

test "insert" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.insert(0, 1);
    try std.testing.expectEqual(@as(usize, 1), a.items.len);
    try std.testing.expectEqual(@as(i32, 1), a.items[0]);

    var b = ArrayList(i32).init(std.testing.allocator);
    defer b.deinit();
    for (0..3) |i| {
        try b.append(i);
    }
    try std.testing.expectEqual(@as(usize, 3), b.items.len);

    try b.insert(0, 5);
    try std.testing.expectEqual(@as(usize, 4), b.items.len);
    try std.testing.expectEqual(@as(i32, 5), b.items[0]);
    try std.testing.expectEqual(@as(i32, 0), b.items[1]);
    try std.testing.expectEqual(@as(i32, 1), b.items[2]);
    try std.testing.expectEqual(@as(i32, 2), b.items[3]);

    var c = ArrayList(i32).init(std.testing.allocator);
    defer c.deinit();
    for (0..3) |i| {
        try c.append(i);
    }
    try std.testing.expectEqual(@as(usize, 3), c.items.len);

    try c.insert(1, 5);
    try std.testing.expectEqual(@as(usize, 4), c.items.len);
    try std.testing.expectEqual(@as(i32, 0), c.items[0]);
    try std.testing.expectEqual(@as(i32, 5), c.items[1]);
    try std.testing.expectEqual(@as(i32, 1), c.items[2]);
    try std.testing.expectEqual(@as(i32, 2), c.items[3]);

    var d = ArrayList(i32).init(std.testing.allocator);
    defer d.deinit();
    for (0..3) |i| {
        try d.append(i);
    }
    try std.testing.expectEqual(@as(usize, 3), d.items.len);

    try d.insert(2, 5);
    try std.testing.expectEqual(@as(usize, 4), d.items.len);
    try std.testing.expectEqual(@as(i32, 0), d.items[0]);
    try std.testing.expectEqual(@as(i32, 1), d.items[1]);
    try std.testing.expectEqual(@as(i32, 5), d.items[2]);
    try std.testing.expectEqual(@as(i32, 2), d.items[3]);

    var e = ArrayList(i32).init(std.testing.allocator);
    defer e.deinit();
    for (0..3) |i| {
        try e.append(i);
    }
    try std.testing.expectEqual(@as(usize, 3), e.items.len);

    try e.insert(3, 5);
    try std.testing.expectEqual(@as(usize, 4), e.items.len);
    try std.testing.expectEqual(@as(i32, 0), e.items[0]);
    try std.testing.expectEqual(@as(i32, 1), e.items[1]);
    try std.testing.expectEqual(@as(i32, 2), e.items[2]);
    try std.testing.expectEqual(@as(i32, 5), e.items[3]);

    var f = ArrayList(i32).init(std.testing.allocator);
    defer f.deinit();
    try f.insert(0, 0);
    try f.insert(1, 1);
    try std.testing.expectEqual(@as(i32, 0), f.items[0]);
    try std.testing.expectEqual(@as(i32, 1), f.items[1]);

    const s: usize = 20;
    for (0..s) |i| {
        var g = ArrayList(i32).initCapacity(std.testing.allocator, s);
        defer g.deinit();
        for (0..s) |j| {
            try g.append(j);
        }

        try g.insert(i, 100);
        for (0..i) |j| {
            try std.testing.expectEqual(j, g.items[j]);
        }
        try std.testing.expectEqual(@as(i32, 100), g.items[i]);
        var v: i32 = @intCast(i);
        for (i + 1..s + 1) |j| {
            try std.testing.expectEqual(v, g.items[j]);
            v += 1;
        }
    }
}

test "removeAt" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    for (0..3) |i| {
        try a.append(i);
    }

    for (0..3) |i| {
        try std.testing.expectEqual(i, a.orderedRemove(0));
        try std.testing.expectEqual(3 - i - 1, a.items.len);
    }
    try std.testing.expectEqual(@as(usize, 0), a.items.len);

    for (0..3) |i| {
        try a.append(i);
    }

    var size: usize = 3;
    while (a.items.len > 0) {
        _ = a.orderedRemove(a.items.len - 1);
        size -= 1;
        try std.testing.expectEqual(size, a.items.len);
    }

    try std.testing.expectEqual(@as(usize, 0), a.items.len);

    var b = ArrayList(i32).init(std.testing.allocator);
    defer b.deinit();
    try b.append(1);
    _ = b.orderedRemove(0);
    try std.testing.expectEqual(@as(usize, 0), b.items.len);

    try b.append(1);
    try b.append(2);
    try std.testing.expectEqual(@as(i32, 2), b.orderedRemove(1));
    try std.testing.expectEqual(@as(usize, 1), b.items.len);

    const len = b.capacity;
    var c = ArrayList(i32).init(std.testing.allocator);
    defer c.deinit();
    for (0..len) |i| {
        try c.append(i);
    }
    try std.testing.expectEqual(len - 1, c.orderedRemove(c.items.len - 1));
    try std.testing.expectEqual(len - 1, c.items.len);
}

test "join" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    var buf: [100]u8 = undefined;
    const writer = std.io.fixedBufferStream(&buf).writer();
    try a.join(writer, ",");
    try std.testing.expectEqualStrings("", &buf);

    try a.append(0);
    try a.join(writer, ",");
    try std.testing.expectEqualStrings("0", &buf);

    try a.append(1);
    try a.join(writer, ",");
    try std.testing.expectEqualStrings("0,1", &buf);

    try a.append(2);
    try a.join(writer, ",");
    try std.testing.expectEqualStrings("0,1,2", &buf);

    try a.append(3);
    try a.join(writer, ",");
    try std.testing.expectEqualStrings("0,1,2,3", &buf);
}

test "reverse" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.append(0);
    try a.append(1);
    a.reverse();
    try std.testing.expectEqual(@as(i32, 1), a.items[0]);
    try std.testing.expectEqual(@as(i32, 0), a.items[1]);

    var b = ArrayList(i32).init(std.testing.allocator);
    defer b.deinit();
    try b.append(0);
    try b.append(1);
    try b.append(2);
    b.reverse();
    try std.testing.expectEqual(@as(i32, 2), b.items[0]);
    try std.testing.expectEqual(@as(i32, 1), b.items[1]);
    try std.testing.expectEqual(@as(i32, 0), b.items[2]);

    var c = ArrayList(i32).init(std.testing.allocator);
    defer c.deinit();
    try c.append(0);
    try c.append(1);
    try c.append(2);
    try c.append(3);
    c.reverse();
    try std.testing.expectEqual(@as(i32, 3), c.items[0]);
    try std.testing.expectEqual(@as(i32, 2), c.items[1]);
    try std.testing.expectEqual(@as(i32, 1), c.items[2]);
    try std.testing.expectEqual(@as(i32, 0), c.items[3]);

    var d = ArrayList(i32).init(std.testing.allocator);
    defer d.deinit();
    try d.append(0);
    try d.append(1);
    try d.append(2);
    try d.append(3);
    try d.append(4);
    d.reverse();
    try std.testing.expectEqual(@as(i32, 4), d.items[0]);
    try std.testing.expectEqual(@as(i32, 3), d.items[1]);
    try std.testing.expectEqual(@as(i32, 2), d.items[2]);
    try std.testing.expectEqual(@as(i32, 1), d.items[3]);
    try std.testing.expectEqual(@as(i32, 0), d.items[4]);

    var e = ArrayList(i32).init(std.testing.allocator);
    defer e.deinit();
    for (0..27) |i| {
        try e.append(i);
    }
    e.reverse();
    for (0..27) |i| {
        try std.testing.expectEqual(26 - i, e.items[i]);
    }

    var f = ArrayList(i32).init(std.testing.allocator);
    defer f.deinit();
    for (0..4) |i| {
        try f.append(i);
    }
    f.reverse();
    for (0..4) |i| {
        try std.testing.expectEqual(3 - i, f.items[i]);
    }

    var g = ArrayList(i32).init(std.testing.allocator);
    defer g.deinit();
    try g.append(8);
    try g.append(7);
    try g.append(4);
    try g.append(2);
    try g.append(4);
    g.reverse();
    g.clearRetainingCapacity();
    try g.append(8);
    try g.append(10);
    try g.append(11);
    try g.append(3);
    g.reverse();
    try std.testing.expectEqual(@as(i32, 3), g.items[0]);
    try std.testing.expectEqual(@as(i32, 11), g.items[1]);
    try std.testing.expectEqual(@as(i32, 10), g.items[2]);
    try std.testing.expectEqual(@as(i32, 8), g.items[3]);

    var h = ArrayList(i32).initCapacity(std.testing.allocator, 10);
    defer h.deinit();
    for (0..10) |i| {
        try h.append(i);
    }
    h.reverse();
    for (0..10) |i| {
        try std.testing.expectEqual(10 - i - 1, h.items[i]);
    }

    var i = ArrayList(i32).initCapacity(std.testing.allocator, 10);
    defer i.deinit();
    for (0..10) |j| {
        try i.append(j);
    }
    i.reverseSlice(0, 5);
    for (0..5) |j| {
        try std.testing.expectEqual(5 - j - 1, i.items[j]);
    }
    for (5..10) |j| {
        try std.testing.expectEqual(j, i.items[j]);
    }

    var j = ArrayList(i32).initCapacity(std.testing.allocator, 10);
    defer j.deinit();
    for (0..10) |k| {
        try j.append(k);
    }
    j.reverseSlice(0, 1);
    try std.testing.expectEqual(@as(i32, 0), j.items[0]);
    try std.testing.expectEqual(@as(i32, 1), j.items[1]);

    var k = ArrayList(i32).initCapacity(std.testing.allocator, 10);
    defer k.deinit();
    for (0..10) |l| {
        try k.append(l);
    }
    k.reverseSlice(0, 2);
    try std.testing.expectEqual(@as(i32, 1), k.items[0]);
    try std.testing.expectEqual(@as(i32, 0), k.items[1]);

    var l = ArrayList(i32).initCapacity(std.testing.allocator, 4);
    defer l.deinit();
    for (0..4) |m| {
        try l.append(m);
    }
    l.reverseSlice(0, 2);
    try std.testing.expectEqual(@as(i32, 1), l.items[0]);
    try std.testing.expectEqual(@as(i32, 0), l.items[1]);
    try std.testing.expectEqual(@as(i32, 2), l.items[2]);
    try std.testing.expectEqual(@as(i32, 3), l.items[3]);

    var m = ArrayList(i32).init(std.testing.allocator);
    defer m.deinit();
    try m.resize(8, 0);
    for (m.items, 0..) |*item, n| {
        item.* = @intCast(n);
    }
    m.reverseSlice(4, 8);
    try std.testing.expectEqual(@as(i32, 0), m.items[0]);
    try std.testing.expectEqual(@as(i32, 1), m.items[1]);
    try std.testing.expectEqual(@as(i32, 2), m.items[2]);
    try std.testing.expectEqual(@as(i32, 3), m.items[3]);
    try std.testing.expectEqual(@as(i32, 7), m.items[4]);
    try std.testing.expectEqual(@as(i32, 6), m.items[5]);
    try std.testing.expectEqual(@as(i32, 5), m.items[6]);
    try std.testing.expectEqual(@as(i32, 4), m.items[7]);

    var n = ArrayList(i32).init(std.testing.allocator);
    defer n.deinit();
    try n.resize(8, 0);
    for (n.items, 0..) |*item, o| {
        item.* = @intCast(o);
    }
    n.reverseSlice(2, 4);
    try std.testing.expectEqual(@as(i32, 0), n.items[0]);
    try std.testing.expectEqual(@as(i32, 1), n.items[1]);
    try std.testing.expectEqual(@as(i32, 3), n.items[2]);
    try std.testing.expectEqual(@as(i32, 2), n.items[3]);
    try std.testing.expectEqual(@as(i32, 4), n.items[4]);
    try std.testing.expectEqual(@as(i32, 5), n.items[5]);
    try std.testing.expectEqual(@as(i32, 6), n.items[6]);
    try std.testing.expectEqual(@as(i32, 7), n.items[7]);
}

test "resize" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.resize(1, 0);
    try std.testing.expect(a.capacity >= 1);
    try std.testing.expectEqual(@as(usize, 1), a.items.len);

    var b = ArrayList(i32).init(std.testing.allocator);
    defer b.deinit();
    try b.resize(4, 0);
    try std.testing.expect(b.capacity >= 4);
    try std.testing.expectEqual(@as(usize, 4), b.items.len);

    var c = ArrayList(i32).init(std.testing.allocator);
    defer c.deinit();
    for (0..8) |i| {
        try c.append(i);
    }
    try c.resize(4, 0);
    try std.testing.expect(c.capacity >= 4);
    try std.testing.expectEqual(@as(usize, 4), c.items.len);
    for (0..4) |i| {
        try std.testing.expectEqual(i, c.items[i]);
    }

    var d = ArrayList(i32).initCapacity(std.testing.allocator, 8);
    defer d.deinit();
    for (0..8) |i| {
        try d.append(i);
    }
    try d.resize(4, 0);
    try std.testing.expect(d.capacity >= 8);
    try std.testing.expectEqual(@as(usize, 4), d.items.len);
    for (0..4) |i| {
        try std.testing.expectEqual(i, d.items[i]);
    }
}

test "binarySearch" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    for (0..10) |i| {
        try a.append(i);
    }

    try std.testing.expect(!a.binarySearch(10, 0, null));
    try std.testing.expect(!a.binarySearch(-100, 0, null));

    for (0..10) |i| {
        const found = a.binarySearch(i, 0, null);
        try std.testing.expect(found);
        try std.testing.expectEqual(i, found.?);
    }
    for (0..10) |i| {
        const found = a.binarySearch(i, i, null);
        try std.testing.expect(found);
        try std.testing.expectEqual(i, found.?);
    }
    for (0..9) |i| {
        try std.testing.expect(!a.binarySearch(i, i + 1, null));
    }

    var b = ArrayList(E).init(std.testing.allocator);
    defer b.deinit();

    for (0..10) |i| {
        try b.append(E{ .x = i });
    }

    for (0..10) |i| {
        const found = b.binarySearch(b.items[i], 0, E.compare);
        try std.testing.expect(found);
        try std.testing.expectEqual(i, found.?);
    }
    for (0..10) |i| {
        const found = b.binarySearch(b.items[i], i, E.compare);
        try std.testing.expect(found);
        try std.testing.expectEqual(i, found.?);
    }
    for (0..9) |i| {
        try std.testing.expect(!b.binarySearch(b.items[i], i + 1, E.compare));
    }
}

test "indexOf" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try std.testing.expect(!a.indexOf(0));
    for (0..3) |i| {
        try a.append(i);
    }
    try std.testing.expectEqual(@as(usize, 0), a.indexOf(0).?);
    try std.testing.expectEqual(@as(usize, 1), a.indexOf(1).?);
    try std.testing.expectEqual(@as(usize, 2), a.indexOf(2).?);
    try std.testing.expect(!a.indexOf(4));
}

test "lastIndexOf" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try std.testing.expect(!a.lastIndexOf(0, null));

    for (0..3) |i| {
        try a.append(i);
    }
    try std.testing.expectEqual(@as(usize, 0), a.lastIndexOf(0, null).?);
    try std.testing.expectEqual(@as(usize, 1), a.lastIndexOf(1, null).?);
    try std.testing.expectEqual(@as(usize, 2), a.lastIndexOf(2, null).?);
    try std.testing.expect(!a.lastIndexOf(4, null));

    var b = ArrayList(i32).init(std.testing.allocator);
    defer b.deinit();
    try b.append(0);
    try b.append(1);
    try b.append(2);
    try b.append(3);
    try b.append(4);
    try b.append(5);

    try std.testing.expectEqual(@as(usize, 5), b.lastIndexOf(5, null).?);
    try std.testing.expectEqual(@as(usize, 5), b.lastIndexOf(5, 5).?);

    try std.testing.expect(!b.lastIndexOf(5, 4));
    try std.testing.expect(!b.lastIndexOf(5, 1));
}

test "blit" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    for (0..20) |i| {
        try a.append(i);
    }

    a.blit(0, 10, 10);

    for (0..10) |i| {
        try std.testing.expectEqual(i + 10, a.items[i]);
    }
    for (10..20) |i| {
        try std.testing.expectEqual(i, a.items[i]);
    }

    var b = ArrayList(i32).init(std.testing.allocator);
    defer b.deinit();
    for (0..20) |i| {
        try b.append(i);
    }

    b.blit(10, 0, 10);

    for (0..10) |i| {
        try std.testing.expectEqual(i, b.items[i]);
    }
    for (10..20) |i| {
        try std.testing.expectEqual(i - 10, b.items[i]);
    }

    var c = ArrayList(i32).init(std.testing.allocator);
    defer c.deinit();
    for (0..20) |i| {
        try c.append(i);
    }

    c.blit(5, 0, 10);

    for (0..5) |i| {
        try std.testing.expectEqual(i, c.items[i]);
    }
    for (5..15) |i| {
        try std.testing.expectEqual(i - 5, c.items[i]);
    }
    for (15..20) |i| {
        try std.testing.expectEqual(i, c.items[i]);
    }
}

test "concat" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.append(0);
    try a.append(1);
    var b = ArrayList(i32).init(std.testing.allocator);
    defer b.deinit();
    try b.append(2);
    try b.append(3);
    var c = try a.clone();
    defer c.deinit();
    try c.appendSlice(b.items);
    try std.testing.expectEqual(@as(usize, 4), c.items.len);
    for (0..4) |i| {
        try std.testing.expectEqual(i, c.items[i]);
    }
    try a.appendSlice(b.items);
    try std.testing.expectEqual(@as(usize, 4), a.items.len);
    for (0..4) |i| {
        try std.testing.expectEqual(i, a.items[i]);
    }

    var d = ArrayList(i32).init(std.testing.allocator);
    defer d.deinit();
    try d.append(0);
    try d.append(1);
    var e = ArrayList(i32).init(std.testing.allocator);
    defer e.deinit();
    try e.append(2);
    try e.append(3);
    try d.appendSlice(e.items);
    try std.testing.expectEqual(@as(usize, 4), d.items.len);
    try std.testing.expectEqual(@as(usize, 2), e.items.len);
    for (0..4) |i| {
        try std.testing.expectEqual(i, d.items[i]);
    }
}

test "convert" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.appendSlice(&[_]i32{ 0, 1, 2, 3 });

    try std.testing.expectEqual(@as(usize, 4), a.items.len);
    for (0..4) |x| {
        try std.testing.expectEqual(x, a.items[x]);
    }
}

test "sortRange" {
    var d = ArrayList(i32).init(std.testing.allocator);
    defer d.deinit();
    try d.append(0);
    try d.append(1);
    try d.append(2);
    try d.append(3);
    try d.append(30);
    try d.append(20);
    try d.append(30);
    d.sort(void, std.math.order, 0, 4);

    const sorted = [_]i32{ 0, 1, 2, 3, 30, 20, 30 };
    for (d.items, 0..) |val, i| {
        try std.testing.expectEqual(sorted[i], val);
    }

    var e = ArrayList(i32).init(std.testing.allocator);
    defer e.deinit();
    try e.appendSlice(&[_]i32{ 9, 8, 1, 2, 3, 8, 9 });
    e.sort(void, std.math.order, 2, 3);

    const sorted2 = [_]i32{ 9, 8, 1, 2, 3, 8, 9 };
    for (e.items, 0..) |val, i| {
        try std.testing.expectEqual(sorted2[i], val);
    }

    var f = ArrayList(i32).init(std.testing.allocator);
    defer f.deinit();
    try f.appendSlice(&[_]i32{ 1, 2, 3 });
    f.sort(void, std.math.order, 1, 2);
    const sorted3 = [_]i32{ 1, 2, 3 };
    for (f.items, 0..) |val, i| {
        try std.testing.expectEqual(sorted3[i], val);
    }
}

test "sort" {
    var v = ArrayList(i32).init(std.testing.allocator);
    defer v.deinit();
    try v.append(4);
    v.sort(void, std.math.order, 0, v.items.len);
    try std.testing.expectEqual(@as(i32, 4), v.items[0]);

    var w = ArrayList(E).init(std.testing.allocator);
    defer w.deinit();
    try w.append(E{ .x = 4 });
    w.sort(void, E.compare, 0, w.items.len);
    try std.testing.expectEqual(@as(i32, 4), w.items[0].x);

    var x = ArrayList(i32).init(std.testing.allocator);
    defer x.deinit();
    try x.append(4);
    try x.append(2);
    x.sort(void, std.math.order, 0, x.items.len);
    try std.testing.expectEqual(@as(i32, 2), x.items[0]);
    try std.testing.expectEqual(@as(i32, 4), x.items[1]);

    var y = ArrayList(E).init(std.testing.allocator);
    defer y.deinit();
    try y.append(E{ .x = 4 });
    try y.append(E{ .x = 2 });
    y.sort(void, E.compare, 0, y.items.len);
    try std.testing.expectEqual(@as(i32, 2), y.items[0].x);
    try std.testing.expectEqual(@as(i32, 4), y.items[1].x);

    var z = ArrayList(i32).init(std.testing.allocator);
    defer z.deinit();
    try z.append(4);
    try z.append(1);
    try z.append(7);
    try z.append(3);
    try z.append(2);
    z.sort(void, std.math.order, 0, z.items.len);
    try std.testing.expectEqual(@as(i32, 1), z.items[0]);
    var j: i32 = 0;
    for (z.items) |i| {
        try std.testing.expect(i > j);
        j = i;
    }

    var aa = ArrayList(E).init(std.testing.allocator);
    defer aa.deinit();
    try aa.append(E{ .x = 4 });
    try aa.append(E{ .x = 1 });
    try aa.append(E{ .x = 7 });
    try aa.append(E{ .x = 3 });
    try aa.append(E{ .x = 2 });
    aa.sort(void, E.compare, 0, aa.items.len);
    try std.testing.expectEqual(@as(i32, 1), aa.items[0].x);
    var k: i32 = 0;
    for (aa.items) |i| {
        try std.testing.expect(i.x > k);
        k = i.x;
    }
}

test "shuffle" {
    var q = ArrayList(i32).init(std.testing.allocator);
    defer q.deinit();
    try q.resize(10, 0);
    for (q.items, 0..) |*e, i| {
        e.* = @intCast(i);
    }
    var prng = std.rand.DefaultPrng.init(0);
    const rnd = prng.random();
    Shuffle(i32, q.items, rnd);
    try std.testing.expectEqual(@as(usize, 10), q.items.len);
    var set = std.ArrayList(i32).init(std.testing.allocator);
    defer set.deinit();
    for (0..10) |i| {
        try std.testing.expect(!set.contains(q.items[i]));
        try set.append(q.items[i]);
    }
    set.sort(void, std.math.order, 0, set.items.len);
    for (0..10) |i| {
        try std.testing.expectEqual(i, set.items[i]);
    }
}

test "iterator" {
    var q = ArrayList(i32).init(std.testing.allocator);
    defer q.deinit();
    for (0..10) |i| {
        try q.append(i);
    }

    var c: i32 = 0;
    var it = q.iterator();
    while (it.next()) |val| {
        try std.testing.expectEqual(c, val.*);
        c += 1;
    }
    try std.testing.expectEqual(c, 10);

    c = 0;
    it.reset();
    while (it.next()) |val| {
        try std.testing.expectEqual(c, val.*);
        c += 1;
    }
    try std.testing.expectEqual(c, 10);
}

test "iteratorRemove" {
    for (0..5) |i| {
        var a = ArrayList(i32).init(std.testing.allocator);
        defer a.deinit();
        var set = HashSet(i32).init(std.testing.allocator);
        defer set.deinit();
        for (0..5) |j| {
            try a.append(j);
            if (i != j) {
                try set.put(j);
            }
        }

        var it = a.iterator();
        while (it.next()) |val| {
            if (val.* == i) {
                it.remove();
            }
        }

        while (a.items.len > 0) {
            const val = a.pop();
            try std.testing.expect(set.contains(val));
            _ = set.remove(val);
        }
        try std.testing.expect(set.count() == 0);
    }

    var b = ArrayList(i32).init(std.testing.allocator);
    defer b.deinit();
    for (0..5) |j| {
        try b.append(j);
    }

    var it = b.iterator();
    while (it.next()) |_| {
        it.remove();
    }
    try std.testing.expect(b.items.len == 0);
}

test "remove" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.appendSlice(&[_]i32{ 0, 1, 2, 2, 2, 3 });

    try std.testing.expectEqual(@as(usize, 6), a.items.len);

    var k = a.removeItem(0);
    try std.testing.expect(k);
    try std.testing.expectEqual(@as(usize, 5), a.items.len);

    k = a.removeItem(2);
    try std.testing.expect(k);
    try std.testing.expectEqual(@as(usize, 2), a.items.len);

    k = a.removeItem(1);
    try std.testing.expect(k);
    try std.testing.expectEqual(@as(usize, 1), a.items.len);

    k = a.removeItem(3);
    try std.testing.expect(k);

    try std.testing.expect(a.items.len == 0);

    var b = ArrayList(i32).init(std.testing.allocator);
    defer b.deinit();
    try b.appendSlice(&[_]i32{ 0, 0, 0, 0, 0 });
    k = b.removeItem(0);
    try std.testing.expect(k);
    try std.testing.expect(b.items.len == 0);

    var c = ArrayList(i32).init(std.testing.allocator);
    defer c.deinit();
    try c.appendSlice(&[_]i32{ 0, 1, 2, 2, 3, 3, 3 });
    _ = c.removeItem(2);
    try std.testing.expectEqual(@as(usize, 5), c.items.len);
    try std.testing.expectEqual(@as(i32, 0), c.items[0]);
    try std.testing.expectEqual(@as(i32, 1), c.items[1]);
    try std.testing.expectEqual(@as(i32, 3), c.items[2]);
    try std.testing.expectEqual(@as(i32, 3), c.items[3]);
    try std.testing.expectEqual(@as(i32, 3), c.items[4]);

    _ = c.removeItem(1);
    try std.testing.expectEqual(@as(usize, 4), c.items.len);
    try std.testing.expectEqual(@as(i32, 0), c.items[0]);
    try std.testing.expectEqual(@as(i32, 3), c.items[1]);
    try std.testing.expectEqual(@as(i32, 3), c.items[2]);
    try std.testing.expectEqual(@as(i32, 3), c.items[3]);

    _ = c.removeItem(3);
    try std.testing.expectEqual(@as(usize, 1), c.items.len);
    try std.testing.expectEqual(@as(i32, 0), c.items[0]);

    var d = ArrayList(i32).init(std.testing.allocator);
    defer d.deinit();
    try d.appendSlice(&[_]i32{ 2, 2, 2 });
    _ = d.removeItem(2);
    try std.testing.expectEqual(@as(usize, 0), d.items.len);

    var e = ArrayList(i32).init(std.testing.allocator);
    defer e.deinit();
    try e.appendSlice(&[_]i32{ 1, 1, 1, 2, 2, 2 });
    _ = e.removeItem(1);
    try std.testing.expectEqual(@as(usize, 3), e.items.len);
    try std.testing.expectEqual(@as(i32, 2), e.items[0]);
    try std.testing.expectEqual(@as(i32, 2), e.items[1]);
    try std.testing.expectEqual(@as(i32, 2), e.items[2]);
    _ = e.removeItem(2);
    try std.testing.expectEqual(@as(usize, 0), e.items.len);

    var f = ArrayList(i32).init(std.testing.allocator);
    defer f.deinit();
    try f.appendSlice(&[_]i32{ 1, 2, 3 });
    _ = f.removeItem(1);
    try std.testing.expectEqual(@as(usize, 2), f.items.len);
    try std.testing.expectEqual(@as(i32, 2), f.items[0]);
    try std.testing.expectEqual(@as(i32, 3), f.items[1]);
    _ = f.removeItem(2);
    try std.testing.expectEqual(@as(usize, 1), f.items.len);
    try std.testing.expectEqual(@as(i32, 3), f.items[0]);
    _ = f.removeItem(3);
    try std.testing.expectEqual(@as(usize, 0), f.items.len);
}

test "clone" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    for (0..3) |i| {
        try a.append(i);
    }
    var copy = try a.clone();
    defer copy.deinit();
    try std.testing.expectEqual(@as(usize, 3), copy.items.len);
    for (0..3) |i| {
        try std.testing.expectEqual(i, copy.items[i]);
    }

    var b = ArrayList(E).init(std.testing.allocator);
    defer b.deinit();
    for (0..3) |i| {
        try b.append(E{ .x = i });
    }
    var copy2 = try b.clone();
    defer copy2.deinit();
    try std.testing.expectEqual(@as(usize, 3), copy2.items.len);
    for (0..3) |i| {
        try std.testing.expectEqual(i, copy2.items[i].x);
    }
}

test "range" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.appendSlice(&[_]i32{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 });

    var b = try a.getRange(0, 5);
    defer b.deinit();
    try std.testing.expectEqual(@as(usize, 5), b.items.len);
    for (0..5) |i| {
        try std.testing.expectEqual(i, b.items[i]);
    }

    var c = try a.getRange(0, -5);
    defer c.deinit();
    try std.testing.expectEqual(@as(usize, 5), c.items.len);
    for (0..5) |i| {
        try std.testing.expectEqual(i, c.items[i]);
    }

    var d = try a.getRange(1, 1);
    defer d.deinit();
    try std.testing.expectEqual(@as(usize, 0), d.items.len);

    var e = try a.getRange(8, -1);
    defer e.deinit();
    try std.testing.expectEqual(@as(usize, 1), e.items.len);
    try std.testing.expectEqual(@as(i32, 8), e.items[0]);
}

test "of" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.resize(3, 0);
    a.items[0] = 0;
    a.items[1] = 1;
    a.items[2] = 2;
    var b = ArrayList(i32).init(std.testing.allocator);
    defer b.deinit();
    try b.appendSlice(a.items);

    try std.testing.expectEqual(@as(usize, 3), b.items.len);
    for (0..3) |i| {
        try std.testing.expectEqual(i, b.items[i]);
    }
    var c = ArrayList(i32).init(std.testing.allocator);
    defer c.deinit();
    var d = ArrayList(i32).init(std.testing.allocator);
    defer d.deinit();
    try d.appendSlice(c.items);
    try std.testing.expect(d.items.len == 0);
}

test "addArray" {
    var a = ArrayList(i32).init(std.testing.allocator);
    defer a.deinit();
    try a.appendSlice(&[_]i32{ 1, 2, 3 });
    try std.testing.expectEqual(@as(usize, 3), a.items.len);
    try std.testing.expectEqual(@as(i32, 1), a.items[0]);
    try std.testing.expectEqual(@as(i32, 2), a.items[1]);
    try std.testing.expectEqual(@as(i32, 3), a.items[2]);

    var b = ArrayList(i32).init(std.testing.allocator);
    defer b.deinit();
    const arr_b = [_]i32{ 1, 2, 3 };
    try b.appendSlice(arr_b[1..]);
    try std.testing.expectEqual(@as(usize, 2), b.items.len);
    try std.testing.expectEqual(@as(i32, 2), b.items[0]);
    try std.testing.expectEqual(@as(i32, 3), b.items[1]);

    var c = ArrayList(i32).init(std.testing.allocator);
    defer c.deinit();
    const arr_c = [_]i32{ 1, 2, 3 };
    try c.appendSlice(arr_c[2..]);
    try std.testing.expectEqual(@as(usize, 1), c.items.len);
    try std.testing.expectEqual(@as(i32, 3), c.items[0]);

    var d = ArrayList(i32).init(std.testing.allocator);
    defer d.deinit();
    const arr_d = [_]i32{ 1, 2, 3 };
    try d.appendSlice(arr_d[0..2]);
    try std.testing.expectEqual(@as(usize, 2), d.items.len);
    try std.testing.expectEqual(@as(i32, 1), d.items[0]);
    try std.testing.expectEqual(@as(i32, 2), d.items[1]);

    var e = ArrayList(i32).initCapacity(std.testing.allocator, 2);
    defer e.deinit();
    try e.appendSlice(&[_]i32{ 1, 2, 3, 4 });
}
