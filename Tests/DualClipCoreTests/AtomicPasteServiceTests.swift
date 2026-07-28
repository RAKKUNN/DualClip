import XCTest
@testable import DualClipCore

/// Covers the restore-delay preference. The keystroke simulation itself is not
/// tested here — posting CGEvents needs Accessibility permission and a real
/// session, neither of which exists on a CI runner.
final class AtomicPasteServiceTests: XCTestCase {

    private let key = AtomicPasteService.restoreDelayDefaultsKey

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: key)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: key)
        super.tearDown()
    }

    func testFallsBackToDefaultWhenUnset() {
        XCTAssertEqual(
            AtomicPasteService.shared.restoreDelayMs,
            AtomicPasteService.defaultRestoreDelayMs
        )
    }

    func testHonoursAValueInsideTheRange() {
        UserDefaults.standard.set(350, forKey: key)
        XCTAssertEqual(AtomicPasteService.shared.restoreDelayMs, 350)
    }

    /// A too-short delay would cut the paste off mid-read, so out-of-range
    /// values are clamped rather than trusted.
    func testClampsValueBelowTheRange() {
        UserDefaults.standard.set(10, forKey: key)
        XCTAssertEqual(
            AtomicPasteService.shared.restoreDelayMs,
            AtomicPasteService.restoreDelayRangeMs.lowerBound
        )
    }

    func testClampsValueAboveTheRange() {
        UserDefaults.standard.set(5_000, forKey: key)
        XCTAssertEqual(
            AtomicPasteService.shared.restoreDelayMs,
            AtomicPasteService.restoreDelayRangeMs.upperBound
        )
    }

    func testDefaultIsInsideTheAllowedRange() {
        XCTAssertTrue(
            AtomicPasteService.restoreDelayRangeMs.contains(AtomicPasteService.defaultRestoreDelayMs)
        )
    }
}
