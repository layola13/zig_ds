const std = @import("std");

pub fn alloc(comptime T: type, len: usize) []T {
    const allocator = std.heap.c_allocator;
    return allocator.alloc(T, len) catch @panic("failed to allocate array");
}

pub fn trim(comptime T: type, a: []T, len: usize) []T {
    if (a.len > len) {
        return a[0..len];
    } else {
        return a;
    }
}

pub fn swap(comptime T: type, a: []T, i: usize, j: usize) void {
    const tmp = a[i];
    a[i] = a[j];
    a[j] = tmp;
}

pub fn getFront(comptime T: type, a: []T, i: usize) T {
    swap(T, a, i, 0);
    return a[0];
}

pub fn init(comptime T: type, a: []T, val: T, first: usize, n: usize) void {
    var i = first;
    while (i < first + n) : (i += 1) {
        a[i] = val;
    }
}

pub fn blit(comptime T: type, src: []const T, srcPos: usize, dst: []T, dstPos: usize, n: usize) void {
    std.mem.copy(T, dst[dstPos..], src[srcPos..n]);
}
