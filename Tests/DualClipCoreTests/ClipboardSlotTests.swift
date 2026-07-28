import AppKit
import XCTest
@testable import DualClipCore

/// Tests for `ClipboardSlot` — the pure storage/preview logic.
///
/// Every test runs against a private `NSPasteboard.withUniqueName()` so the
/// suite never reads or clobbers the machine's real clipboard.
final class ClipboardSlotTests: XCTestCase {

    private var pasteboard: NSPasteboard!
    private var destination: NSPasteboard!

    override func setUp() {
        super.setUp()
        pasteboard = NSPasteboard.withUniqueName()
        destination = NSPasteboard.withUniqueName()
    }

    override func tearDown() {
        pasteboard.releaseGlobally()
        destination.releaseGlobally()
        pasteboard = nil
        destination = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func writeString(_ string: String, to board: NSPasteboard) {
        board.clearContents()
        board.setString(string, forType: .string)
    }

    private func makeRTFData(_ string: String) throws -> Data {
        let attributed = NSAttributedString(
            string: string,
            attributes: [.font: NSFont.systemFont(ofSize: 13)]
        )
        let data = attributed.rtf(
            from: NSRange(location: 0, length: attributed.length),
            documentAttributes: [:]
        )
        return try XCTUnwrap(data)
    }

    private func makeTIFFData() throws -> Data {
        let image = NSImage(size: NSSize(width: 4, height: 4))
        image.lockFocus()
        NSColor.red.drawSwatch(in: NSRect(x: 0, y: 0, width: 4, height: 4))
        image.unlockFocus()
        return try XCTUnwrap(image.tiffRepresentation)
    }

    // MARK: - Store / write round trips

    func testStoreAndWriteRoundTripsPlainText() {
        writeString("hello world", to: pasteboard)

        let slot = ClipboardSlot()
        slot.store(from: pasteboard)
        slot.write(to: destination)

        XCTAssertEqual(destination.string(forType: .string), "hello world")
    }

    func testStoreAndWriteRoundTripsRTF() throws {
        let rtfData = try makeRTFData("styled text")
        pasteboard.clearContents()
        pasteboard.setData(rtfData, forType: .rtf)

        let slot = ClipboardSlot()
        slot.store(from: pasteboard)
        slot.write(to: destination)

        let restored = try XCTUnwrap(destination.data(forType: .rtf))
        let attributed = try XCTUnwrap(NSAttributedString(rtf: restored, documentAttributes: nil))
        XCTAssertEqual(attributed.string, "styled text")
    }

    /// A single pasteboard item usually carries several representations of the
    /// same content. Dropping any of them degrades the paste in the target app.
    func testStorePreservesEveryTypeOnAnItem() throws {
        let rtfData = try makeRTFData("rich")
        pasteboard.clearContents()
        let item = NSPasteboardItem()
        item.setString("rich", forType: .string)
        item.setData(rtfData, forType: .rtf)
        pasteboard.writeObjects([item])

        let slot = ClipboardSlot()
        slot.store(from: pasteboard)
        slot.write(to: destination)

        XCTAssertEqual(destination.string(forType: .string), "rich")
        XCTAssertNotNil(destination.data(forType: .rtf))
    }

    func testStorePreservesMultipleItems() {
        pasteboard.clearContents()
        pasteboard.writeObjects([
            URL(fileURLWithPath: "/tmp/one.txt") as NSURL,
            URL(fileURLWithPath: "/tmp/two.txt") as NSURL
        ])

        let slot = ClipboardSlot()
        slot.store(from: pasteboard)

        XCTAssertEqual(slot.storedItems?.count, 2)
    }

    /// `NSPasteboardItem` can only ever belong to one pasteboard, so `write`
    /// has to hand out fresh copies. If it didn't, the second paste would come
    /// out empty.
    func testWriteIsRepeatable() {
        writeString("repeat me", to: pasteboard)

        let slot = ClipboardSlot()
        slot.store(from: pasteboard)

        slot.write(to: destination)
        XCTAssertEqual(destination.string(forType: .string), "repeat me")

        let second = NSPasteboard.withUniqueName()
        defer { second.releaseGlobally() }
        slot.write(to: second)
        XCTAssertEqual(second.string(forType: .string), "repeat me")
    }

    // MARK: - Content type detection

    func testDetectsPlainText() {
        writeString("just text", to: pasteboard)

        let slot = ClipboardSlot()
        slot.store(from: pasteboard)

        XCTAssertEqual(slot.contentType, .text)
        XCTAssertEqual(slot.textContent, "just text")
        XCTAssertNil(slot.imageContent)
        XCTAssertNil(slot.fileURLs)
    }

    func testDetectsRTF() throws {
        let rtfData = try makeRTFData("styled")
        pasteboard.clearContents()
        pasteboard.setData(rtfData, forType: .rtf)

        let slot = ClipboardSlot()
        slot.store(from: pasteboard)

        XCTAssertEqual(slot.contentType, .rtf)
        XCTAssertEqual(slot.textContent, "styled")
    }

    func testDetectsImage() throws {
        let tiff = try makeTIFFData()
        pasteboard.clearContents()
        pasteboard.setData(tiff, forType: .tiff)

        let slot = ClipboardSlot()
        slot.store(from: pasteboard)

        XCTAssertEqual(slot.contentType, .image)
        XCTAssertNotNil(slot.imageContent)
    }

    /// File URLs win over every other representation — Finder puts a string
    /// version on the pasteboard too, and pasting that instead loses the files.
    func testFileURLTakesPriorityOverText() {
        pasteboard.clearContents()
        pasteboard.writeObjects([URL(fileURLWithPath: "/tmp/report.pdf") as NSURL])

        let slot = ClipboardSlot()
        slot.store(from: pasteboard)

        XCTAssertEqual(slot.contentType, .fileURL)
        XCTAssertEqual(slot.fileURLs?.count, 1)
        XCTAssertEqual(slot.fileURLs?.first?.lastPathComponent, "report.pdf")
    }

    // MARK: - Preview

    func testPreviewReturnsPlaceholderWhenEmpty() {
        XCTAssertEqual(ClipboardSlot().preview(), "(empty)")
    }

    func testPreviewReturnsShortTextUnchanged() {
        let slot = ClipboardSlot()
        slot.store("short")
        XCTAssertEqual(slot.preview(maxLength: 40), "short")
    }

    func testPreviewTruncatesWithEllipsis() {
        let slot = ClipboardSlot()
        slot.store(String(repeating: "a", count: 100))

        let preview = slot.preview(maxLength: 10)

        XCTAssertTrue(preview.hasSuffix("…"))
        XCTAssertEqual(preview.count, 11, "10 characters plus the ellipsis")
    }

    func testPreviewCollapsesNewlines() {
        let slot = ClipboardSlot()
        slot.store("line one\nline two")
        XCTAssertEqual(slot.preview(maxLength: 40), "line one line two")
    }

    func testPreviewPrefixesRTFAndStaysWithinBudget() throws {
        let rtfData = try makeRTFData(String(repeating: "b", count: 100))
        pasteboard.clearContents()
        pasteboard.setData(rtfData, forType: .rtf)

        let slot = ClipboardSlot()
        slot.store(from: pasteboard)

        let preview = slot.preview(maxLength: 20)

        XCTAssertTrue(preview.hasPrefix("[RTF] "))
        // 20 characters total, of which 6 are the prefix, plus the ellipsis.
        XCTAssertEqual(preview.count, 21)
    }

    func testPreviewNamesSingleFileAndCountsMultiple() {
        let single = ClipboardSlot()
        pasteboard.clearContents()
        pasteboard.writeObjects([URL(fileURLWithPath: "/tmp/only.txt") as NSURL])
        single.store(from: pasteboard)
        XCTAssertEqual(single.preview(), "only.txt")

        let multiple = ClipboardSlot()
        let board = NSPasteboard.withUniqueName()
        defer { board.releaseGlobally() }
        board.clearContents()
        board.writeObjects([
            URL(fileURLWithPath: "/tmp/a.txt") as NSURL,
            URL(fileURLWithPath: "/tmp/b.txt") as NSURL,
            URL(fileURLWithPath: "/tmp/c.txt") as NSURL
        ])
        multiple.store(from: board)
        XCTAssertEqual(multiple.preview(), "3 files")
    }

    func testPreviewLabelsImages() throws {
        let tiff = try makeTIFFData()
        pasteboard.clearContents()
        pasteboard.setData(tiff, forType: .tiff)

        let slot = ClipboardSlot()
        slot.store(from: pasteboard)

        XCTAssertEqual(slot.preview(), "Image")
    }

    // MARK: - Clearing

    func testClearResetsEveryField() {
        writeString("content", to: pasteboard)
        let slot = ClipboardSlot()
        slot.store(from: pasteboard)
        XCTAssertFalse(slot.isEmpty)

        slot.clear()

        XCTAssertTrue(slot.isEmpty)
        XCTAssertNil(slot.contentType)
        XCTAssertNil(slot.textContent)
        XCTAssertNil(slot.imageContent)
        XCTAssertNil(slot.fileURLs)
        XCTAssertNil(slot.timestamp)
    }

    func testSecureWipeEmptiesTheSlot() {
        writeString("sensitive", to: pasteboard)
        let slot = ClipboardSlot()
        slot.store(from: pasteboard)

        slot.secureWipe()

        XCTAssertTrue(slot.isEmpty)
        XCTAssertNil(slot.textContent)
        XCTAssertNil(slot.storedItems)
    }

    /// `resetBytes(in:)` only zeroes in place while the buffer is uniquely
    /// referenced — under copy-on-write, a second reference would silently make
    /// it zero a fresh copy and release the original untouched. This exercises
    /// the wipe path on a slot whose data went through the normal store flow;
    /// the ownership handling itself lives in `secureWipe`.
    func testSecureWipeIsSafeToCallTwice() {
        writeString("sensitive", to: pasteboard)
        let slot = ClipboardSlot()
        slot.store(from: pasteboard)

        slot.secureWipe()
        slot.secureWipe()

        XCTAssertTrue(slot.isEmpty)
    }

    func testSecureWipeOnEmptySlotIsANoOp() {
        let slot = ClipboardSlot()
        slot.secureWipe()
        XCTAssertTrue(slot.isEmpty)
    }

    func testStoreTextConvenienceSetsTextType() {
        let slot = ClipboardSlot()
        slot.store("direct")

        XCTAssertEqual(slot.contentType, .text)
        XCTAssertEqual(slot.textContent, "direct")
        XCTAssertFalse(slot.isEmpty)
        XCTAssertNotNil(slot.timestamp)
    }
}
