import AppKit
import KeyboardShortcuts

/// Registers global keyboard shortcut handlers and connects them to clipboard operations.
final class ShortcutHandler {

    private let clipboardManager: ClipboardManager

    init(clipboardManager: ClipboardManager) {
        self.clipboardManager = clipboardManager
        registerShortcuts()
    }

    private func registerShortcuts() {
        // Slot B: Copy
        KeyboardShortcuts.onKeyUp(for: .copyB) { [weak self] in
            self?.handleCopy(to: .B)
        }

        // Slot B: Paste
        KeyboardShortcuts.onKeyUp(for: .pasteB) { [weak self] in
            self?.handlePaste(from: .B)
        }

        // Slot C: Copy
        KeyboardShortcuts.onKeyUp(for: .copyC) { [weak self] in
            self?.handleCopy(to: .C)
        }

        // Slot C: Paste
        KeyboardShortcuts.onKeyUp(for: .pasteC) { [weak self] in
            self?.handlePaste(from: .C)
        }
    }

    /// Copy the current selection into the specified slot.
    /// Simulates ⌘C, waits for the clipboard to actually change, then reads it
    /// into the slot.
    private func handleCopy(to slot: SlotIdentifier) {
        // Skip when a secure input field (e.g. password) is focused
        guard !AccessibilityService.shared.isSecureInputActive() else { return }

        let manager = clipboardManager

        // Pause polling to prevent Slot A from racing with this copy
        manager.pausePolling()

        // Backup current system clipboard so Slot A stays unchanged
        let backup = manager.backupSystemClipboard()
        let baseline = manager.currentChangeCount

        // Simulate ⌘C to capture the current selection
        AtomicPasteService.shared.simulateCopy()

        PasteboardWaiter.waitForChange(on: manager.pasteboard, from: baseline) { changed in
            // No change means the ⌘C produced nothing — an empty selection, or
            // an app that ignores the keystroke. Storing anyway would copy
            // whatever was already on the clipboard into the slot, which looks
            // to the user like the shortcut grabbed the wrong thing.
            if changed {
                manager.copyToSlot(slot)
            }
            manager.restoreSystemClipboard(backup)
            manager.resumePolling()
        }
    }

    /// Paste content from the specified slot using atomic paste (all types).
    private func handlePaste(from slot: SlotIdentifier) {
        // Skip when a secure input field (e.g. password) is focused
        guard !AccessibilityService.shared.isSecureInputActive() else { return }

        AtomicPasteService.shared.paste(from: slot, clipboardManager: clipboardManager)
    }
}
