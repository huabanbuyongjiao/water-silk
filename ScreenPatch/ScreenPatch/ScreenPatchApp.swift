import SwiftUI
import AppKit

@main
struct ScreenPatchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Main control panel
        WindowGroup("ScreenPatch 控制面板") {
            ContentView()
                .environmentObject(MaskStore.shared)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindowController: OverlayWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        overlayWindowController = OverlayWindowController()
        overlayWindowController?.showWindow(nil)

        // Activate app so control panel is visible
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
