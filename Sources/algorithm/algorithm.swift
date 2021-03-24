public enum algorithm {
  @inlinable public static func xorSwap<T: BinaryInteger>(
    _ lhs: inout T, _ rhs: inout T
  ) {
    lhs ^= rhs
    rhs ^= lhs
    lhs ^= rhs
  }
}
