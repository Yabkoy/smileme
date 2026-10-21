import AppKit
import SwiftUI
import EmojiCore

@MainActor
final class PickerController {
    private let vm: PickerViewModel
    private let panel: PickerPanel

    init(vm: PickerViewModel) {
        self.vm = vm
        let host = NSHostingView(rootView: PickerView(vm: vm, onPick: { _ in }, onClose: {}))
        self.panel = PickerPanel(content: host)

        // Właściwy rootView (z domknięciami do kontrolera) ustawiamy po init.
        host.rootView = PickerView(
            vm: vm,
            onPick: { [weak self] text in self?.pick(text) },
            onClose: { [weak self] in self?.hide() }
        )
        panel.onResignKey = { [weak self] in self?.hide() }
    }

    func toggle() {
        panel.isVisible ? hide() : show()
    }

    func show() {
        vm.resetForShow()

        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) } ?? NSScreen.main
        if let f = screen?.visibleFrame {
            let size = panel.frame.size
            panel.setFrameOrigin(NSPoint(x: f.midX - size.width / 2, y: f.midY - size.height / 2))
        }
        panel.makeKeyAndOrderFront(nil)
    }

    func hide() {
        panel.orderOut(nil)
    }

    private func pick(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        hide()

        // Wklejamy tylko z uprawnieniem Dostępność; bez niego emoji zostaje w schowku.
        if Paster.isTrusted(prompt: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                Paster.pasteCommandV()
            }
        }
    }
}
