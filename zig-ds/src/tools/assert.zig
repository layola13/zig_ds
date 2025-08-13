const std = @import("std");

pub fn assert(condition: bool, comptime message: []const u8) void {
    if (std.debug.runtime_safety) {
        if (!condition) {
            @panic(message);
        }
    }
}

test "assert" {
    assert(true, "This should not panic");

    // The following would panic in Debug or ReleaseSafe mode:
    // assert(false, "This should panic");
}