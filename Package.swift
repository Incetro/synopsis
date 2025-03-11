// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Synopsis",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Synopsis",
            targets: [
                "Synopsis"
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Incetro/source-kitten-adapter",
            from: "0.1.0"
        ),
        .package(
            url: "https://github.com/jpsim/SourceKitten",
            from: "0.37.0"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Synopsis",
            dependencies: [
                .product(
                    name: "SourceKittenAdapter",
                    package: "source-kitten-adapter"
                ),
                .product(
                    name: "SourceKittenFramework",
                    package: "SourceKitten"
                )
            ]
        ),
        .testTarget(
            name: "SynopsisTests",
            dependencies: [
                "Synopsis"
            ]
        ),
    ]
)
