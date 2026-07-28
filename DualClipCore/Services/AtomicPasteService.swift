import AppKit
import Carbon.HIToolbox

/// Handles the Atomic Paste operation:
/// 1. Backup current system clipboard
/// 2. Replace with slot data
/// 3. Simulate ⌘V keystroke via CGEvent
/// 4. Restore original clipboard after a delay
final class AtomicPasteService {

    static let shared = AtomicPasteService()

    /// Key used to persist the user's restore-delay preference.
    static let restoreDelayDefaultsKey = "pasteRestoreDelayMs"

    static let defaultRestoreDelayMs = 200
    static let restoreDelayRangeMs = 100...500

    /// How long to leave slot content on the clipboard before putting the
    /// user's own content back.
    ///
    /// This one genuinely cannot be derived from `changeCount`: that only
    /// reports writes, and what we are waiting for here is the target app
    /// *reading* the pasteboard, which AppKit does not expose. So it stays a
    /// delay — but a longer default than before, and adjustable in Settings for
    /// apps that take their time.
    var restoreDelayMs: Int {
        let stored = UserDefaults.standard.integer(forKey: Self.restoreDelayDefaultsKey)
        guard stored != 0 else { return Self.defaultRestoreDelayMs }
        return min(max(stored, Self.restoreDelayRangeMs.lowerBound),
                   Self.restoreDelayRangeMs.upperBound)
    }

    private init() {}

    /// Perform an atomic paste from the given slot (supports all content types).
    /// - Parameters:
    ///   - slot: The slot identifier to paste from
    ///   - clipboardManager: The clipboard manager to coordinate with
    func paste(from slot: SlotIdentifier, clipboardManager: ClipboardManager) {
        guard clipboardManager.hasContent(for: slot) else { return }

        // Pause polling for the entire atomic operation
        clipboardManager.pausePolling()

        // 1. Backup current system clipboard (all types)
        let backup = clipboardManager.backupSystemClipboard()
        let before = clipboardManager.currentChangeCount

        // 2. Replace system clipboard with slot data (all types)
        clipboardManager.writeSlotToSystemClipboard(slot)
        let afterWrite = clipboardManager.currentChangeCount

        // 3. Only send ⌘V once the write is confirmed. Firing blind risks
        //    pasting whatever was on the clipboard before.
        guard afterWrite != before else {
            clipboardManager.resumePolling()
            return
        }
        simulatePaste()

        // 4. Restore the original clipboard, then resume polling.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(restoreDelayMs)) {
            // If the count moved, someone else wrote to the clipboard while we
            // were waiting — most likely the user pressing ⌘C. Restoring now
            // would silently destroy what they just copied.
            if clipboardManager.currentChangeCount == afterWrite {
                clipboardManager.restoreSystemClipboard(backup)
            }
            clipboardManager.resumePolling()
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
