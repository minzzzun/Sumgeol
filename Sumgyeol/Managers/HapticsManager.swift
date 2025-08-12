import CoreHaptics
import UIKit

// MARK: - Haptics
struct HapticsManager {
    private var engine: CHHapticEngine?
    
    mutating func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        engine = try? CHHapticEngine()
        try? engine?.start()
    }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
