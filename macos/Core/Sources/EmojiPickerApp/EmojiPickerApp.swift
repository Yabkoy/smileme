import AppKit

@MainActor
@main
struct EmojiPickerApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)  // bez ikony w Docku
        app.run()
    }
}
