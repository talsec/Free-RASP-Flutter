// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "freerasp",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "freerasp", targets: ["freerasp"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .binaryTarget(
            name: "TalsecRuntime",
            url: "https://storage.googleapis.com/talsec-artifact-repository/freerasp/ios/flutter/7.1.1/TalsecRuntime.xcframework.zip",
            checksum: "7074650ba823de4f11e97aadb2c41671b686fdde5479db9f4f49eb90d537aa1d"
        ),
        .target(
            name: "freerasp",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                "TalsecRuntime"
            ],
            path: "Sources/freerasp"
        )
    ]
)
