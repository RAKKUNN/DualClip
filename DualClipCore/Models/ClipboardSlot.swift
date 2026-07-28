import AppKit

/// The type of content stored in a clipboard slot.
enum ClipboardContentType: Equatable {
    case text
    case image
    case fileURL
    case rtf
}

/// Represents a single clipboard slot that can hold text, images, files, or RTF data.
final class ClipboardSlot {
    /// Raw pasteboard data for faithful clipboard restoration — one dictionary
    /// of type→data per pasteboard item.
    ///
    /// Stored as plain `Data` rather than `NSPasteboardItem` so that
    /// `secureWipe()` can zero the bytes through `Data.resetBytes(in:)`, a
    /// documented mutating API. The previous implementation wrote through a
    /// pointer obtained from an *immutable* `Data`'s `withUnsafeBytes`, which
    /// is undefined behaviour and liable to break under Swift 6.
    private(set) var storedItems: [[NSPasteboard.PasteboardType: Data]]?

    /// The dominant content type for display purposes.
    private(set) var contentType: ClipboardContentType?

    /// Cached text representation (for text and RTF).
    private(set) var textContent: String?

    /// Cached image representation (for image content).
    private(set) var imageContent: NSImage?

    /// Cached file URLs (for file content).
    private(set) var fileURLs: [URL]?

    var timestamp: Date?

    var isEmpty: Bool {
        storedItems == nil
    }

    // MARK: - Preview

    /// Preview text truncated to a given length.
    func preview(maxLength: Int = 40) -> String {
        guard !isEmpty else { return "(empty)" }

        switch contentType {
        case .image:
            return "Image"
        case .fileURL:
            if let urls = fileURLs {
                if urls.count == 1 {
                    return urls[0].lastPathComponent
                }
                return "\(urls.count) files"
            }
            return "File"
        case .rtf:
            return textPreview(maxLength: maxLength, prefix: "[RTF] ")
        case .text, .none:
            return textPreview(maxLength: maxLength)
        }
    }

    private func textPreview(maxLength: Int, prefix: String = "") -> String {
        guard let text = textContent, !text.isEmpty else { return "(empty)" }
        let singleLine = text.replacingOccurrences(of: "\n", with: " ")
        let available = maxLength - prefix.count
        if singleLine.count <= available {
            return prefix + singleLine
        }
        return prefix + String(singleLine.prefix(available)) + "…"
    }

    // MARK: - Store from Pasteboard

    /// Capture the current system pasteboard contents into this slot.
    func store(from pasteboard: NSPasteboard) {
        var copiedItems: [[NSPasteboard.PasteboardType: Data]] = []
        for item in pasteboard.pasteboardItems ?? [] {
            var copy: [NSPasteboard.PasteboardType: Data] = [:]
            for type in item.types {
                if let data = item.data(forType: type) {
                    copy[type] = data
                }
            }
            if !copy.isEmpty {
                copiedItems.append(copy)
            }
        }
        storedItems = copiedItems.isEmpty ? nil : copiedItems
        timestamp = Date()

        // Detect dominant content type and cache
        detectContentType(from: pasteboard)
    }

    /// Store plain text directly (backward-compatible convenience).
    func store(_ text: String) {
        storedItems = [[.string: Data(text.utf8)]]
        contentType = .text
        textContent = text
        imageContent = nil
        fileURLs = nil
        timestamp = Date()
    }

    // MARK: - Write to Pasteboard

    /// Write this slot's contents to the given pasteboard.
    ///
    /// Builds fresh `NSPasteboardItem`s on every call — an item instance can
    /// only ever belong to one pasteboard, so this is what makes repeated
    /// pastes from the same slot work.
    func write(to pasteboard: NSPasteboard) {
        guard let storedItems else { return }
        pasteboard.clearContents()

        let freshItems = storedItems.map { typedData -> NSPasteboardItem in
            let item = NSPasteboardItem()
            for (type, data) in typedData {
                item.setData(data, forType: type)
            }
            return item
        }
        pasteboard.writeObjects(freshItems)
    }

    // MARK: - Clear

    /// Clear the slot content.
    func clear() {
        storedItems = nil
        contentType = nil
        textContent = nil
        imageContent = nil
        fileURLs = nil
        timestamp = nil
    }

    /// Overwrite the slot's stored bytes with zeros before releasing them.
    /// Called on normal app termination to reduce residual sensitive data in RAM.
    ///
    /// `resetBytes(in:)` mutates in place when this slot holds the only
    /// reference to the buffer (copy-on-write), which is the case here: the
    /// data was deep-copied out of the pasteboard at store time and never
    /// escapes except as fresh copies handed to `write(to:)`.
    ///
    /// Honest limitations: the cached `textContent` string and `imageContent`
    /// bitmap cannot be zeroed (immutable, and `NSImage` owns its storage), and
    /// copies AppKit made internally are out of reach. This narrows the window;
    /// it is not a guarantee.
    func secureWipe() {
        // Take sole ownership before mutating. `resetBytes` only works in place
        // when the buffer is uniquely referenced; if `storedItems` still held a
        // second reference, copy-on-write would zero a fresh copy and release
        // the original bytes untouched.
        if var items = storedItems {
            storedItems = nil
            for itemIndex in items.indices {
                // Snapshot the keys so no borrowed copy of the dictionary is
                // alive while its values are mutated.
                let keys = Array(items[itemIndex].keys)
                for key in keys {
                    if let count = items[itemIndex][key]?.count, count > 0 {
                        items[itemIndex][key]?.resetBytes(in: 0..<count)
                    }
                }
            }
        }
        clear()
    }

    // MARK: - Private

    private func detectContentType(from pasteboard: NSPasteboard) {
        // Priority: fileURL > image > RTF > text
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self],
                                              options: [.urlReadingFileURLsOnly: true]) as? [URL],
           !urls.isEmpty {
            contentType = .fileURL
            fileURLs = urls
            textContent = urls.map(\.lastPathComponent).joined(separator: ", ")
            imageContent = nil
            return
        }

        if let image = NSImage(pasteboard: pasteboard) {
            contentType = .image
            imageContent = image
            textContent = nil
            fileURLs = nil
            return
        }

        if let rtfData = pasteboard.data(forType: .rtf),
           let attrStr = NSAttributedString(rtf: rtfData, documentAttributes: nil) {
            contentType = .rtf
            textContent = attrStr.string
            imageContent = nil
            fileURLs = nil
            return
        }

        if let text = pasteboard.string(forType: .string) {
            contentType = .text
            textContent = text
            imageContent = nil
            fileURLs = nil
            return
        }

        contentType = nil
    }
}
