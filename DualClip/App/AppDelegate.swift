import AppKit

/// App delegate handling lifecycle events and initial setup.
final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check accessibility permission on launch
        if !AccessibilityService.shared.isAccessibilityGranted() {
            AccessibilityService.shared.requestAccessibility()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Future: Zeroing-out slot data for security
    }
}
