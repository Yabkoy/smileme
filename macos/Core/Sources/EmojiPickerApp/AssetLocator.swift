import AppKit
import EmojiCore

enum AssetLocator {
    /// Katalog `shared/`: najpierw wewnątrz paczki .app (krok pakowania), potem repo (tryb deweloperski).
    static let sharedRoot: URL = {
        if let res = Bundle.main.resourceURL?.appendingPathComponent("shared"),
           FileManager.default.fileExists(atPath: res.appendingPathComponent("data").path) {
            return res
        }
        // .../macos/Core/Sources/EmojiPickerApp/AssetLocator.swift -> korzeń repo (5 poziomów w górę)
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { url.deleteLastPathComponent() }
        return url.appendingPathComponent("shared")
    }()
}

enum ImageCache {
    private static let cache = NSCache<NSString, NSImage>()

    /// Pierwsza istniejąca grafika z listy kandydatów (styl -> bez FE0F -> Twitter).
    static func image(hex: String, style: String) -> NSImage? {
        let key = "\(style)/\(hex)" as NSString
        if let hit = cache.object(forKey: key) { return hit }

        for rel in EmojiCore.imageCandidates(hex: hex, style: style) {
            let url = AssetLocator.sharedRoot.appendingPathComponent(rel)
            if let img = NSImage(contentsOf: url) {
                cache.setObject(img, forKey: key)
                return img
            }
        }
        return nil
    }
}
