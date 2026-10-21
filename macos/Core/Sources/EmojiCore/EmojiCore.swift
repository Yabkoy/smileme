import Foundation

public struct EmojiItem: Codable, Equatable {
    public let hex: String
    public let label: String
    public let group: Int
    public let search: String
    public let skins: [String]
}

public enum EmojiCore {
    public static let version = "0.1.0"

    public static func parseItems(_ data: Data) throws -> [EmojiItem] {
        try JSONDecoder().decode([EmojiItem].self, from: data)
    }

    public static func loadItems(from url: URL) throws -> [EmojiItem] {
        try parseItems(Data(contentsOf: url))
    }

    /// Pusty ciąg zwraca wszystko.
    public static func search(_ items: [EmojiItem], query: String) -> [EmojiItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return items }
        return items.filter { $0.search.contains(q) }
    }

    /// tone 0 = domyślny, 1...5 = odcień. Brak wariantu => hex bez zmian.
    public static func applySkin(_ item: EmojiItem, tone: Int) -> String {
        if tone >= 1 && tone <= item.skins.count { return item.skins[tone - 1] }
        return item.hex
    }

    public static func stripVariation(_ hex: String) -> String {
        hex.split(separator: "-").filter { $0 != "fe0f" }.joined(separator: "-")
    }

    /// Style bez zasobów (microsoft, samsung) spadają na twitter.
    public static func imageCandidates(hex: String, style: String) -> [String] {
        let available = ["apple", "google", "twitter"]
        let s = available.contains(style) ? style : "twitter"
        let stripped = stripVariation(hex)
        let all = [
            "assets/\(s)/\(hex).png",
            "assets/\(s)/\(stripped).png",
            "assets/twitter/\(stripped).png",
        ]
        var out: [String] = []
        for u in all where !out.contains(u) { out.append(u) }
        return out
    }
}
