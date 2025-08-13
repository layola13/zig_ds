const std = @import("std");

pub fn default(comptime T: type) fn (T, T) std.math.Order {
    if (comptime @typeInfo(T) == .Int or @typeInfo(T) == .Float) {
        return std.sort.asc(T);
    } else {
        return struct {
            fn cmp(a: T, b: T) std.math.Order {
                if (a < b) return .lt;
                if (a > b) return .gt;
                return .eq;
            }
        }.cmp;
    }
}

pub fn inverse(comptime T: type, comptime cmp: fn (T, T) std.math.Order) fn (T, T) std.math.Order {
    return struct {
        fn inv(a: T, b: T) std.math.Order {
            return switch (cmp(a, b)) {
                .lt => .gt,
                .gt => .lt,
                .eq => .eq,
            };
        }
    }.inv;
}