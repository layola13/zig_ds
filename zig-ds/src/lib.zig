//! Polygonal DS Zig Port
pub const ds = @import("ds/ds.zig");

// Directly exposing common data structures for easier access
pub const ArrayList = @import("linear/ArrayList.zig").ArrayList;
