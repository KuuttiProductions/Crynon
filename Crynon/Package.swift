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
            name: "Crynon",
            resources: [.process("Assets")]),
        .testTarget(
            name: "CrynonTests",
            dependencies: ["Crynon"])
    ]
)