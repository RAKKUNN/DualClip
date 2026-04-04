import SwiftUI

/// Holds all app-level state: clipboard manager and shortcut handler.
final class AppState: ObservableObject {
    static weak var current: AppState?

    let clipboardManager = ClipboardManager()
    private(set) var shortcutHandler: ShortcutHandler!

    init() {
        shortcutHandler = ShortcutHandler(clipboardManager: clipboardManager)
        AppState.current = self
    }
}

@main
struct DualClipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        MenuBarExtra {
            if hasCompletedOnboarding {
                MenuBarView()
                    .environmentObject(appState.clipboardManager)
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .environmentObject(appState.clipboardManager)
            }
        } label: {
            Image(systemName: "doc.on.clipboard")
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(appState.clipboardManager)
        }
    }
}
