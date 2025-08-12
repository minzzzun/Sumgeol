import SwiftUI

// MARK: - Breathing Circle
struct BreathingCircle: Shape {
    var isActive: Bool

    // 애니메이션용 상태
    private var phase: CGFloat {
        isActive ? 1.0 : 0.0
    }

    func path(in rect: CGRect) -> Path {
        Path(ellipseIn: rect)
    }

    // 스케일 애니메이션을 적용하기 위해 Shape를 View로 감싼 확장
    func fill<S: ShapeStyle>(_ content: S) -> some View {
        Circle()
            .fill(content)
            // 드라마틱한 효과를 위해 수축 시 크기를 0.35로 변경
            .scaleEffect(isActive ? 1.0 : 0.45)
            .shadow(radius: isActive ? 22 : 6)
            .blur(radius: isActive ? 0 : 0.5)
            .animation(
                .easeInOut(duration: 4).repeatForever(autoreverses: true),
                value: phase
            )
    }
}
