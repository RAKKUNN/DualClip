import AppKit
import KeyboardShortcuts

/// Registers global keyboard shortcut handlers and connects them to clipboard operations.
final class ShortcutHandler {

    private let clipboardManager: ClipboardManager

    /// Delay after simulating ⌘C before reading the clipboard (milliseconds).
    private let copyReadDelayMs: Int = 100

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
    /// Simulates ⌘C, waits briefly, then reads the clipboard into the slot.
    private func handleCopy(to slot: SlotIdentifier) {
        // Simulate ⌘C to capture the current selection
        AtomicPasteService.shared.simulateCopy()

        // Wait for the system to process the copy, then store in slot
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(copyReadDelayMs)) { [weak self] in
            self?.clipboardManager.copyToSlot(slot)
        }
    }

    /// Paste content from the specified slot using atomic paste.
    private func handlePaste(from slot: SlotIdentifier) {
        guard let content = clipboardManager.content(for: slot), !content.isEmpty else {
            return
        }
        AtomicPasteService.shared.paste(slotContent: content, clipboardManager: clipboardManager)
    }
}
