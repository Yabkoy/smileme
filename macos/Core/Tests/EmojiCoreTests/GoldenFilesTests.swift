import XCTest
@testable import EmojiCore

final class GoldenFilesTests: XCTestCase {
    func testVersion() {
        XCTAssertEqual(EmojiCore.version, "0.1.0")
    }

    func testGoldenFilesExist() throws {
        // .../macos/Core/Tests/EmojiCoreTests/ThisFile.swift -> korzeń repo (5 poziomów w górę)
        var root = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { root.deleteLastPathComponent() }
        let golden = root.appendingPathComponent("shared/golden")

        for name in ["search.json", "skin.json", "assets.json"] {
            let data = try Data(contentsOf: golden.appendingPathComponent(name))
            XCTAssertGreaterThan(data.count, 2, name)
        }
    }
}
