import AppKit
import Carbon.HIToolbox

/// Handles the Atomic Paste operation:
/// 1. Backup current system clipboard
/// 2. Replace with slot data
/// 3. Simulate ⌘V keystroke via CGEvent
/// 4. Restore original clipboard after a delay
final class AtomicPasteService {

    static let shared = AtomicPasteService()

    /// Delay before restoring the original clipboard (milliseconds).
    /// 150ms is an empirically safe value to prevent race conditions.
    private let restoreDelayMs: Int = 150

    private init() {}

    /// Perform an atomic paste from the given slot.
    /// - Parameters:
    ///   - slotContent: The text content to paste
    ///   - clipboardManager: The clipboard manager to coordinate with
    func paste(slotContent: String, clipboardManager: ClipboardManager) {
        guard AccessibilityService.shared.isAccessibilityGranted() else {
            return
        }

        // 1. Backup current system clipboard
        let backup = clipboardManager.backupSystemClipboard()

        // 2. Replace system clipboard with slot data
        clipboardManager.writeToSystemClipboard(slotContent)

        // 3. Simulate ⌘V keystroke
        simulatePaste()

        // 4. Restore original clipboard after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(restoreDelayMs)) {
            clipboardManager.restoreSystemClipboard(backup)
        }
    }

    // MARK: - CGEvent Key Simulation

    /// Simulate a ⌘V (Paste) keystroke using CGEvent.
    private func simulatePaste() {
        let source = CGEventSource(stateID: .hidSystemState)

        // Key code 9 = 'V' on US keyboard layout
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)

        // Add Command modifier
        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand

        // Post events to the HID system
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    /// Simulate a ⌘C (Copy) keystroke using CGEvent.
    /// Used to capture the current selection into the system clipboard.
    func simulateCopy() {
        guard AccessibilityService.shared.isAccessibilityGranted() else {
            return
        }

        let source = CGEventSource(stateID: .hidSystemState)

        // Key code 8 = 'C' on US keyboard layout
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_C), keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_C), keyDown: false)

        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}
