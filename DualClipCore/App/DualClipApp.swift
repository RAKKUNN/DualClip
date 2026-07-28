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

/// Entry point for the executable target.
///
/// `@main` cannot be used here: this type lives in a library so that it can be
/// unit tested, and the `main` symbol has to be emitted by the executable
/// target instead (see `DualClip/main.swift`). This is the only symbol the
/// executable needs, so it is also the only `public` one in DualClipCore.
public enum DualClipLauncher {
    public static func run() {
        DualClipApp.main()
    }
}

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
    }
}
