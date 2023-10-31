// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Crynon",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Crynon",
            targets: ["Crynon"]),
    ],
    targets: [
        .target(
            name: "Crynon"),
        .testTarget(
            name: "CrynonTests",
            dependencies: ["Crynon"]),
    ]
)
