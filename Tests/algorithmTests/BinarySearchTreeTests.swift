import algorithm
import XCTest
import SwiftCheck

final class BinarySearchTreeTests: XCTestCase {
  func testFoo() {
    var node = BasicBSTNode<Int>(value: 5, left: nil, right: nil)
    node.insert(value: 3, keyForValue: { $0 })
    node.insert(value: 2, keyForValue: { $0 })
    node.insert(value: 4, keyForValue: { $0 })
    node.insert(value: 7, keyForValue: { $0 })
    node.insert(value: 6, keyForValue: { $0 })
    node.insert(value: 8, keyForValue: { $0 })

    XCTAssertEqual(node.left?.left?.value, 2)
    XCTAssertEqual(node.left?.value, 3)
    XCTAssertEqual(node.left?.right?.value, 4)
    XCTAssertEqual(node.value, 5)
    XCTAssertEqual(node.right?.left?.value, 6)
    XCTAssertEqual(node.right?.value, 7)
    XCTAssertEqual(node.right?.right?.value, 8)
  }
}
