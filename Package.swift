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
        .executableTarget(
            name: "DualClip",
            dependencies: ["KeyboardShortcuts"],
            path: "DualClip",
            exclude: ["Info.plist"]
        )
    ]
)
