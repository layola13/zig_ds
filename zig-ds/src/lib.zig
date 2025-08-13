//! Zig Data Structures Library
//!
//! This library is a port of the Haxe polygonal-ds library to Zig.
//! It aims to provide a comprehensive set of high-performance data structures
//! for game development and other applications.

const std = @import("std");

pub const core = @import("core.zig");
pub const assert = @import("tools/assert.zig").assert;
pub const compare = @import("tools/compare.zig");

// Linear data structures
pub const ArrayList = @import("linear/ArrayList.zig").ArrayList;
// pub const SinglyLinkedList = @import("linear/SinglyLinkedList.zig");
// pub const DoublyLinkedList = @import("linear/DoublyLinkedList.zig");

// Hash-based data structures
pub const HashMap = @import("hash/HashMap.zig").HashMap;
// pub const HashSet = @import("hash/HashSet.zig");

// Trees and heaps
// pub const Bst = @import("tree/Bst.zig");
// pub const Heap = @import("heap/Heap.zig");

// Graphs
// pub const Graph = @import("graph/Graph.zig");