import AppKit
import XCTest
@testable import DualClipCore

final class PasteboardWaiterTests: XCTestCase {

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

    private func write(_ string: String) {
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
    }

    func testReportsChangeThatAlreadyHappened() {
        write("before")
        let baseline = pasteboard.changeCount
        write("after")

        let expectation = expectation(description: "completion")
        var result: Bool?

        PasteboardWaiter.waitForChange(on: pasteboard, from: baseline, timeout: 0.5) {
            result = $0
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(result, true)
    }

    func testReportsChangeThatArrivesLater() {
        write("before")
        let baseline = pasteboard.changeCount

        let expectation = expectation(description: "completion")
        var result: Bool?

        PasteboardWaiter.waitForChange(on: pasteboard, from: baseline, timeout: 1.0) {
            result = $0
            expectation.fulfill()
        }

        // Land the change well after the first poll tick.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.write("after")
        }

        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(result, true)
    }

    /// A ⌘C that produces nothing must be reported as such rather than hanging
    /// or silently succeeding.
    func testReportsFailureWhenNothingChanges() {
        write("unchanged")
        let baseline = pasteboard.changeCount

        let expectation = expectation(description: "completion")
        var result: Bool?

        PasteboardWaiter.waitForChange(on: pasteboard, from: baseline, timeout: 0.15) {
            result = $0
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(result, false)
    }

    func testCallsCompletionExactlyOnce() {
        write("before")
        let baseline = pasteboard.changeCount
        write("after")

        let expectation = expectation(description: "completion")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true

        PasteboardWaiter.waitForChange(on: pasteboard, from: baseline, timeout: 0.3) { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
        // Give any stray reschedule a chance to fire and over-fulfil.
        let settle = expectation(description: "settle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { settle.fulfill() }
        wait(for: [settle], timeout: 1.0)
    }
}
