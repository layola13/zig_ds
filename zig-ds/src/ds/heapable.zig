const std = @import("std");

/// A type is Heapable if it has a `pos` field of type i32.
pub fn isHeapable(comptime T: type) bool {
    return @hasField(T, "pos") and @TypeOf(@field(T, "pos")) == i32;
}

test "isHeapable" {
    const MyType = struct {
        pos: i32,
    };

    const NotHeapable = struct {};

    try std.testing.expect(isHeapable(MyType));
    try std.testing.expect(!isHeapable(NotHeapable));
}
