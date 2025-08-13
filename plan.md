# 测试计划

我将把 Haxe 测试逐个移植到 Zig。我将从 `TestArrayList.zig` 开始，然后继续处理其他测试文件。

## `build.zig` 修改

我将修改 `build.zig` 文件以包含新的测试。我将为每个测试文件创建一个新的模块，然后将该模块添加到一个新的测试步骤中。

```zig
const test_array_list_module = b.addModule("test_array_list", .{
    .root_source_file = b.path("src/test/TestArrayList.zig"),
    .target = target,
    .optimize = optimize,
});

const test_array_list = b.addTest(.{
    .root_module = test_array_list_module,
    .target = target,
    .optimize = optimize,
});
test_array_list.addModule("zig-ds", module);

const run_test_array_list = b.addRunArtifact(test_array_list);

const test_step = b.step("test", "Run unit tests");
test_step.dependOn(&run_test_array_list.step);
```

## 测试文件

我将创建以下测试文件：

*   `zig-ds/src/test/TestArrayList.zig`
*   `zig-ds/src/test/TestArrayTools.zig`
*   `zig-ds/src/test/TestBitfield.zig`
*   `zig-ds/src/test/TestBits.zig`
*   `zig-ds/src/test/TestBitVector.zig`
*   `zig-ds/src/test/TestBst.zig`
*   `zig-ds/src/test/TestCompare.zig`
*   `zig-ds/src/test/TestDll.zig`
*   `zig-ds/src/test/TestFreeList.zig`
*   `zig-ds/src/test/TestGraph.zig`
*   `zig-ds/src/test/TestHashMap.zig`
*   `zig-ds/src/test/TestHashSet.zig`
*   `zig-ds/src/test/TestHashTable.zig`
*   `zig-ds/src/test/TestHeap.zig`
*   `zig-ds/src/test/TestIntHashSet.zig`
*   `zig-ds/src/test/TestIntHashTable.zig`
*   `zig-ds/src/test/TestIntIntHashTable.zig`
*   `zig-ds/src/test/TestListSet.zig`
*   `zig-ds/src/test/TestNativeArray.zig`
*   `zig-ds/src/test/TestObjectPool.zig`
*   `zig-ds/src/test/TestPriorityQueue.zig`
*   `zig-ds/src/test/TestRadixSort.zig`
*   `zig-ds/src/test/TestSll.zig`
*   `zig-ds/src/test/TestTree.zig`