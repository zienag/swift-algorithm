// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "algorithm",
  products: [
    .library(
        name: "algorithm",
        targets: ["algorithm"]),
  ],
  dependencies: [
    .package(url: "https://github.com/typelift/SwiftCheck.git", from: "0.8.1")
  ],
  targets: [
    .target(
        name: "algorithm",
        dependencies: []),
    .testTarget(
        name: "algorithmTests",
        dependencies: ["algorithm", "SwiftCheck"]),
  ]
)
