import AppKit
import Combine

/// Manages clipboard polling and slot storage.
/// Polls NSPasteboard every 0.5 seconds to detect system clipboard changes.
final class ClipboardManager: ObservableObject {

    @Published var slotA = ClipboardSlot()
    @Published var slotB = ClipboardSlot()
    @Published var slotC = ClipboardSlot()

    private var lastChangeCount: Int
    private var pollingTimer: DispatchSourceTimer?

    /// Flag to temporarily ignore clipboard changes caused by our own writes.
    private var ignoreNextChange = false

    init() {
        lastChangeCount = NSPasteboard.general.changeCount
        syncSlotA()
        startPolling()
    }

    deinit {
        stopPolling()
    }

    // MARK: - Polling

    private func startPolling() {
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now(), repeating: .milliseconds(500))
        timer.setEventHandler { [weak self] in
            self?.checkForChanges()
        }
        timer.resume()
        pollingTimer = timer
    }

    private func stopPolling() {
        pollingTimer?.cancel()
        pollingTimer = nil
    }

    private func checkForChanges() {
        let currentCount = NSPasteboard.general.changeCount
        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        if ignoreNextChange {
            ignoreNextChange = false
            return
        }

        syncSlotA()
    }

    /// Sync Slot A with the current system clipboard content.
    private func syncSlotA() {
        if let text = NSPasteboard.general.string(forType: .string) {
            slotA.store(text)
            objectWillChange.send()
        }
    }

    // MARK: - Slot Operations

    /// Copy current system clipboard content into the specified slot.
    func copyToSlot(_ identifier: SlotIdentifier) {
        guard let text = NSPasteboard.general.string(forType: .string) else { return }
        slot(for: identifier).store(text)
        objectWillChange.send()
    }

    /// Get the content of a specific slot.
    func content(for identifier: SlotIdentifier) -> String? {
        slot(for: identifier).content
    }

    /// Clear a specific slot.
    func clearSlot(_ identifier: SlotIdentifier) {
        slot(for: identifier).clear()
        objectWillChange.send()
    }

    /// Clear all slots (B and C only; A mirrors the system clipboard).
    func clearAllSlots() {
        slotB.clear()
        slotC.clear()
        objectWillChange.send()
    }

    /// Write text to the system clipboard, marking it to be ignored by polling.
    func writeToSystemClipboard(_ text: String) {
        ignoreNextChange = true
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        lastChangeCount = pasteboard.changeCount
    }

    /// Backup current system clipboard content.
    func backupSystemClipboard() -> String? {
        NSPasteboard.general.string(forType: .string)
    }

    /// Restore previously backed-up content to the system clipboard.
    func restoreSystemClipboard(_ text: String?) {
        guard let text = text else { return }
        writeToSystemClipboard(text)
    }

    // MARK: - Helpers

    func slot(for identifier: SlotIdentifier) -> ClipboardSlot {
        switch identifier {
        case .A: return slotA
        case .B: return slotB
        case .C: return slotC
        }
    }
}
