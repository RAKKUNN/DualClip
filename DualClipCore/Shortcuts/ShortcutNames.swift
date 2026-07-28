import KeyboardShortcuts

/// Define all global keyboard shortcut names used in DualClip.
extension KeyboardShortcuts.Name {
    // Slot B shortcuts
    static let copyB = Self("copyB", default: .init(.c, modifiers: [.option, .command]))
    static let pasteB = Self("pasteB", default: .init(.v, modifiers: [.option, .command]))

    // Slot C shortcuts
    static let copyC = Self("copyC", default: .init(.c, modifiers: [.control, .command]))
    static let pasteC = Self("pasteC", default: .init(.v, modifiers: [.control, .command]))
}
