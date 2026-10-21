import XCTest
@testable import EmojiCore

private struct SearchCase: Decodable {
    let query: String
    let expectCount: Int?
    let expectCountAtLeast: Int?
    let mustContain: [String]?
}

private struct SkinCase: Decodable {
    let base: String
    let tone: Int
    let expect: String
}

private struct AssetCase: Decodable {
    let hex: String
    let style: String
    let expect: [String]
}

final class GoldenFilesTests: XCTestCase {
    // .../macos/Core/Tests/EmojiCoreTests/ThisFile.swift -> korzeń repo (5 poziomów w górę)
    private var root: URL {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { url.deleteLastPathComponent() }
        return url
    }

    private func golden<T: Decodable>(_ name: String, as type: T.Type) throws -> T {
        let url = root.appendingPathComponent("shared/golden/\(name)")
        return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
    }

    private func items() throws -> [EmojiItem] {
        try EmojiCore.loadItems(from: root.appendingPathComponent("shared/data/emoji.json"))
    }

    func testVersion() {
        XCTAssertEqual(EmojiCore.version, "0.1.0")
    }

    func testStripVariation() {
        XCTAssertEqual(EmojiCore.stripVariation("2764-fe0f"), "2764")
        XCTAssertEqual(EmojiCore.stripVariation("1f600"), "1f600")
        XCTAssertEqual(EmojiCore.stripVariation("1f468-200d-1f4bb"), "1f468-200d-1f4bb")
    }

    func testSearchGolden() throws {
        let all = try items()
        for c in try golden("search.json", as: [SearchCase].self) {
            let res = EmojiCore.search(all, query: c.query)
            if let n = c.expectCount { XCTAssertEqual(res.count, n, "query '\(c.query)'") }
            if let n = c.expectCountAtLeast { XCTAssertGreaterThanOrEqual(res.count, n, "query '\(c.query)'") }
            for hex in c.mustContain ?? [] {
                XCTAssertTrue(res.contains { $0.hex == hex }, "query '\(c.query)': brak \(hex)")
            }
        }
    }

    func testSkinGolden() throws {
        let all = try items()
        for c in try golden("skin.json", as: [SkinCase].self) {
            guard let item = all.first(where: { $0.hex == c.base }) else {
                XCTFail("brak emoji \(c.base) w danych")
                continue
            }
            XCTAssertEqual(EmojiCore.applySkin(item, tone: c.tone), c.expect, "base \(c.base)")
        }
    }

    func testAssetsGolden() throws {
        for c in try golden("assets.json", as: [AssetCase].self) {
            XCTAssertEqual(EmojiCore.imageCandidates(hex: c.hex, style: c.style), c.expect,
                           "\(c.style)/\(c.hex)")
        }
    }
}
