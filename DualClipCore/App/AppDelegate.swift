import AppKit

/// App delegate handling lifecycle events and initial setup.
final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationWillFinishLaunching(_ notification: Notification) {
        // Register bundle identifier for SPM executable (no embedded Info.plist)
        UserDefaults.standard.register(defaults: [
            "NSApplicationBundleIdentifier": "com.dualclip.app"
        ])
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check accessibility permission on launch
        if !AccessibilityService.shared.isAccessibilityGranted() {
            AccessibilityService.shared.requestAccessibility()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Securely wipe all clipboard slot data (zero-fill RAM before release)
        guard let manager = AppState.current?.clipboardManager else { return }
        manager.slotA.secureWipe()
        manager.slotB.secureWipe()
        manager.slotC.secureWipe()
    }
}
