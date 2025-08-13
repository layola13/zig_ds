const std = @import("std");
const Allocator = std.mem.Allocator;

/// Defines the required interface for a type to be considered a collection.
/// This is a compile-time concept using duck typing. A type `T` is a Collection
/// if it provides the functions defined here.
pub fn Collection(comptime T: type) type {
    return struct {
        pub const Self = T;
        pub const Item = @TypeOf(Self.items).Child;

        pub fn size(self: *const Self) usize {
            return self.items.len;
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.items.len == 0;
        }

        // Other functions like `contains`, `remove`, `clear`, `iterator`
        // will be defined on the concrete types.
        // This struct serves as a conceptual
    };
}