/// Utilities to work with a collection of elements as a heap.
/// Some of those utilities are considered "unsafe" as they require
/// inputs to have heap invariant (child less that or equal to parent).
/// To work with a nicer and safer API consider Heap or BinaryHeapView containers.
extension algorithm {
  /// Constraints for collection that can be heapified and used as heap,
  /// without changing its size
  public typealias MutableRandomAccessCollection =
    MutableCollection & RandomAccessCollection
  /// Constraints for collection that can be heapified and used as heap,
  /// including changing its size (insert, extract, meld, etc)
  public typealias MutableHeapCollection =
    MutableRandomAccessCollection & RangeReplaceableCollection

  /// Namespace for subroutines that binary heap functions use
  public enum binheap {}

  /// Arrange elements in a given collection to fulfill heap invariant.
  /// - Parameters:
  ///   - xs: collection of elements
  ///   - order: linear order relation for elements in given collection
  /// - Complexity: O(n) where n is the length of the collection.
  @inlinable public static func heapify<T: MutableRandomAccessCollection>(
    _ xs: inout T,
    order: (T.Element, T.Element) throws -> Bool
  ) rethrows {
    let count = xs.distance(from: xs.startIndex, to: xs.endIndex)
    for i in xs.indices.prefix(count / 2).reversed() {
      try binheap.siftDown(&xs, at: i, order: order)
    }
  }

  /// Returns the node of maximum value.
  /// - Precondition: Input `xs` must be valid heap with linear order relation
  /// defined by `order` function.
  /// - Parameters:
  ///   - xs: collection of elements with heap invariant
  ///   - order: function that defines linear order criteria on `xs`,
  ///   used to maintain heap invariants after removal
  /// - Returns: The max element of the heap if the heap is
  ///   not empty; otherwise, `nil`.
  /// - Complexity: O(log(n)) where n is the length of the collection.
  @inlinable public static func heapExtract<T: MutableHeapCollection>(
    from xs: inout T,
    order: (T.Element, T.Element) throws -> Bool
  ) rethrows -> T.Element? {
    guard xs.count > 0 else { return nil }
    xs.swapAt(xs.startIndex, xs.index(before: xs.endIndex))
    let found = xs.popLast()
    try binheap.siftDown(&xs, at: xs.startIndex, order: order)
    return found
  }

  /// Insert new element into the heap.
  /// - Precondition: Input `xs` must be valid heap with linear order relation
  /// defined by `order` function.
  /// - Parameters:
  ///   - xs: collection of elements with heap invariant
  ///   - element: element to insert
  ///   - order: function that defines linear order criteria on `xs`,
  ///   used to maintain heap invariants after insert
  /// - Complexity: O(log(n)) where n is the length of the collection.
  @inlinable public static func heapInsert<T: MutableHeapCollection>(
    into xs: inout T,
    element: T.Element,
    order: (T.Element, T.Element) throws -> Bool
  ) rethrows {
    xs.append(element)
    try binheap
      .siftUp(&xs, at: xs.index(before: xs.endIndex), order: order)
  }

  /// Removes greatest element from heap and replaces it with new.
  /// Similar to extract then insert, but runs more efficiently and requires
  /// non empty collection.
  /// - Precondition: Input `xs` must not be empty.
  /// - Precondition: Input `xs` must be valid heap with linear order relation
  /// defined by `order` function.
  /// - Parameters:
  ///   - xs: collection of elements with heap invariant
  ///   - element: element to insert
  ///   - order: function that defines linear order criteria on `xs`,
  ///   used to maintain heap invariants after insert
  /// - Complexity: O(log(n)) where n is the length of the collection.
  @inlinable @discardableResult
  public static func heapReplace<T: MutableRandomAccessCollection>(
    in xs: inout T,
    with element: T.Element,
    order: (T.Element, T.Element) throws -> Bool
  ) rethrows -> T.Element {
    let old = setAndGetOld(&xs[xs.startIndex], new: element)
    try binheap.siftDown(&xs, at: xs.startIndex, order: order)
    return old
  }

  /// Pushes new element into the heap and pops greatest.
  /// Equivalent to insert then extract, but runs more efficiently.
  /// - Precondition: Input `xs` must be valid heap with linear order relation
  /// defined by `order` function.
  /// - Parameters:
  ///   - xs: collection of elements with heap invariant
  ///   - element: element to insert
  ///   - order: function that defines linear order criteria on `xs`,
  ///   used to maintain heap invariants after insert
  /// - Complexity: O(log(n)) where n is the length of the collection.
  @inlinable @discardableResult
  public static func heapPushpop<T: MutableRandomAccessCollection>(
    in xs: inout T,
    with element: T.Element,
    order: (T.Element, T.Element) throws -> Bool
  ) rethrows -> T.Element {
    guard let first = xs.first, try order(first, element) else {
      return element
    }
    return try heapReplace(in: &xs, with: element, order: order)
  }

  /// Adds the elements of a sequence into heap.
  ///
  /// Equivavlent to appending contents of collection and callling heapify.
  /// Runs more effective than inserting element one by one if size of this
  /// collection is asymptotically equivalent to O(*n*/log(*n*)) or greater,
  /// where *n* is the length of xs.
  ///
  /// This function, unlike other, doesn't require that xs is a valid
  /// heap, as it rearranges everything anyway.
  /// Exists purely for convinience and readibility.
  /// - Parameters:
  ///   - xs: collection that will be extended and modified to fulfill heap
  ///   invariant
  ///   - newElements: contents of this collection will be appended to xs
  ///   - order: linear order for heap property maintenance
  /// - Complexity: O(*n* + *m*), where *n* is the length of xs,
  /// *m* is the length of `newElements`
  @inlinable
  public static func heapMeld<T: MutableHeapCollection, S: Sequence>(
    into xs: inout T,
    from newElements: S,
    order: (T.Element, T.Element) throws -> Bool
  ) rethrows where T.Element == S.Element {
    fatalError("Not Implemented")
//    xs.append(contentsOf: newElements)
  }
}

// MARK: Comparable helpers
extension algorithm {
  /// Builds a max heap – heap with greatest element on top.
  /// - Parameter xs: collection of comparable elements
  /// - Complexity: O(n) where n is the length of the collection.
  @inlinable public static func buildMaxHeap<T: MutableRandomAccessCollection>(
    _ xs: inout T
  ) where T.Element: Comparable {
    heapify(&xs, order: >)
  }

  /// Builds a min heap – heap with least element on top.
  /// - Parameter xs: collection of comparable elements
  /// - Complexity: O(n) where n is the length of the collection.
  @inlinable
  public static func buildMinHeap<T: MutableRandomAccessCollection>(
    _ xs: inout T
  ) where T.Element: Comparable {
    heapify(&xs, order: <)
  }
}

// MARK: Copying helpers
extension algorithm {
  @inlinable
  public static func heapified<T: MutableRandomAccessCollection>(
    _ xs: T,
    order: (T.Element, T.Element) throws -> Bool
  ) rethrows -> T {
    try modified(xs) { try heapify(&$0, order: order) }
  }

  @inlinable
  public static func builtMaxHeap<T: MutableRandomAccessCollection>(
    _ xs: T
  ) -> T where T.Element: Comparable {
    heapified(xs, order: >)
  }

  @inlinable
  public static func builtMinHeap<T: MutableRandomAccessCollection>(
    _ xs: T
  ) -> T where T.Element: Comparable {
    self.heapified(xs, order: <)
  }
}

// MARK: Utilities
extension algorithm.binheap {
  @inlinable public static func children<T: RandomAccessCollection>(
    in xs: T,
    of node: T.Index
  ) -> (left: T.Index, right: T.Index) {
    let d = xs.distance(from: xs.startIndex, to: node)
    let left = xs.index(xs.startIndex, offsetBy: 2 * d + 1)
    return (left: left, right: xs.index(after: left))
  }

  @inlinable public static func parent<T: RandomAccessCollection>(
    in xs: T,
    of node: T.Index
  ) -> T.Index {
    let d = xs.distance(from: xs.startIndex, to: node)
    return xs.index(xs.startIndex, offsetBy: (d - 1) / 2)
  }

  @inlinable
  public static func siftDown<T: algorithm.MutableRandomAccessCollection>(
    _ xs: inout T,
    at index: T.Index,
    order: (T.Element, T.Element) throws -> Bool
  ) rethrows {
    var i = index
    while case let (left, right) = children(in: xs, of: i),
      left < xs.endIndex,
      case let maxChild = try
        right >= xs.endIndex || order(xs[left], xs[right]) ? left : right,
      try order(xs[maxChild], xs[i]) {
      xs.swapAt(maxChild, i)
      i = maxChild
    }
  }

  @inlinable
  public static func siftUp<T: algorithm.MutableRandomAccessCollection>(
    _ xs: inout T,
    at index: T.Index,
    order: (T.Element, T.Element) throws -> Bool
  ) rethrows {
    let element = xs[index]
    var current = index
    while case let parent = parent(in: xs, of: current),
      parent >= xs.startIndex,
      try order(element, xs[parent]) {
      xs.swapAt(current, parent)
      current = parent
    }
  }
}
