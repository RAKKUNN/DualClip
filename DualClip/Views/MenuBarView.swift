import SwiftUI
import KeyboardShortcuts

/// Main popover view displayed from the menu bar icon.
struct MenuBarView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("DualClip")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Button {
                    clipboardManager.clearAllSlots()
                } label: {
                    Text("Clear All")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Clear slots B and C")
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            // Slot list
            VStack(spacing: 4) {
                SlotRowView(identifier: .A)
                    .help("System clipboard (⌘C / ⌘V)")

                SlotRowView(identifier: .B)
                    .help(shortcutHint(copy: .copyB, paste: .pasteB))

                SlotRowView(identifier: .C)
                    .help(shortcutHint(copy: .copyC, paste: .pasteC))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)

            Divider()

            // Footer
            HStack {
                Button {
                    openSettings()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)

                Spacer()

                // Accessibility status indicator
                Circle()
                    .fill(AccessibilityService.shared.isGranted ? Color.green : Color.red)
                    .frame(width: 6, height: 6)
                    .help(AccessibilityService.shared.isGranted
                          ? "Accessibility: Granted"
                          : "Accessibility: Not Granted — Click to fix")
                    .onTapGesture {
                        if !AccessibilityService.shared.isGranted {
                            AccessibilityService.shared.openAccessibilitySettings()
                        }
                    }

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "power")
                        Text("Quit")
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 280)
    }

    private func openSettings() {
        // Temporarily become a regular app so the Settings window gets proper focus
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        if #available(macOS 14.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }

        // Watch for Settings window close to revert to menu-bar-only mode
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let window = notification.object as? NSWindow,
                  window.title.contains("Settings") || window.title.contains("Preferences") else { return }
            NotificationCenter.default.removeObserver(self, name: NSWindow.willCloseNotification, object: nil)
            // Delay to let the window fully close before switching policy
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }

    private func shortcutHint(copy: KeyboardShortcuts.Name, paste: KeyboardShortcuts.Name) -> String {
        let copyStr = KeyboardShortcuts.getShortcut(for: copy)?.description ?? "Not set"
        let pasteStr = KeyboardShortcuts.getShortcut(for: paste)?.description ?? "Not set"
        return "Copy: \(copyStr) / Paste: \(pasteStr)"
    }
}
