import Foundation
import Combine

public final class PickerViewModel: ObservableObject {
    public let items: [EmojiItem]
    private let defaults: UserDefaults

    @Published public var query = ""
    @Published public var showingSettings = false
    /// Zwiększany przy każdym pokazaniu okna; widok na tej podstawie ustawia focus w polu wyszukiwania.
    @Published public private(set) var focusToken = 0

    @Published public var tone: Int {
        didSet { defaults.set(tone, forKey: "tone") }
    }
    @Published public var style: String {
        didSet { defaults.set(style, forKey: "style") }
    }

    public init(items: [EmojiItem], defaults: UserDefaults = .standard) {
        self.items = items
        self.defaults = defaults

        let savedTone = defaults.integer(forKey: "tone")
        self.tone = (0...5).contains(savedTone) ? savedTone : 0

        let savedStyle = defaults.string(forKey: "style") ?? "twitter"
        let ok = EmojiCore.styles.contains { $0.id == savedStyle && $0.available }
        self.style = ok ? savedStyle : "twitter"
    }

    public var results: [EmojiItem] { EmojiCore.search(items, query: query) }

    public func hex(for item: EmojiItem) -> String { EmojiCore.applySkin(item, tone: tone) }

    public func text(for item: EmojiItem) -> String { EmojiCore.string(fromHex: hex(for: item)) }

    /// Wywoływane przy każdym pokazaniu okna.
    public func resetForShow() {
        query = ""
        showingSettings = false
        focusToken += 1
    }
}
