@inlinable
public func modified<T>(
  _ val: T,
  transform: (inout T) throws -> Void
) rethrows -> T {
  var copy = val
  try transform(&copy)
  return copy
}

@inlinable
public func setAndGetOld<T>(
  _ val: inout T,
  new: T
) -> T {
  withUnsafeMutablePointer(to: &val) { ptr in
    defer {
      ptr.initialize(to: new)
    }
    return ptr.move()
  }
}

@inlinable
public func maybeInitializeAndModify<T>(
  _ value: inout T?,
  initializeTo: @autoclosure () -> T,
  _ body: (inout T) throws -> Void
) rethrows {
  var temp = value ?? initializeTo()
  try body(&temp)
  value = temp
}

@propertyWrapper
public struct CopyOnWrite<Value> {
  @usableFromInline
  final internal class Pointer<T> {
    @usableFromInline
    internal var value: T
    @usableFromInline
    init(_ value: T) {
      self.value = value
    }
  }

  @usableFromInline
  internal var store: Pointer<Value>

  @inlinable public var wrappedValue: Value {
    get {
      store.value
    }
    _modify {
      ensureIsUnique()
      yield &store.value
    }
  }

  @inlinable public init(wrappedValue: Value) {
    self.store = Pointer(wrappedValue)
  }

  @inlinable public func withUnsafePointer<U>(
    _ body: (UnsafePointer<Value>) throws -> U
  ) rethrows -> U {
    try Swift.withUnsafeMutablePointer(to: &store.value) { try body($0) }
  }

  @inlinable public mutating func withUnsafeMutablePointer<U>(
    _ body: (UnsafeMutablePointer<Value>) throws -> U
  ) rethrows -> U {
    ensureIsUnique()
    return try Swift.withUnsafeMutablePointer(to: &store.value, body)
  }

  @usableFromInline mutating internal func ensureIsUnique() {
    if !isKnownUniquelyReferenced(&store) {
      store = .init(store.value)
    }
  }
}
