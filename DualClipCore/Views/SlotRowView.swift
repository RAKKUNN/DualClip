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
                HStack(spacing: 4) {
                    contentTypeIcon
                    Text(slot.preview())
                        .font(.system(size: 13))
                        .foregroundColor(slot.isEmpty ? .secondary : .primary)
                        .lineLimit(1)
                }

                if let timestamp = slot.timestamp {
                    Text(timestamp, style: .relative)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Image thumbnail (for image content)
            if slot.contentType == .image, let nsImage = slot.imageContent {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

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

    @ViewBuilder
    private var contentTypeIcon: some View {
        switch slot.contentType {
        case .image:
            Image(systemName: "photo")
                .font(.system(size: 10))
                .foregroundColor(.green)
        case .fileURL:
            Image(systemName: "doc")
                .font(.system(size: 10))
                .foregroundColor(.blue)
        case .rtf:
            Image(systemName: "text.badge.star")
                .font(.system(size: 10))
                .foregroundColor(.purple)
        case .text:
            EmptyView()
        case .none:
            EmptyView()
        }
    }

    private var badgeColor: Color {
        switch identifier {
        case .A: return .blue
        case .B: return .orange
        case .C: return .purple
        }
    }
}
