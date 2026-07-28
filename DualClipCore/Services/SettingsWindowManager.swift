import AppKit
import SwiftUI

/// Manages a standalone Settings window for menu-bar-only (LSUIElement) apps.
/// SwiftUI's built-in Settings scene does not work reliably with MenuBarExtra + SPM executables.
final class SettingsWindowManager {

    static let shared = SettingsWindowManager()

    private var window: NSWindow?

    private init() {}

    func open(with clipboardManager: ClipboardManager) {
        // If already open, just bring to front
        if let existing = window, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView()
            .environmentObject(clipboardManager)

        let hostingController = NSHostingController(rootView: settingsView)

        let newWindow = NSWindow(contentViewController: hostingController)
        newWindow.title = "DualClip Settings"
        newWindow.styleMask = [.titled, .closable]
        newWindow.setContentSize(NSSize(width: 420, height: 320))
        newWindow.center()
        newWindow.isReleasedWhenClosed = false
        newWindow.level = .floating

        // Revert activation policy when window closes
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: newWindow,
            queue: .main
        ) { [weak self] _ in
            self?.window = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                NSApp.setActivationPolicy(.accessory)
            }
        }

        self.window = newWindow

        NSApp.setActivationPolicy(.regular)
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
