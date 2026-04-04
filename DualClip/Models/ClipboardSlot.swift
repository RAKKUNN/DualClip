import AppKit

/// The type of content stored in a clipboard slot.
enum ClipboardContentType {
    case text
    case image
    case fileURL
    case rtf
}

/// Represents a single clipboard slot that can hold text, images, files, or RTF data.
final class ClipboardSlot {
    /// Raw pasteboard items for faithful clipboard restoration.
    private(set) var pasteboardItems: [NSPasteboardItem]?

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
        pasteboardItems == nil
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
        // Deep-copy pasteboard items
        var copiedItems: [NSPasteboardItem] = []
        for item in pasteboard.pasteboardItems ?? [] {
            let copy = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) {
                    copy.setData(data, forType: type)
                }
            }
            copiedItems.append(copy)
        }
        pasteboardItems = copiedItems.isEmpty ? nil : copiedItems
        timestamp = Date()

        // Detect dominant content type and cache
        detectContentType(from: pasteboard)
    }

    /// Store plain text directly (backward-compatible convenience).
    func store(_ text: String) {
        let item = NSPasteboardItem()
        item.setString(text, forType: .string)
        pasteboardItems = [item]
        contentType = .text
        textContent = text
        imageContent = nil
        fileURLs = nil
        timestamp = Date()
    }

    // MARK: - Write to Pasteboard

    /// Write this slot's contents to the given pasteboard.
    func write(to pasteboard: NSPasteboard) {
        guard let items = pasteboardItems else { return }
        pasteboard.clearContents()

        // Re-copy items (NSPasteboardItem can only be on one pasteboard)
        var freshItems: [NSPasteboardItem] = []
        for item in items {
            let copy = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) {
                    copy.setData(data, forType: type)
                }
            }
            freshItems.append(copy)
        }
        pasteboard.writeObjects(freshItems)
    }

    // MARK: - Clear

    /// Clear the slot content.
    func clear() {
        pasteboardItems = nil
        contentType = nil
        textContent = nil
        imageContent = nil
        fileURLs = nil
        timestamp = nil
    }

    /// Securely wipe slot data by overwriting backing memory with zeros before releasing.
    /// Called on app termination to prevent residual sensitive data in RAM.
    func secureWipe() {
        if let items = pasteboardItems {
            for item in items {
                for type in item.types {
                    if let data = item.data(forType: type) {
                        data.withUnsafeBytes { rawBuffer in
                            guard let baseAddress = rawBuffer.baseAddress else { return }
                            let mutable = UnsafeMutableRawPointer(mutating: baseAddress)
                            memset(mutable, 0, rawBuffer.count)
                        }
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
