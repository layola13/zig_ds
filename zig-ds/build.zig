const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("zig-ds", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    const ds_tools_mem_module = b.addModule("ds_tools_mem", .{
        .root_source_file = b.path("src/ds/tools/mem.zig"),
    });
    module.addImport("ds_tools_mem", ds_tools_mem_module);

    const ds_linear_list_module = b.addModule("ds_linear_list", .{
        .root_source_file = b.path("src/ds/linear/list.zig"),
    });
    module.addImport("ds_linear_list", ds_linear_list_module);

    const ds_linear_queue_module = b.addModule("ds_linear_queue", .{
        .root_source_file = b.path("src/ds/linear/queue.zig"),
    });
    module.addImport("ds_linear_queue", ds_linear_queue_module);

    const ds_linear_stack_module = b.addModule("ds_linear_stack", .{
        .root_source_file = b.path("src/ds/linear/stack.zig"),
    });
    module.addImport("ds_linear_stack", ds_linear_stack_module);

    const ds_linear_deque_module = b.addModule("ds_linear_deque", .{
        .root_source_file = b.path("src/ds/linear/deque.zig"),
    });
    module.addImport("ds_linear_deque", ds_linear_deque_module);

    const ds_tools_mem_memory_access_module = b.addModule("ds_tools_mem_memory_access", .{
        .root_source_file = b.path("src/ds/tools/mem/memory_access.zig"),
    });
    module.addImport("ds_tools_mem_memory_access", ds_tools_mem_memory_access_module);

    const ds_linear_sll_module = b.addModule("ds_linear_sll", .{
        .root_source_file = b.path("src/linear/Sll.zig"),
    });
    module.addImport("ds_linear_sll", ds_linear_sll_module);

    const ds_linear_dll_module = b.addModule("ds_linear_dll", .{
        .root_source_file = b.path("src/linear/Dll.zig"),
    });
    module.addImport("ds_linear_dll", ds_linear_dll_module);

    const ds_linear_arrayed_queue_module = b.addModule("ds_linear_arrayed_queue", .{
        .root_source_file = b.path("src/linear/ArrayedQueue.zig"),
    });
    module.addImport("ds_linear_arrayed_queue", ds_linear_arrayed_queue_module);

    const ds_linear_arrayed_stack_module = b.addModule("ds_linear_arrayed_stack", .{
        .root_source_file = b.path("src/linear/ArrayedStack.zig"),
    });
    module.addImport("ds_linear_arrayed_stack", ds_linear_arrayed_stack_module);

    const ds_linear_arrayed_deque_module = b.addModule("ds_linear_arrayed_deque", .{
        .root_source_file = b.path("src/linear/ArrayedDeque.zig"),
    });
    module.addImport("ds_linear_arrayed_deque", ds_linear_arrayed_deque_module);

    const ds_linear_linked_queue_module = b.addModule("ds_linear_linked_queue", .{
        .root_source_file = b.path("src/linear/LinkedQueue.zig"),
    });
    module.addImport("ds_linear_linked_queue", ds_linear_linked_queue_module);

    const ds_linear_linked_stack_module = b.addModule("ds_linear_linked_stack", .{
        .root_source_file = b.path("src/linear/LinkedStack.zig"),
    });
    module.addImport("ds_linear_linked_stack", ds_linear_linked_stack_module);

    const ds_linear_linked_deque_module = b.addModule("ds_linear_linked_deque", .{
        .root_source_file = b.path("src/linear/LinkedDeque.zig"),
    });
    module.addImport("ds_linear_linked_deque", ds_linear_linked_deque_module);

    const ds_tree_heap_module = b.addModule("ds_tree_heap", .{
        .root_source_file = b.path("src/tree/Heap.zig"),
    });
    module.addImport("ds_tree_heap", ds_tree_heap_module);

    const ds_tree_priority_queue_module = b.addModule("ds_tree_priority_queue", .{
        .root_source_file = b.path("src/tree/PriorityQueue.zig"),
    });
    module.addImport("ds_tree_priority_queue", ds_tree_priority_queue_module);

    const ds_misc_bit_vector_module = b.addModule("ds_misc_bit_vector", .{
        .root_source_file = b.path("src/misc/BitVector.zig"),
    });
    module.addImport("ds_misc_bit_vector", ds_misc_bit_vector_module);

    const ds_hash_hash_table_module = b.addModule("ds_hash_hash_table", .{
        .root_source_file = b.path("src/hash/HashTable.zig"),
    });
    module.addImport("ds_hash_hash_table", ds_hash_hash_table_module);

    const ds_hash_hash_set_module = b.addModule("ds_hash_hash_set", .{
        .root_source_file = b.path("src/hash/HashSet.zig"),
    });
    module.addImport("ds_hash_hash_set", ds_hash_hash_set_module);

    const ds_hash_int_hash_table_module = b.addModule("ds_hash_int_hash_table", .{
        .root_source_file = b.path("src/hash/IntHashTable.zig"),
    });
    module.addImport("ds_hash_int_hash_table", ds_hash_int_hash_table_module);

    const ds_hash_int_hash_set_module = b.addModule("ds_hash_int_hash_set", .{
        .root_source_file = b.path("src/hash/IntHashSet.zig"),
    });
    module.addImport("ds_hash_int_hash_set", ds_hash_int_hash_set_module);

    const ds_hash_int_int_hash_table_module = b.addModule("ds_hash_int_int_hash_table", .{
        .root_source_file = b.path("src/hash/IntIntHashTable.zig"),
    });
    module.addImport("ds_hash_int_int_hash_table", ds_hash_int_int_hash_table_module);

    const ds_hash_list_set_module = b.addModule("ds_hash_list_set", .{
        .root_source_file = b.path("src/hash/ListSet.zig"),
    });
    module.addImport("ds_hash_list_set", ds_hash_list_set_module);

    const ds_tree_tree_node_module = b.addModule("ds_tree_tree_node", .{
        .root_source_file = b.path("src/tree/TreeNode.zig"),
    });
    module.addImport("ds_tree_tree_node", ds_tree_tree_node_module);

    const ds_tree_binary_tree_node_module = b.addModule("ds_tree_binary_tree_node", .{
        .root_source_file = b.path("src/tree/BinaryTreeNode.zig"),
    });
    module.addImport("ds_tree_binary_tree_node", ds_tree_binary_tree_node_module);

    const ds_tree_bst_module = b.addModule("ds_tree_bst", .{
        .root_source_file = b.path("src/tree/Bst.zig"),
    });
    module.addImport("ds_tree_bst", ds_tree_bst_module);

    const ds_tree_tree_builder_module = b.addModule("ds_tree_tree_builder", .{
        .root_source_file = b.path("src/tree/TreeBuilder.zig"),
    });
    module.addImport("ds_tree_tree_builder", ds_tree_tree_builder_module);

    const ds_graph_graph_arc_module = b.addModule("ds_graph_graph_arc", .{
        .root_source_file = b.path("src/graph/GraphArc.zig"),
    });
    module.addImport("ds_graph_graph_arc", ds_graph_graph_arc_module);

    const ds_graph_graph_node_module = b.addModule("ds_graph_graph_node", .{
        .root_source_file = b.path("src/graph/GraphNode.zig"),
    });
    module.addImport("ds_graph_graph_node", ds_graph_graph_node_module);

    const ds_graph_graph_module = b.addModule("ds_graph_graph", .{
        .root_source_file = b.path("src/graph/Graph.zig"),
    });
    module.addImport("ds_graph_graph", ds_graph_graph_module);

    const ds_tools_array_tools_module = b.addModule("ds_tools_array_tools", .{
        .root_source_file = b.path("src/tools/ArrayTools.zig"),
    });
    module.addImport("ds_tools_array_tools", ds_tools_array_tools_module);

    const ds_tools_bits_module = b.addModule("ds_tools_bits", .{
        .root_source_file = b.path("src/tools/Bits.zig"),
    });
    module.addImport("ds_tools_bits", ds_tools_bits_module);

    const ds_tools_bitfield_module = b.addModule("ds_tools_bitfield", .{
        .root_source_file = b.path("src/tools/Bitfield.zig"),
    });
    module.addImport("ds_tools_bitfield", ds_tools_bitfield_module);

    const ds_tools_free_list_module = b.addModule("ds_tools_free_list", .{
        .root_source_file = b.path("src/tools/FreeList.zig"),
    });
    module.addImport("ds_tools_free_list", ds_tools_free_list_module);

    const ds_tools_growth_rate_module = b.addModule("ds_tools_growth_rate", .{
        .root_source_file = b.path("src/tools/GrowthRate.zig"),
    });
    module.addImport("ds_tools_growth_rate", ds_tools_growth_rate_module);

    const ds_tools_math_tools_module = b.addModule("ds_tools_math_tools", .{
        .root_source_file = b.path("src/tools/MathTools.zig"),
    });
    module.addImport("ds_tools_math_tools", ds_tools_math_tools_module);

    const ds_tools_native_array_module = b.addModule("ds_tools_native_array", .{
        .root_source_file = b.path("src/tools/NativeArray.zig"),
    });
    module.addImport("ds_tools_native_array", ds_tools_native_array_module);

    const ds_tools_native_array_tools_module = b.addModule("ds_tools_native_array_tools", .{
        .root_source_file = b.path("src/tools/NativeArrayTools.zig"),
    });
    module.addImport("ds_tools_native_array_tools", ds_tools_native_array_tools_module);

    const ds_tools_object_pool_module = b.addModule("ds_tools_object_pool", .{
        .root_source_file = b.path("src/tools/ObjectPool.zig"),
    });
    module.addImport("ds_tools_object_pool", ds_tools_object_pool_module);

    const ds_tools_radix_sort_module = b.addModule("ds_tools_radix_sort", .{
        .root_source_file = b.path("src/tools/RadixSort.zig"),
    });
    module.addImport("ds_tools_radix_sort", ds_tools_radix_sort_module);

    const ds_tools_shuffle_module = b.addModule("ds_tools_shuffle", .{
        .root_source_file = b.path("src/tools/Shuffle.zig"),
    });
    module.addImport("ds_tools_shuffle", ds_tools_shuffle_module);

    const lib_unit_tests = b.addTest(.{ .root_module = module });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    const test_array_list_mod = b.addModule("test_array_list", .{
        .root_source_file = b.path("src/test/TestArrayList.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_array_list_mod.addImport("zig-ds", module);

    // Fixed: Removed target and optimize from TestOptions
    const test_array_list = b.addTest(.{
        .root_module = test_array_list_mod,
    });

    const run_test_array_list = b.addRunArtifact(test_array_list);
    test_step.dependOn(&run_test_array_list.step);
}
