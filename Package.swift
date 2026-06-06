// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MarqueeKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
    ],
    products: [
        .library(
            name: "MarqueeKit",
            targets: ["MarqueeKit"]
        ),
    ],
    targets: [
        .target(
            name: "MarqueeKit",
            path: "Sources/MarqueeKit",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "MarqueeKitTests",
            dependencies: ["MarqueeKit"],
            path: "Tests/MarqueeKitTests"
        ),
    ]
)
