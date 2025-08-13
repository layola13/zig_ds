# Polygonal DS Haxe to Zig 重构计划

这是一个详尽的任务清单，用于将 Haxe 的 `polygonal-ds` 库完整地、一对一地重构为 Zig 语言。

---

### 阶段一：项目准备

- [x] **1.1 备份旧项目**: 将 `zig-ds` 重命名为 `zig-ds-simplified-backup`
- [x] **1.2 创建新项目**: 创建一个新的 Zig 库项目 `zig-ds`
- [x] **1.3 创建目录结构**: 在 `zig-ds/src/` 下创建 `ds/tools/mem` 目录结构

---

### 阶段二：核心接口与辅助类型移植 (已完成)

- [x] **2.1 `Cloneable.hx`** -> `ds/cloneable.zig`
- [x] **2.2 `Comparable.hx`** -> `ds/comparable.zig`
- [x] **2.3 `Collection.hx`** -> `ds/collection.zig`
- [x] **2.4 `Hashable.hx`** -> `ds/hashable.zig`
- [x] **2.5 `HashableItem.hx`** -> `ds/hashable_item.zig`
- [x] **2.6 `HashKey.hx`** -> `ds/hash_key.zig`
- [x] **2.7 `Heapable.hx`** -> `ds/heapable.zig`
- [x] **2.8 `Itr.hx`** -> `ds/itr.zig`
- [x] **2.9 `Map.hx`** -> `ds/map.zig`
- [x] **2.10 `Prioritizable.hx`** -> `ds/prioritizable.zig`
- [x] **2.11 `Set.hx`** -> `ds/set.zig`
- [x] **2.12 `Visitable.hx`** -> `ds/visitable.zig`
- [x] **2.13 `List.hx`** -> `ds/list.zig`
- [x] **2.14 `Queue.hx`** -> `ds/queue.zig`
- [x] **2.15 `Stack.hx`** -> `ds/stack.zig`
- [x] **2.16 `Deque.hx`** -> `ds/deque.zig`
- [x] **2.17 `Printf.hx`** -> `ds/printf.zig`

---

### 阶段三：内存工具移植 (`tools/mem`)
- [x] **3.1 `BitMemory.hx`** -> `ds/tools/mem/bit_memory.zig`
- [x] **3.2 `ByteMemory.hx`** -> `ds/tools/mem/byte_memory.zig`
- [x] **3.3 `ShortMemory.hx`** -> `ds/tools/mem/short_memory.zig`
- [x] **3.4 `IntMemory.hx`** -> `ds/tools/mem/int_memory.zig`
- [x] **3.5 `FloatMemory.hx`** -> `ds/tools/mem/float_memory.zig`
- [x] **3.6 `DoubleMemory.hx`** -> `ds/tools/mem/double_memory.zig`
- [x] **3.7 `MemoryAccess.hx`** -> `ds/tools/mem/memory_access.zig`
- [x] **3.8 `MemoryManager.hx`** -> `ds/tools/mem/memory_manager.zig`

---

### 阶段四：通用工具移植 (`tools`)

- [x] **4.1 `Assert.hx`** -> `ds/tools/assert.zig`
- [x] **4.2 `Compare.hx`** -> `ds/tools/compare.zig`
- [ ] **4.3 `GrowthRate.hx`** -> `ds/tools/growth_rate.zig`
- [ ] **4.4 `MathTools.hx`** -> `ds/tools/math_tools.zig`
- [ ] **4.5 `Shuffle.hx`** -> `ds/tools/shuffle.zig`
- [ ] **4.6 `Bits.hx`** -> `ds/tools/bits.zig`
- [ ] **4.7 `Bitfield.hx`** -> `ds/tools/bitfield.zig`
- [ ] **4.8 `FreeList.hx`** -> `ds/tools/free_list.zig`
- [ ] **4.9 `ObjectPool.hx`** -> `ds/tools/object_pool.zig`
- [ ] **4.10 `NativeArrayTools.hx`** -> `ds/tools/native_array_tools.zig`
- [ ] **4.11 `ArrayTools.hx`** -> `ds/tools/array_tools.zig`
- [ ] **4.12 `TreeTools.hx`** -> `ds/tools/tree_tools.zig`
- [ ] **4.13 `RadixSort.hx`** -> `ds/tools/radix_sort.zig`

---

### 阶段五：哈希表核心

- [ ] **5.1 `IntIntHashTable.hx`** -> `ds/int_int_hash_table.zig`

---

### 阶段六：核心数据结构

- [ ] **6.1 `ArrayList.hx`** -> `ds/array_list.zig`
- [ ] **6.2 `Dll.hx` & `DllNode.hx`** -> `ds/dll.zig`
- [ ] **6.3 `Sll.hx` & `SllNode.hx`** -> `ds/sll.zig`
- [ ] **6.4 `HashTable.hx`** -> `ds/hash_table.zig`
- [ ] **6.5 `HashSet.hx`** -> `ds/hash_set.zig`
- [ ] **6.6 `IntHashTable.hx`** -> `ds/int_hash_table.zig`
- [ ] **6.7 `IntHashSet.hx`** -> `ds/int_hash_set.zig`
- [ ] **6.8 `BitVector.hx`** -> `ds/bit_vector.zig`
- [ ] **6.9 `Bst.hx` & `BinaryTreeNode.hx`** -> `ds/bst.zig`
- [ ] **6.10 `Heap.hx`** -> `ds/heap.zig`
- [ ] **6.11 `Graph.hx`, `GraphNode.hx`, `GraphArc.hx`** -> `ds/graph.zig`
- [ ] **6.12 `Array2.hx`** -> `ds/array2.zig`
- [ ] **6.13 `Array3.hx`** -> `ds/array3.zig`
- [ ] **6.14 `TreeNode.hx`** -> `ds/tree_node.zig`
- [ ] **6.15 `TreeBuilder.hx`** -> `ds/tree_builder.zig`

---

### 阶段七：派生数据结构

- [ ] **7.1 `ArrayedStack.hx`** -> `ds/arrayed_stack.zig`
- [ ] **7.2 `LinkedStack.hx`** -> `ds/linked_stack.zig`
- [ ] **7.3 `ArrayedQueue.hx`** -> `ds/arrayed_queue.zig`
- [ ] **7.4 `LinkedQueue.hx`** -> `ds/linked_queue.zig`
- [ ] **7.5 `ArrayedDeque.hx`** -> `ds/arrayed_deque.zig`
- [ ] **7.6 `LinkedDeque.hx`** -> `ds/linked_deque.zig`
- [ ] **7.7 `PriorityQueue.hx`** -> `ds/priority_queue.zig`
- [ ] **7.8 `ListSet.hx`** -> `ds/list_set.zig`

---

### 阶段八：测试、文档与收尾

- [ ] **8.1 单元测试**: 逐个为已移植的模块编写单元测试
- [ ] **8.2 文档**: 为所有公共 API 编写文档
- [ ] **8.3 示例**: 编写项目 README 和使用示例