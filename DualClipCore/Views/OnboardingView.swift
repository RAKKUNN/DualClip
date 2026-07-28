import SwiftUI

/// First-run onboarding view guiding the user through permission setup.
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject var clipboardManager: ClipboardManager
    @ObservedObject private var accessibilityService = AccessibilityService.shared

    @State private var currentStep = 0

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)

                Text("Welcome to DualClip")
                    .font(.system(size: 16, weight: .semibold))

                Text("A few quick steps to get started")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()

            // Step content
            VStack(spacing: 12) {
                if currentStep == 0 {
                    permissionStep
                } else {
                    readyStep
                }
            }
            .padding(16)

            Divider()

            // Navigation
            HStack {
                if currentStep > 0 {
                    Button("Back") {
                        currentStep -= 1
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }

                Spacer()

                if currentStep == 0 {
                    Button("Next") {
                        currentStep = 1
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                } else {
                    Button("Get Started") {
                        hasCompletedOnboarding = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(width: 300)
    }

    // MARK: - Steps

    private var permissionStep: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text("Accessibility Permission")
                    .font(.system(size: 13, weight: .medium))
            } icon: {
                Image(systemName: "hand.raised.fill")
                    .foregroundColor(.orange)
            }

            Text("DualClip needs Accessibility access to simulate paste keystrokes (⌘V) when using Slot B/C.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Circle()
                    .fill(accessibilityService.isGranted ? Color.green : Color.red)
                    .frame(width: 8, height: 8)

                Text(accessibilityService.isGranted ? "Permission Granted" : "Not Granted")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(accessibilityService.isGranted ? .green : .red)

                Spacer()

                if !accessibilityService.isGranted {
                    Button("Grant Access") {
                        AccessibilityService.shared.requestAccessibility()
                        // Start polling for permission change
                        AccessibilityService.shared.startPermissionPolling { granted in
                            // Published property will auto-update the UI
                        }
                    }
                    .controlSize(.small)
                }
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.1)))

            Text("Your data never leaves this device. DualClip has zero network access.")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .italic()
        }
    }

    private var readyStep: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text("You're All Set!")
                    .font(.system(size: 13, weight: .medium))
            } icon: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }

            VStack(alignment: .leading, spacing: 6) {
                shortcutRow(label: "Slot A", desc: "System clipboard", keys: "⌘C / ⌘V")
                shortcutRow(label: "Slot B", desc: "Secondary slot", keys: "⌥⌘C / ⌥⌘V")
                shortcutRow(label: "Slot C", desc: "Tertiary slot", keys: "⌃⌘C / ⌃⌘V")
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.1)))

            Text("Shortcuts are customizable in Settings.")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }

    private func shortcutRow(label: String, desc: String, keys: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .frame(width: 44, alignment: .leading)
            Text(desc)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Spacer()
            Text(keys)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}
