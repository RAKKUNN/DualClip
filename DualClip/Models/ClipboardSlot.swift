import Foundation

/// Represents a single clipboard slot holding text content.
final class ClipboardSlot {
    var content: String?
    var timestamp: Date?

    var isEmpty: Bool {
        content == nil || content?.isEmpty == true
    }

    /// Preview text truncated to a given length.
    func preview(maxLength: Int = 40) -> String {
        guard let text = content, !text.isEmpty else {
            return "(empty)"
        }
        let singleLine = text.replacingOccurrences(of: "\n", with: " ")
        if singleLine.count <= maxLength {
            return singleLine
        }
        return String(singleLine.prefix(maxLength)) + "…"
    }

    /// Store new content with the current timestamp.
    func store(_ text: String) {
        content = text
        timestamp = Date()
    }

    /// Clear the slot content.
    func clear() {
        content = nil
        timestamp = nil
    }
}
