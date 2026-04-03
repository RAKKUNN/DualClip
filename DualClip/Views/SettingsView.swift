import SwiftUI
import KeyboardShortcuts

/// Settings view for customizing keyboard shortcuts.
struct SettingsView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager

    var body: some View {
        TabView {
            shortcutsTab
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }

            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 420, height: 320)
    }

    // MARK: - Shortcuts Tab

    private var shortcutsTab: some View {
        Form {
            Section {
                Text("Customize keyboard shortcuts for each clipboard slot.")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }

            Section("Slot B") {
                KeyboardShortcuts.Recorder("Copy to Slot B:", name: .copyB)
                KeyboardShortcuts.Recorder("Paste from Slot B:", name: .pasteB)
            }

            Section("Slot C") {
                KeyboardShortcuts.Recorder("Copy to Slot C:", name: .copyC)
                KeyboardShortcuts.Recorder("Paste from Slot C:", name: .pasteC)
            }

            Section {
                Button("Reset to Defaults") {
                    KeyboardShortcuts.reset([.copyB, .pasteB, .copyC, .pasteC])
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - About Tab

    private var aboutTab: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text("DualClip")
                .font(.title2.bold())

            Text("Multi-Slot Clipboard Manager for macOS")
                .font(.callout)
                .foregroundColor(.secondary)

            Text("v1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)

            Divider()

            VStack(spacing: 4) {
                Text("Open Source — MIT License")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Link("GitHub Repository",
                     destination: URL(string: "https://github.com/dualclip/dualclip")!)
                    .font(.caption)
            }

            Spacer()
        }
        .padding()
    }
}
