// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "freerasp",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        .library(name: "freerasp", targets: ["freerasp"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "freerasp",
            dependencies: [],
            resources: []
        ),
        .binaryTarget(
            name: "TalsecRuntime.xcframework",
            path: "./TalsecRuntime.xcframework"
        )
    ]
)
