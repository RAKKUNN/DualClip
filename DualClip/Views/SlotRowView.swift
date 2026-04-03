import SwiftUI

/// Displays a single clipboard slot row with label, preview, and timestamp.
struct SlotRowView: View {
    let identifier: SlotIdentifier
    @EnvironmentObject var clipboardManager: ClipboardManager

    private var slot: ClipboardSlot {
        clipboardManager.slot(for: identifier)
    }

    var body: some View {
        HStack(spacing: 10) {
            // Slot label badge
            Text(identifier.shortLabel)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(badgeColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            // Content area
            VStack(alignment: .leading, spacing: 2) {
                Text(slot.preview())
                    .font(.system(size: 13))
                    .foregroundColor(slot.isEmpty ? .secondary : .primary)
                    .lineLimit(1)

                if let timestamp = slot.timestamp {
                    Text(timestamp, style: .relative)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Clear button (only for non-empty B/C slots)
            if identifier != .A && !slot.isEmpty {
                Button {
                    clipboardManager.clearSlot(identifier)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Clear \(identifier.displayName)")
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(slot.isEmpty ? Color.clear : Color.accentColor.opacity(0.05))
        )
    }

    private var badgeColor: Color {
        switch identifier {
        case .A: return .blue
        case .B: return .orange
        case .C: return .purple
        }
    }
}
