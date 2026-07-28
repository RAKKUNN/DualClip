// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "DualClip",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "DualClip", targets: ["DualClip"])
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", "1.15.0"..<"1.16.0")
    ],
    targets: [
        // All app logic lives here so it can be exercised by tests.
        // An executable target cannot be imported by a test target — its `main`
        // symbol collides at link time — hence the split.
        .target(
            name: "DualClipCore",
            dependencies: ["KeyboardShortcuts"],
            path: "DualClipCore"
        ),
        // Thin entry point: just calls into DualClipCore.
        .executableTarget(
            name: "DualClip",
            dependencies: ["DualClipCore"],
            path: "DualClip",
            exclude: ["Info.plist"]
        ),
        // Uses @testable, so DualClipCore does not need to expose anything
        // publicly just to be tested.
        .testTarget(
            name: "DualClipCoreTests",
            dependencies: ["DualClipCore"],
            path: "Tests/DualClipCoreTests"
        )
    ]
)
