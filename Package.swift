// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "IncrementableLabel",
    products: [.library(name: "IncrementableLabel", targets: ["IncrementableLabel"])],
    targets: [.target(name: "IncrementableLabel", path: "Source") ]
)
