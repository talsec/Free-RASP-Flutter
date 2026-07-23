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
            path: "TalsecRuntime.xcframework"
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
