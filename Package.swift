// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MonnoNetwork",
    products: [
        .library(
            name: "MonnoNetwork",
            targets: ["MonnoNetwork"]),
    ],
    targets: [
        .target(
            name: "MonnoNetwork",
            dependencies: []),
        .testTarget(
            name: "MonnoNetworkTests",
            dependencies: ["MonnoNetwork"]),
    ]
)
