const std = @import("std");
const ds = @import("../ds/ds.zig");

pub fn alloc(comptime T: type, allocator: std.mem.Allocator, len: usize) ![]T {
    return allocator.alloc(T, len);
}

pub fn get(comptime T: type, a: []const T, i: usize) T {
    return a[i];
}

pub fn set(comptime T: type, a: []T, i: usize, x: T) void {
    a[i] = x;
}

pub fn size(comptime T: type, a: []const T) usize {
    return a.len;
}

pub fn blit(comptime T: type, src: []const T, src_pos: usize, dest: []T, dest_pos: usize, len: usize) void {
    std.mem.copy(T, dest[dest_pos..], src[src_pos..][0..len]);
}

pub fn copy(comptime T: type, a: []const T) ![]T {
    const allocator = std.heap.page_allocator;
    const b = try allocator.alloc(T, a.len);
    @memcpy(b, a);
    return b;
}

pub fn zero(comptime T: type, a: []T, pos: usize, len: usize) void {
    std.mem.set(T, a[pos..][0..len], .{0});
}

pub fn init(comptime T: type, a: []T, pos: usize, len: usize, val: T) void {
    for (a[pos..][0..len]) |*item| {
        item.* = val;
    }
}

pub fn nullify(comptime T: type, a: []?T, pos: usize, len: usize) void {
    init(?T, a, pos, len, null);
}
