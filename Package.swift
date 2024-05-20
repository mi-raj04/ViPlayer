// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription

let package = Package(
    name: "VPlayerUIKit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "VPlayerUIKit",
            targets: ["VPlayerUIKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "VPlayerUIKit",
            dependencies: []),
        .testTarget(
            name: "VPlayerUIKitTests",
            dependencies: ["VPlayerUIKit"]),
    ]
)
