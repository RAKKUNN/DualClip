import Foundation

/// Identifies the three clipboard slots available in DualClip.
enum SlotIdentifier: String, CaseIterable, Identifiable {
    case A
    case B
    case C

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .A: return "Slot A (System)"
        case .B: return "Slot B"
        case .C: return "Slot C"
        }
    }

    var shortLabel: String {
        switch self {
        case .A: return "A"
        case .B: return "B"
        case .C: return "C"
        }
    }
}
