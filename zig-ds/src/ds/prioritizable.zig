const std = @import("std");

/// A type is Prioritizable if it has a `priority` field of type i32.
pub fn isPrioritizable(comptime T: type) bool {
    return @hasField(T, "priority") and @TypeOf(@field(T, "priority")) == i32;
}

test "isPrioritizable" {
    const MyType = struct {
        priority: i32,
    };

    const NotPrioritizable = struct {};

    try std.testing.expect(isPrioritizable(MyType));
    try std.testing.expect(!isPrioritizable(NotPrioritizable));
}
