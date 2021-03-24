extension algorithm {
  /// Sorts the input collection of elements in ascending order inplace using
  /// [Heapsort](https://en.wikipedia.org/wiki/Heapsort)
  /// - Parameters:
  ///   - xs: input collection of elements
  /// - Complexity: O(K*nlog(n)) where K is `areInIncreasingOrder` complexity
  @inlinable public static func heapsort<T: MutableRandomAccessCollection>(
    _ xs: inout T
  ) where T.Element: Comparable {
    heapsort(&xs, by: <)
  }

  /// Sorts the input collection inplace using
  /// [Heapsort](https://en.wikipedia.org/wiki/Heapsort)
  /// - Parameters:
  ///   - xs: input collection of elements
  ///   - areInIncreasingOrder: A predicate that returns `true` if its
  ///   first argument should be ordered before its second argument;
  ///   otherwise, `false`.
  /// - Complexity: O(K*nlog(n)) where K is `order` function complexity
  @inlinable public static func heapsort<T: MutableRandomAccessCollection>(
    _ xs: inout T,
    by areInIncreasingOrder: (T.Element, T.Element) throws -> Bool
  ) rethrows {
    try heapify(&xs) { try !areInIncreasingOrder($0, $1) }
    for current in xs.indices.reversed() {
      xs.swapAt(xs.startIndex, current)
      try binheap.siftDown(&xs[xs.startIndex..<current], at: xs.startIndex)
        { try !areInIncreasingOrder($0, $1) }
    }
  }

  @inlinable
  public static func heapsorted<T: MutableRandomAccessCollection>(
    _ xs: T,
    by areInIncreasingOrder: (T.Element, T.Element) throws -> Bool
  ) rethrows -> T {
    try modified(xs) { try heapsort(&$0, by: areInIncreasingOrder) }
  }

  @inlinable
  public static func heapsorted<T: MutableRandomAccessCollection>(
    _ xs: T
  ) -> T where T.Element: Comparable {
    algorithm.heapsorted(xs, by: <)
  }
}
