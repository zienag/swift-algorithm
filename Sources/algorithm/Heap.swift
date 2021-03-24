/// Specialized tree-based data structure which is an almost
/// complete tree that satisfies the heap property: for any given node C,
/// if P is a parent node of C, then the key (the value) of P is
/// greater than or equal to the key of C. The node at the "top" of the heap
/// (with no parents) is called the root node.
/// - Linear order is defined by comparator function.
/// - Can be parameterized with underlying storage type, that needs to conform
/// to RandomAccessCollection, RangeReplacableCollection and MutableCollection.
///
/// https://en.wikipedia.org/wiki/Binary_heap
public struct BinaryHeapView<S: algorithm.MutableHeapCollection> {
  public typealias T = S.Element
  @usableFromInline
  internal var guts: S
  @usableFromInline
  internal let comparator: (T, T) -> Bool

  /// Copy of underlying storage
  public var heap: S { guts }

  /// Find the greatest element (topmost)
  /// - Complexity: O(1)
  public var peek: T?  { guts.first }

  /// Creates a heap containing the elements of a sequence.
  /// - Parameters:
  ///   - elements: The sequence of elements to turn into a heap.
  ///   - comparator: function to check if two elements are in increasing order
  /// - Complexity: O(*n*) where *n* is the size of elements
  @inlinable public init(_ elements: S, comparator: @escaping (T, T) -> Bool) {
    guts = elements
    self.comparator = comparator
    algorithm.heapify(&guts, order: comparator)
  }

  /// Returns the maximum value from a heap after removing it if
  /// heap is not empty, nil otherwise.
  /// - Complexity: O(log(n)) where n is the length of the heap.
  @inlinable public mutating func pop() -> T? {
    algorithm.heapExtract(from: &guts, order: comparator)
  }

  /// Adding a new key to the heap
  /// - Parameter element: new element to insert
  /// - Complexity: O(log(n)) where n is the length of the heap.
  @inlinable public mutating func push(_ element: T) {
    algorithm.heapInsert(into: &guts, element: element, order: comparator)
  }


  /// Insert item on the heap, then pop and return the smallest item.
  /// The combined action runs more efficiently than push() followed by pop()
  /// - Parameter element: new element to insert
  /// - Complexity: O(log(n)) where n is the length of the heap.
  @inlinable public mutating func pushpop(_ element: T) -> T? {
    algorithm.heapPushpop(in: &guts, with: element, order: comparator)
  }


  /// Inserts all elements from some collection into the heap.
  /// Runs more effeiciently than inserting one by one if size of this
  /// collection is asymptotically equivalent to O(n/log(n)) or greater.
  /// - Parameter elements: collection of elements to insert
  /// - Complexity: O(*n* + *m*) where *n* is the size of heap,
  /// and *m* is the size of inserted collection.
  @inlinable public mutating func meld<C: Collection>(
    _ elements: C
  ) where C.Element == T {
    guts.append(contentsOf: elements)
    algorithm.heapify(&guts, order: comparator)
  }
}

extension BinaryHeapView {
  /// Creates a new, empty heap.
  /// - Parameters:
  ///   - comparator: function to check if two elements are in increasing order
  /// - Complexity: O(1)
  @inlinable public init(comparator: @escaping (T, T) -> Bool) {
    guts = .init()
    self.comparator = comparator
  }
}

/// Collection implementation just forwards everything to underlying storage.
/// - Warning: Order of elements are defined by heap invariants,
/// and differs from that is obtained from sequenced `pop()` calls.
extension BinaryHeapView: Collection {
  public typealias SubSequence = S.SubSequence
  public var startIndex: S.Index { guts.startIndex }
  public var endIndex: S.Index { guts.endIndex }
  public func makeIterator() -> S.Iterator { guts.makeIterator() }
  public func index(after i: S.Index) -> S.Index { guts.index(after: i) }
  public subscript(position: S.Index) -> T { guts[position] }
}

/// Heap is a BinaryHeapView with Array as underlying storage.
public typealias Heap<T> = BinaryHeapView<Array<T>>

// MARK: Comparable conveniences
extension BinaryHeapView where T: Comparable {
  @inlinable
  public static func maxHeap(elements: S) -> Self {
    .init(elements, comparator: >)
  }

  @inlinable
  public static func minHeap(elements: S) -> Self {
    .init(elements, comparator: <)
  }

  @inlinable
  public static func maxHeap() -> Self {
    .init(comparator: >)
  }

  @inlinable
  public static func minHeap() -> Self {
    .init(comparator: <)
  }
}
