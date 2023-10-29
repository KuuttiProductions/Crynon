// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Crynon",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Crynon",
            targets: ["Crynon"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Crynon"),
        .testTarget(
            name: "CrynonTests",
            dependencies: ["Crynon"]),
    ]
)
