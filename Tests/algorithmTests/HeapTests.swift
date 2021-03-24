import algorithm
import XCTest
import SwiftCheck

final class HeapTests: XCTestCase {
  func testBuildHeap() {
    property("collection has heap property") <- forAll { (xs: [Int]) in
      validateMaxHeap(algorithm.builtMaxHeap(xs))
    }
  }

  func testHeap_extract() {
    property("returns greatest number in max heap") <- forAll { (xs: [Int]) in
      var heap = algorithm.builtMaxHeap(xs)
      guard let extracted = algorithm.heapExtract(from: &heap, order: >) else {
        return xs.isEmpty
      }
      return validateMaxHeap(heap)
        && (heap + [extracted]).sorted() == xs.sorted()
    }
  }

  func testHeap_insert() {
    property(
      "maintains heap invariant after insertion"
    ) <- forAll { (xs: [Int], new: Int) in
      var heap = algorithm.builtMaxHeap(xs)
      algorithm.heapInsert(into: &heap, element: new, order: >)
      return validateMaxHeap(heap) && heap.sorted() == (xs + [new]).sorted()
    }
  }

  func testHeap_replace() {
    property("maintains heap invariant after replace") <- forAll(
      Int.arbitrary.proliferateNonEmpty,
      Int.arbitrary
    ) { (xs: [Int], new: Int) in
      guard !xs.isEmpty else { return true }
      var heap = algorithm.builtMaxHeap(xs)
      let replaced = algorithm.heapReplace(in: &heap, with: new, order: >)
      return validateMaxHeap(heap) &&
          ((heap + [replaced]).sorted() == (xs + [new]).sorted())
    }

    property("returns value independant of new element") <- forAll(
      Int.arbitrary.proliferateNonEmpty,
      Int.arbitrary
    ) { (xs: [Int], new: Int) in
      guard !xs.isEmpty, let max = xs.max() else { return true }
      let new = max + abs(new) + 1
      var heap = algorithm.builtMaxHeap(xs)
      let replaced = algorithm.heapReplace(in: &heap, with: new, order: >)
      return replaced < new
    }

  }

  func testHeap_pushpop() {
    property("maintains heap invariant after pushpop") <- forAll(
    ) { (xs: [Int], new: Int) in
      var heap = algorithm.builtMaxHeap(xs)
      let replaced = algorithm.heapPushpop(in: &heap, with: new, order: >)
      return validateMaxHeap(heap) &&
          ((heap + [replaced]).sorted() == (xs + [new]).sorted())
    }
    property("returns new value if it becomes greatest") <- forAll(
    ) { (xs: [Int], new: Int) in
      var heap = algorithm.builtMaxHeap(xs)
      let new = (xs.max() ?? 0) + abs(new) + 1
      let replaced = algorithm.heapPushpop(in: &heap, with: new, order: >)
      return replaced == new
    }
  }

  func testHeapsort() {
    property("sorting in ascending order") <- forAll { (xs: [Int]) in
      let xs = algorithm.heapsorted(xs, by: <)
      return zip(xs.dropLast(), xs.dropFirst()).allSatisfy {
        $0.0 <= $0.1
      }
    }
    property("sorting in descending order") <- forAll { (xs: [Int]) in
      let xs = algorithm.heapsorted(xs, by: >)
      return zip(xs.dropLast(), xs.dropFirst()).allSatisfy {
        $0.0 >= $0.1
      }
    }
  }
}

private func validateMaxHeap(_ xs: [Int]) -> Bool {
  xs.enumerated().allSatisfy { i, el in
    let right = i * 2 + 1
    let left = right + 1
    return (right >= xs.count || xs[right] <= el)
      && (left >= xs.count || xs[right] <= el)
  }
}
