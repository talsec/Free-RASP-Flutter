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
            url: "https://storage.googleapis.com/talsec-artifact-repository/freerasp/ios/flutter/7.1.4/TalsecRuntime.xcframework.zip",
            checksum: "815e70160e31d714f8b17624e5942bdb80c6ab168b614190596275ebcad06863"
        ),
        .target(
            name: "freerasp",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                "TalsecRuntime"
            ],
            path: "Sources"
        )
    ]
)
