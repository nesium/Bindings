// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "Bindings",
  platforms: [
    .iOS(.v11)
  ],
  products: [
    .library(name: "Bindings", targets: ["Bindings"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMinor(from: "5.0.1")),
    .package(url: "https://github.com/nesium/NSMFoundation.git", .upToNextMinor(from: "1.0.0")),
  ],
  targets: [
    .target(name: "Bindings", dependencies: ["RxSwift", "NSMFoundation"]), 
    .testTarget(name: "BindingsTests", dependencies: ["Bindings"])
  ]
)
