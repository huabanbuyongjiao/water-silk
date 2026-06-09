import AppKit
import SwiftUI

/// Transparent, always-on-top, click-through (when not editing) full-screen window
class OverlayWindow: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

class OverlayWindowController: NSWindowController {
    private var cancellable: Any?

    init() {
        let screen = NSScreen.main ?? NSScreen.screens.first!
        let frame = screen.frame

        let panel = OverlayWindow(
            contentRect: frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .screenSaver          // above almost everything
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.ignoresMouseEvents = true     // default: pass through
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.hasShadow = false

        let hostingView = NSHostingView(
            rootView: OverlayView()
                .environmentObject(MaskStore.shared)
        )
        hostingView.frame = frame
        panel.contentView = hostingView

        super.init(window: panel)

        // When editing, capture mouse events
        cancellable = MaskStore.shared.$isEditing.sink { [weak panel] editing in
            panel?.ignoresMouseEvents = !editing
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}
