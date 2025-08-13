# `ArrayedDeque` 功能差异报告

本文档详细对比了 Haxe (`src/ds/ArrayedDeque.hx`) 和 Zig (`zig-ds/src/linear/ArrayedDeque.zig`) 中 `ArrayedDeque` 的实现，并列出了 Zig 版本需要补全的功能。

| 分类 | Haxe (`ArrayedDeque.hx`) | Zig (`ArrayedDeque.zig`) | 状态 | 缺失/待办事项 |
| :--- | :--- | :--- | :--- | :--- |
| **核心功能** | `pushFront`, `popFront`, `pushBack`, `popBack` | `pushFront`, `popFront`, `pushBack`, `popBack` | ✅ 已实现 | - |
| **元素查看** | `front()`, `back()` | - | ❌ **缺失** | 实现 `front()` 和 `back()` 以查看元素而不移除。 |
| **索引访问** | `getFront(i)`, `getBack(i)` | - | ❌ **缺失** | 实现按索引访问的功能。 |
| **搜索** | `contains(val)`, `indexOfFront(val)`, `indexOfBack(val)` | - | ❌ **缺失** | 实现 `contains` 和 `indexOf` 功能。 |
| **迭代** | `iterator()`, `forEach()`, `iter()` | - | ❌ **缺失** | 实现一个标准的 Zig 迭代器。 |
| **内存管理** | `pack()`, Block Pooling (`getBlock`, `putBlock`) | - | ❌ **缺失** | 实现 `pack()` 以整理内存，并考虑添加块对象池以提高性能。 |
| **高级操作** | `remove(val)`, `clear()`, `clone()` | `deinit()` | ❌ **缺失** | 实现 `remove`, `clear`, 和 `clone` 功能。 |
| **辅助功能** | `isEmpty()`, `toArray()`, `toString()` | `size()` | ❌ **缺失** | 实现 `isEmpty`, `toArray` 和一个合适的格式化输出函数。 |
| **构造/初始化** | `new(blockSize, blockPoolCapacity, source)` | `init(block_size)` | ❌ **缺失** | 增强 `init` 函数，使其支持从一个 slice 初始化。 |
