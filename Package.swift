// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tarot",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TarotKit",
            targets: ["TarotKit"]),
        .executable(
            name: "tarot",
            targets: ["Tool"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "../DotWriter", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Records",
            dependencies: []),
        .target(
            name: "TarotKit",
            dependencies: ["Records", "DotWriter"]),
        .executableTarget(
            name: "Tool",
            dependencies: [
                "TarotKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            resources: [ ]
        ),
        .testTarget(
            name: "RecordsTests",
            dependencies: ["Records"]),
        .testTarget(
            name: "TarotTests",
            dependencies: ["TarotKit", "Records", "DotWriter"]),
    ]
)
