import AppKit
import SwiftUI

/// Transparent, always-on-top, click-through (when not editing) full-screen window
class OverlayWindow: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

class OverlayWindowController: NSWindowController {
    private var cancellable: Any?
    private var keyMonitor: Any?

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

        // When editing, capture mouse events and listen for keyboard shortcuts
        cancellable = MaskStore.shared.$isEditing.sink { [weak self, weak panel] editing in
            panel?.ignoresMouseEvents = !editing
            if editing {
                self?.startKeyMonitor()
            } else {
                self?.stopKeyMonitor()
            }
        }
    }

    private func startKeyMonitor() {
        guard keyMonitor == nil else { return }
        keyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKey(event)
        }
    }

    private func stopKeyMonitor() {
        if let m = keyMonitor { NSEvent.removeMonitor(m) }
        keyMonitor = nil
    }

    private func handleKey(_ event: NSEvent) {
        let store = MaskStore.shared
        guard store.isEditing else { return }
        switch event.keyCode {
        case 36, 76: // Return, numpad Enter
            store.commitDraft()
            store.isEditing = false
        case 53: // Escape
            store.cancelDraft()
            store.isEditing = false
        default:
            break
        }
    }

    deinit {
        stopKeyMonitor()
    }

    required init?(coder: NSCoder) { fatalError() }
}
