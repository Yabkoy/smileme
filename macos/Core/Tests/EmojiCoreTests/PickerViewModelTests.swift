import XCTest
@testable import EmojiCore

final class PickerViewModelTests: XCTestCase {
    private let items = [
        EmojiItem(hex: "1f44b", label: "waving hand", group: 1, search: "waving hand hello",
                  skins: ["1f44b-1f3fb", "1f44b-1f3fc", "1f44b-1f3fd", "1f44b-1f3fe", "1f44b-1f3ff"]),
        EmojiItem(hex: "1f600", label: "grinning face", group: 0, search: "grinning face smile", skins: []),
    ]

    private func makeDefaults() -> UserDefaults {
        let name = "test-\(UUID().uuidString)"
        let d = UserDefaults(suiteName: name)!
        d.removePersistentDomain(forName: name)
        return d
    }

    func testStringFromHex() {
        XCTAssertEqual(EmojiCore.string(fromHex: "1f600"), "😀")
        XCTAssertEqual(EmojiCore.string(fromHex: "1f44b-1f3fd"), "👋🏽")
        XCTAssertEqual(EmojiCore.string(fromHex: "2764-fe0f"), "❤️")
    }

    func testDefaults() {
        let vm = PickerViewModel(items: items, defaults: makeDefaults())
        XCTAssertEqual(vm.tone, 0)
        XCTAssertEqual(vm.style, "twitter")
        XCTAssertEqual(vm.results.count, 2)
    }

    func testSearchAndSkin() {
        let vm = PickerViewModel(items: items, defaults: makeDefaults())
        vm.query = "wave"
        XCTAssertEqual(vm.results.map(\.hex), ["1f44b"])
        vm.tone = 3
        XCTAssertEqual(vm.hex(for: vm.results[0]), "1f44b-1f3fd")
        XCTAssertEqual(vm.text(for: vm.results[0]), "👋🏽")
    }

    func testPersistence() {
        let d = makeDefaults()
        let a = PickerViewModel(items: items, defaults: d)
        a.tone = 4
        a.style = "google"
        let b = PickerViewModel(items: items, defaults: d)
        XCTAssertEqual(b.tone, 4)
        XCTAssertEqual(b.style, "google")
    }

    func testUnavailableSavedStyleFallsBackToTwitter() {
        let d = makeDefaults()
        d.set("samsung", forKey: "style")
        XCTAssertEqual(PickerViewModel(items: items, defaults: d).style, "twitter")
    }

    func testResetForShow() {
        let vm = PickerViewModel(items: items, defaults: makeDefaults())
        vm.query = "abc"
        vm.showingSettings = true
        let before = vm.focusToken
        vm.resetForShow()
        XCTAssertEqual(vm.query, "")
        XCTAssertFalse(vm.showingSettings)
        XCTAssertEqual(vm.focusToken, before + 1)
    }
}
