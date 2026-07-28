import AppKit
import XCTest
@testable import DualClipCore

/// Tests for `ClipboardManager`.
///
/// The manager is built with `startPolling: false` so the poll tick can be
/// driven by calling `checkForChanges()` directly — no timers, no waiting,
/// no flakiness.
final class ClipboardManagerTests: XCTestCase {

    private var pasteboard: NSPasteboard!

    override func setUp() {
        super.setUp()
        pasteboard = NSPasteboard.withUniqueName()
    }

    override func tearDown() {
        pasteboard.releaseGlobally()
        pasteboard = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func write(_ string: String) {
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
    }

    private func makeManager() -> ClipboardManager {
        ClipboardManager(pasteboard: pasteboard, startPolling: false)
    }

    // MARK: - Slot A mirroring

    func testSlotAAdoptsPasteboardContentOnInit() {
        write("at launch")

        let manager = makeManager()

        XCTAssertEqual(manager.slotA.textContent, "at launch")
    }

    func testExternalChangeUpdatesSlotA() {
        write("first")
        let manager = makeManager()

        write("second")
        manager.checkForChanges()

        XCTAssertEqual(manager.slotA.textContent, "second")
    }

    /// Slot A mirrors the *system* clipboard. When DualClip itself writes — as
    /// it does mid-paste — that write must not be mistaken for the user copying
    /// something.
    func testOwnWriteDoesNotUpdateSlotA() {
        write("user content")
        let manager = makeManager()
        manager.slotB.store("slot b content")

        manager.writeSlotToSystemClipboard(.B)
        manager.checkForChanges()

        XCTAssertEqual(manager.slotA.textContent, "user content")
    }

    /// Regression test. The previous implementation counted how many upcoming
    /// changes to ignore and incremented that counter on every write of our own.
    /// The counter was only spent on the *next* observed change, so a copy made
    /// right after DualClip touched the clipboard got swallowed and never
    /// reached Slot A. Tracking the observed `changeCount` instead makes the
    /// check exact.
    func testExternalChangeRightAfterOwnWriteStillUpdatesSlotA() {
        write("user content")
        let manager = makeManager()
        manager.slotB.store("slot b content")

        manager.writeSlotToSystemClipboard(.B)
        manager.checkForChanges()
        XCTAssertEqual(manager.slotA.textContent, "user content", "our own write must be ignored")

        write("copied moments later")
        manager.checkForChanges()

        XCTAssertEqual(manager.slotA.textContent, "copied moments later")
    }

    func testCurrentChangeCountTracksThePasteboard() {
        write("first")
        let manager = makeManager()
        let before = manager.currentChangeCount

        write("second")

        XCTAssertNotEqual(manager.currentChangeCount, before)
    }

    func testPausedPollingDoesNotUpdateSlotA() {
        write("before pause")
        let manager = makeManager()

        manager.pausePolling()
        write("during pause")
        manager.checkForChanges()

        XCTAssertEqual(manager.slotA.textContent, "before pause")
    }

    func testResumePollingResyncsSlotA() {
        write("before pause")
        let manager = makeManager()

        manager.pausePolling()
        write("during pause")
        manager.resumePolling()

        XCTAssertFalse(manager.isPollingPaused)
        XCTAssertEqual(manager.slotA.textContent, "during pause")
    }

    // MARK: - Slot operations

    func testCopyToSlotCapturesCurrentPasteboard() {
        write("copy me")
        let manager = makeManager()

        manager.copyToSlot(.B)

        XCTAssertEqual(manager.slotB.textContent, "copy me")
        XCTAssertTrue(manager.hasContent(for: .B))
    }

    func testCopyToSlotIgnoresEmptyPasteboard() {
        write("existing")
        let manager = makeManager()
        manager.copyToSlot(.B)

        pasteboard.clearContents()
        manager.copyToSlot(.B)

        XCTAssertEqual(manager.slotB.textContent, "existing")
    }

    func testHasContentReflectsSlotState() {
        write("anything")
        let manager = makeManager()

        XCTAssertFalse(manager.hasContent(for: .C))
        manager.copyToSlot(.C)
        XCTAssertTrue(manager.hasContent(for: .C))
    }

    func testClearSlotOnlyAffectsTheTargetSlot() {
        write("shared")
        let manager = makeManager()
        manager.copyToSlot(.B)
        manager.copyToSlot(.C)

        manager.clearSlot(.B)

        XCTAssertFalse(manager.hasContent(for: .B))
        XCTAssertTrue(manager.hasContent(for: .C))
    }

    /// Slot A is a live mirror of the system clipboard, so "clear all" must
    /// leave it alone — otherwise the popover would show an empty Slot A while
    /// the clipboard still holds content.
    func testClearAllSlotsPreservesSlotA() {
        write("system content")
        let manager = makeManager()
        manager.copyToSlot(.B)
        manager.copyToSlot(.C)

        manager.clearAllSlots()

        XCTAssertFalse(manager.hasContent(for: .B))
        XCTAssertFalse(manager.hasContent(for: .C))
        XCTAssertEqual(manager.slotA.textContent, "system content")
    }

    // MARK: - Backup / restore

    func testBackupAndRestoreRoundTripsThePasteboard() {
        write("original")
        let manager = makeManager()
        manager.slotB.store("replacement")

        let backup = manager.backupSystemClipboard()
        manager.writeSlotToSystemClipboard(.B)
        XCTAssertEqual(pasteboard.string(forType: .string), "replacement")

        manager.restoreSystemClipboard(backup)

        XCTAssertEqual(pasteboard.string(forType: .string), "original")
    }

    func testRestoringAnEmptyBackupLeavesThePasteboardAlone() {
        write("keep me")
        let manager = makeManager()

        manager.restoreSystemClipboard(ClipboardSlot())

        XCTAssertEqual(pasteboard.string(forType: .string), "keep me")
    }

    // MARK: - Lookup

    func testSlotLookupReturnsDistinctSlots() {
        write("anything")
        let manager = makeManager()

        XCTAssertTrue(manager.slot(for: .A) === manager.slotA)
        XCTAssertTrue(manager.slot(for: .B) === manager.slotB)
        XCTAssertTrue(manager.slot(for: .C) === manager.slotC)
    }
}
