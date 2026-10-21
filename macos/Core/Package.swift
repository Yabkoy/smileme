// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "EmojiCore",
    platforms: [.macOS(.v13)],
    products: [.library(name: "EmojiCore", targets: ["EmojiCore"])],
    targets: [
        .target(name: "EmojiCore"),
        .testTarget(name: "EmojiCoreTests", dependencies: ["EmojiCore"]),
    ]
)
