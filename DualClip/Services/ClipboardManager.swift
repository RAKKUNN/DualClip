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

    /// Sync Slot A with the current system clipboard content (all types).
    private func syncSlotA() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.pasteboardItems?.isEmpty == false else { return }
        slotA.store(from: pasteboard)
        objectWillChange.send()
    }

    // MARK: - Slot Operations

    /// Copy current system clipboard content into the specified slot (all types).
    func copyToSlot(_ identifier: SlotIdentifier) {
        let pasteboard = NSPasteboard.general
        guard pasteboard.pasteboardItems?.isEmpty == false else { return }
        slot(for: identifier).store(from: pasteboard)
        objectWillChange.send()
    }

    /// Check if a slot has content available for pasting.
    func hasContent(for identifier: SlotIdentifier) -> Bool {
        !slot(for: identifier).isEmpty
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

    /// Write a slot's full content to the system clipboard.
    func writeSlotToSystemClipboard(_ identifier: SlotIdentifier) {
        ignoreNextChange = true
        slot(for: identifier).write(to: NSPasteboard.general)
        lastChangeCount = NSPasteboard.general.changeCount
    }

    /// Backup entire system clipboard into a temporary slot.
    func backupSystemClipboard() -> ClipboardSlot {
        let backup = ClipboardSlot()
        backup.store(from: NSPasteboard.general)
        return backup
    }

    /// Restore previously backed-up clipboard contents.
    func restoreSystemClipboard(_ backup: ClipboardSlot) {
        guard !backup.isEmpty else { return }
        ignoreNextChange = true
        backup.write(to: NSPasteboard.general)
        lastChangeCount = NSPasteboard.general.changeCount
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
