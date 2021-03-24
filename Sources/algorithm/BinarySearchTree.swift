public protocol BSTNode {
  associatedtype Value
  var value: Value { get }
  var left: Self? { get set }
  var right: Self? { get set }

  init(value: Value, left: Self?, right: Self?)

  func find<Key: Comparable>(key: Key, keyForValue: (Value) -> Key) -> Self?
  func findMin() -> Self
  mutating func insert<Key: Comparable>(value: Value, keyForValue: (Value) -> Key)
}

extension BSTNode {
  public var hasLeft: Bool { left != nil }
  public var hasRight: Bool { right != nil }

  public func find<Key: Comparable>(key: Key, keyForValue: (Value) -> Key) -> Self?  {
    let selfkey = keyForValue(value)
    if key == selfkey {
      return self
    } else if key < selfkey {
      guard let left = self.left else { return nil }
      return left.find(key: key, keyForValue: keyForValue)
    } else {
      guard let right = self.right else { return nil }
      return right.find(key: key, keyForValue: keyForValue)
    }
  }

  public func findMin() -> Self {
    var current = self
    while let left = current.left {
      current = left
    }
    return current
  }

  public mutating func insert<Key: Comparable>(value: Value, keyForValue: (Value) -> Key) {
    let key = keyForValue(value)
    if key < keyForValue(self.value) {
      switch left {
      case var left?:
        left.insert(value: value, keyForValue: keyForValue)
        self.left = left
      case nil:
        left = Self.init(value: value, left: nil, right: nil)
      }
    } else {
      switch right {
      case var right?:
        right.insert(value: value, keyForValue: keyForValue)
        self.right = right
      case nil:
        right = Self.init(value: value, left: nil, right: nil)
      }
    }
  }
//  if node is None:
//      return
//  if node.key < self.key:
//      if self.left is None:
//          node.parent = self
//          self.left = node
//      else:
//          self.left.insert(node)
//  else:
//      if self.right is None:
//          node.parent = self
//          self.right = node
//      else:
//          self.right.insert(node)

  public func nextLarger() -> Self {
    if let right = right {
      return right.findMin()
    }
    preconditionFailure()
//    var current = self
//    while let parent = current.value.parent, current === parent.value.right {
//      current = parent
//    }
//    return current
  }
}

public struct BasicBSTNode<T>: BSTNode {
  public var value: T
  // We need some indirection anyway, cow seems as a good choice.
  @CopyOnWrite public var left: Self?
  @CopyOnWrite public var right: Self?

  public init(value: T, left: BasicBSTNode<T>?, right: BasicBSTNode<T>?) {
    self.value = value
    self.left = left
    self.right = right
  }
}
