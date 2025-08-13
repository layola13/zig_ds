# `ArrayList` Feature Comparison: Haxe vs. Zig

This document outlines the feature differences between `ds.ArrayList` (Haxe) and `zig-ds.linear.ArrayList` (Zig). The Zig implementation is currently a wrapper around `std.ArrayList`, while the Haxe version offers a much richer, custom API.

## Missing Features in `ArrayList.zig`

The following is a list of major features present in the Haxe version that are missing from the Zig implementation.

### I. Core Properties & Memory Management

-   [ ] **`capacity: Int`**: Public property to get the current allocated capacity. Zig's `std.ArrayList` has this, but it's not exposed.
-   [ ] **`growthRate: GrowthRate`**: Configurable growth strategy. (Note: `std.ArrayList` has its own internal growth logic, a direct 1:1 port might be complex).
-   [ ] **`reserve(n: Int)`**: Pre-allocates internal storage for `n` elements. Maps to `std.ArrayList.ensureTotalCapacity`.
-   [ ] **`pack()`**: Reduces capacity to fit the current size. Maps to `std.ArrayList.shrink`.
-   [ ] **`resize(n: Int)`**: Resizes the container to exactly `n` elements, either truncating or expanding.
-   [ ] **`trim(n: Int)`**: A soft resize that only changes the `size` property without deallocating memory.
-   [ ] **`clear(gc: Bool)`**: Removes all elements. `std.ArrayList.clearRetainingCapacity` is a good equivalent.
-   [ ] **`free()`**: Full deinitialization. Covered by `deinit()`.

### II. Element Access & Manipulation

-   [ ] **`front(): T`**: Get the first element.
-   [ ] **`back(): T`**: Get the last element.
-   [ ] **`swap(i: Int, j: Int)`**: Swap two elements.
-   [ ] **`swapPop(i: Int): T`**: Fast removal by swapping with the last element. Maps to `std.ArrayList.swapRemove`.
-   [ ] **`add(val: T)`**: Alias for `pushBack`.
-   [ ] **`unsafePushBack(val: T)`**: Appends without capacity checks. Maps to `std.ArrayList.appendAssumeCapacity`.

### III. Search & Query

-   [ ] **`contains(val: T): Bool`**: Checks for the existence of an element.
-   [ ] **`binarySearch(val: T, ...): Int`**: Binary search for sorted lists.

### IV. Iteration & Higher-Order Functions

-   [ ] **`iterator(): Itr<T>`**: Returns a standard iterator.
-   [ ] **`reuseIterator: Bool`**: A property to control iterator object allocation.
-   [ ] **`forEach(f: T->Int->T)`**: Map-like iteration.
-   [ ] **`iter(f: T->Void)`**: Simple iteration.
-   [ ] **`pairwise(visit: Int->T->T->Void)`**: Iterates over elements in pairs.

### V. Utility & Conversion

-   [ ] **`isEmpty(): Bool`**: Checks if size is 0.
-   [ ] **`toArray(): Array<T>`**: Converts to a standard array/slice.
-   [ ] **`clone(byRef: Bool, ...): Collection<T>`**: Creates a shallow or deep copy.
-   [ ] **`concat(val: ArrayList<T>, ...)`**: Concatenates with another list.
-   [ ] **`join(sep: String): String`**: Joins elements into a string.
-   [ ] **`reverse()`**: Reverses the list in-place.
-   [ ] **`shuffle()`**: Randomizes element order.
-   [ ] **`sort(...)`**: More advanced sorting options (e.g., `insertionSort`).

## Implementation Plan

1.  **Expose Basic Properties**: Add `capacity()` and `isEmpty()`.
2.  **Implement Core Methods**: Add `front()`, `back()`, `clear()`, `contains()`, `toArray()`, `clone()`.
3.  **Implement Memory Management**: Add `reserve()`, `pack()`.
4.  **Implement Manipulation Methods**: Add `swap()`, `swapPop()`.
5.  **Implement Iterator**: Add `iterator()` and the corresponding `Iterator` struct.
6.  **Implement Advanced Utilities**: Consider `concat`, `reverse`, `join`, `shuffle` as lower priority.