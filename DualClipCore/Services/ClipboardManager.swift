import AppKit
import Combine

/// Manages clipboard polling and slot storage.
/// Polls NSPasteboard every 0.5 seconds to detect system clipboard changes.
final class ClipboardManager: ObservableObject {

    @Published var slotA = ClipboardSlot()
    @Published var slotB = ClipboardSlot()
    @Published var slotC = ClipboardSlot()

    /// The pasteboard this manager observes. Injectable so tests can run against
    /// a private `NSPasteboard.withUniqueName()` instead of the user's clipboard.
    let pasteboard: NSPasteboard

    private var lastChangeCount: Int
    private var pollingTimer: DispatchSourceTimer?

    /// `changeCount` as of our own most recent write.
    ///
    /// Replaces a "skip the next N changes" counter, which assumed one write
    /// bumps `changeCount` by exactly one. That increment is not contractual —
    /// `clearContents()` and `writeObjects(_:)` are separate operations and the
    /// count can drift between macOS versions. Worse, an over-count would
    /// swallow the *next* genuine change, so a copy made right after a paste
    /// never reached Slot A. Recording the observed value instead makes the
    /// check exact.
    private var ownedChangeCount: Int?

    /// When true, polling is suspended (used during copy/paste operations).
    private(set) var isPollingPaused = false

    /// Current `changeCount`, for callers that need a baseline before writing.
    var currentChangeCount: Int { pasteboard.changeCount }

    /// - Parameters:
    ///   - pasteboard: Pasteboard to observe. Defaults to the system clipboard.
    ///   - startPolling: Pass `false` in tests to drive `checkForChanges()` manually.
    init(pasteboard: NSPasteboard = .general, startPolling autoStart: Bool = true) {
        self.pasteboard = pasteboard
        lastChangeCount = pasteboard.changeCount
        syncSlotA()
        if autoStart { startPolling() }
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

    /// Internal rather than private so tests can drive a single poll tick
    /// deterministically instead of waiting on the timer.
    func checkForChanges() {
        let currentCount = pasteboard.changeCount
        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        // Our own write, not the user copying something.
        if currentCount == ownedChangeCount { return }

        if isPollingPaused { return }

        syncSlotA()
    }

    /// Temporarily pause polling during multi-step clipboard operations.
    func pausePolling() {
        isPollingPaused = true
    }

    /// Resume polling and resync Slot A with current clipboard.
    func resumePolling() {
        isPollingPaused = false
        ownedChangeCount = nil
        lastChangeCount = pasteboard.changeCount
        syncSlotA()
    }

    /// Sync Slot A with the current system clipboard content (all types).
    private func syncSlotA() {
        guard pasteboard.pasteboardItems?.isEmpty == false else { return }
        slotA.store(from: pasteboard)
        objectWillChange.send()
    }

    // MARK: - Slot Operations

    /// Copy current system clipboard content into the specified slot (all types).
    func copyToSlot(_ identifier: SlotIdentifier) {
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
        slot(for: identifier).write(to: pasteboard)
        // Record what the write actually produced rather than assuming +1.
        ownedChangeCount = pasteboard.changeCount
        lastChangeCount = pasteboard.changeCount
    }

    /// Backup entire system clipboard into a temporary slot.
    func backupSystemClipboard() -> ClipboardSlot {
        let backup = ClipboardSlot()
        backup.store(from: pasteboard)
        return backup
    }

    /// Restore previously backed-up clipboard contents.
    func restoreSystemClipboard(_ backup: ClipboardSlot) {
        guard !backup.isEmpty else { return }
        backup.write(to: pasteboard)
        ownedChangeCount = pasteboard.changeCount
        lastChangeCount = pasteboard.changeCount
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
