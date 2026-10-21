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
        /// "1f44b-1f3fd" -> "👋🏽"
    public static func string(fromHex hex: String) -> String {
        var scalars = String.UnicodeScalarView()
        for part in hex.split(separator: "-") {
            if let v = UInt32(part, radix: 16), let s = Unicode.Scalar(v) {
                scalars.append(s)
            }
        }
        return String(scalars)
    }

    public static let styles: [EmojiStyle] = [
        EmojiStyle(id: "apple", label: "Apple (iOS / macOS)", available: true),
        EmojiStyle(id: "google", label: "Google (Android / Pixel / YouTube)", available: true),
        EmojiStyle(id: "microsoft", label: "Microsoft (Windows / Fluent)", available: false),
        EmojiStyle(id: "twitter", label: "Twitter / X (Twemoji)", available: true),
        EmojiStyle(id: "samsung", label: "Samsung (One UI)", available: false),
    ]
}
public struct EmojiStyle: Identifiable, Equatable {
    public let id: String
    public let label: String
    public let available: Bool
}
