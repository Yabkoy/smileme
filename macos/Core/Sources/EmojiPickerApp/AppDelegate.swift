import AppKit
import Carbon.HIToolbox
import EmojiCore

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var hotKey: GlobalHotKey?
    private var controller: PickerController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let dataURL = AssetLocator.sharedRoot.appendingPathComponent("data/emoji.json")
        let items: [EmojiItem]
        do {
            items = try EmojiCore.loadItems(from: dataURL)
        } catch {
            let alert = NSAlert()
            alert.messageText = "Nie można wczytać danych emoji"
            alert.informativeText = "\(dataURL.path)\n\(error)"
            alert.runModal()
            NSApp.terminate(nil)
            return
        }

        let controller = PickerController(vm: PickerViewModel(items: items))
        self.controller = controller

        hotKey = GlobalHotKey(keyCode: UInt32(kVK_ANSI_Period), modifiers: UInt32(optionKey)) {
            controller.toggle()
        }
        if hotKey == nil {
            NSLog("Nie udało się zarejestrować skrótu Alt+. (zajęty przez inną aplikację?)")
        }

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "😀"
        let menu = NSMenu()
        menu.addItem(withTitle: "Pokaż picker (⌥.)", action: #selector(showPicker), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Zakończ", action: #selector(quit), keyEquivalent: "q").target = self
        item.menu = menu
        statusItem = item
    }

    @objc private func showPicker() { controller?.show() }
    @objc private func quit() { NSApp.terminate(nil) }
}
