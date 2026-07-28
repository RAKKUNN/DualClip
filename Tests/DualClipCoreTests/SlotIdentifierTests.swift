import XCTest
@testable import DualClipCore

final class SlotIdentifierTests: XCTestCase {

    /// The menu bar popover renders `allCases` in order, so A/B/C is not just
    /// cosmetic — reordering would silently reshuffle the UI.
    func testAllCasesAreInDisplayOrder() {
        XCTAssertEqual(SlotIdentifier.allCases, [.A, .B, .C])
    }

    func testIdentifierMatchesRawValue() {
        for slot in SlotIdentifier.allCases {
            XCTAssertEqual(slot.id, slot.rawValue)
        }
    }

    func testSlotAIsLabelledAsTheSystemSlot() {
        XCTAssertEqual(SlotIdentifier.A.displayName, "Slot A (System)")
        XCTAssertEqual(SlotIdentifier.B.displayName, "Slot B")
        XCTAssertEqual(SlotIdentifier.C.displayName, "Slot C")
    }

    func testShortLabelsAreSingleCharacters() {
        for slot in SlotIdentifier.allCases {
            XCTAssertEqual(slot.shortLabel.count, 1)
        }
    }
}
