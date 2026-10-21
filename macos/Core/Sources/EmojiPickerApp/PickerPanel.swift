import AppKit

/// Bezramkowy panel zawsze na wierzchu. Przyjmuje klawiaturę, ale nie aktywuje aplikacji,
/// więc poprzednia aplikacja zostaje na pierwszym planie.
final class PickerPanel: NSPanel {
    var onResignKey: (() -> Void)?

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func resignKey() {
        super.resignKey()
        onResignKey?()
    }

    init(content: NSView) {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 420, height: 480),
                   styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered,
                   defer: false)
        isFloatingPanel = true
        level = .floating
        hidesOnDeactivate = false
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        contentView = content
    }
}
