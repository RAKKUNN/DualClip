import AppKit
import ApplicationServices

/// Manages Accessibility and Input Monitoring permission checks and requests.
final class AccessibilityService: ObservableObject {

    static let shared = AccessibilityService()

    @Published var isGranted: Bool

    /// Prevents the system dialog from being shown too frequently.
    private var lastPromptDate: Date = .distantPast
    private let promptCooldown: TimeInterval = 30

    private init() {
        isGranted = AXIsProcessTrusted()
    }

    /// Check if accessibility permission is currently granted.
    func isAccessibilityGranted() -> Bool {
        let granted = AXIsProcessTrusted()
        DispatchQueue.main.async {
            self.isGranted = granted
        }
        return granted
    }

    /// Prompt the system accessibility permission dialog.
    /// On macOS, this opens System Settings > Privacy & Security > Accessibility.
    /// Throttled to avoid repeated dialogs within the cooldown period.
    func requestAccessibility() {
        let now = Date()
        guard now.timeIntervalSince(lastPromptDate) > promptCooldown else { return }
        lastPromptDate = now
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    /// Open System Settings directly to Accessibility pane.
    func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    /// Open System Settings directly to Input Monitoring pane.
    func openInputMonitoringSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
            NSWorkspace.shared.open(url)
        }
    }

    /// Periodically re-check permission status (useful after user grants access).
    func startPermissionPolling(interval: TimeInterval = 2.0, completion: @escaping (Bool) -> Void) {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            let granted = self.isAccessibilityGranted()
            if granted {
                timer.invalidate()
                completion(true)
            }
        }
    }
}
