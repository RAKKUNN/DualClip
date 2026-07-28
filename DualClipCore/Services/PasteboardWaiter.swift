import AppKit

/// Waits for a pasteboard to actually change, instead of sleeping for a fixed
/// interval and hoping.
///
/// `changeCount` is the only observable signal AppKit gives us here, and it only
/// reacts to *writes*. That makes it a reliable way to know when a simulated ⌘C
/// has landed — but note there is no equivalent signal for a *read*, so the
/// delay before restoring the clipboard after a paste cannot be replaced this
/// way (see `AtomicPasteService`).
enum PasteboardWaiter {

    /// Polls until `pasteboard.changeCount` differs from `baseline`.
    ///
    /// Typically completes in a few tens of milliseconds — faster than the fixed
    /// delay it replaces, while also being correct when the app is slow.
    ///
    /// - Parameters:
    ///   - baseline: `changeCount` captured before triggering the write.
    ///   - timeout: Give up after this long and report `false`.
    ///   - completion: Called on the main queue with whether a change was seen.
    static func waitForChange(
        on pasteboard: NSPasteboard,
        from baseline: Int,
        timeout: TimeInterval = 0.6,
        pollInterval: TimeInterval = 0.01,
        completion: @escaping (_ changed: Bool) -> Void
    ) {
        let poller = Poller(
            pasteboard: pasteboard,
            baseline: baseline,
            deadline: Date().addingTimeInterval(timeout),
            pollInterval: pollInterval,
            completion: completion
        )
        poller.start()
    }

    /// Keeps itself alive through the closure it schedules, and releases once it
    /// stops rescheduling.
    private final class Poller {
        private let pasteboard: NSPasteboard
        private let baseline: Int
        private let deadline: Date
        private let pollInterval: TimeInterval
        private var completion: ((Bool) -> Void)?

        init(
            pasteboard: NSPasteboard,
            baseline: Int,
            deadline: Date,
            pollInterval: TimeInterval,
            completion: @escaping (Bool) -> Void
        ) {
            self.pasteboard = pasteboard
            self.baseline = baseline
            self.deadline = deadline
            self.pollInterval = pollInterval
            self.completion = completion
        }

        func start() {
            tick()
        }

        private func tick() {
            if pasteboard.changeCount != baseline {
                finish(changed: true)
                return
            }
            guard Date() < deadline else {
                finish(changed: false)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + pollInterval) {
                self.tick()
            }
        }

        private func finish(changed: Bool) {
            guard let completion else { return }
            self.completion = nil
            completion(changed)
        }
    }
}
