import SwiftUI

// MARK: - Styles
struct FilledCapsule: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1))
            .clipShape(Capsule())
            .shadow(radius: configuration.isPressed ? 2 : 8, y: 2)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct OutlineCapsule: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .overlay(
                Capsule().stroke(color.opacity(0.9), lineWidth: 2)
            )
            .background(
                Capsule().fill(.white.opacity(configuration.isPressed ? 0.06 : 0.02))
            )
            .clipShape(Capsule())
            .shadow(radius: configuration.isPressed ? 0 : 6, y: 2)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
