// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ThriftFeedCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "ThriftFeedCore", targets: ["ThriftFeedCore"])
    ],
    targets: [
        .target(name: "ThriftFeedCore"),
        .testTarget(
            name: "ThriftFeedCoreTests",
            dependencies: ["ThriftFeedCore"]
        )
    ]
)
