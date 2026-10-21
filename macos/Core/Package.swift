// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "EmojiCore",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "EmojiCore", targets: ["EmojiCore"]),
        .executable(name: "EmojiPickerApp", targets: ["EmojiPickerApp"]),
    ],
    targets: [
        .target(name: "EmojiCore"),
        .executableTarget(name: "EmojiPickerApp", dependencies: ["EmojiCore"]),
        .testTarget(name: "EmojiCoreTests", dependencies: ["EmojiCore"]),
    ]
)
