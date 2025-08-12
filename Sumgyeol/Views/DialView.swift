import SwiftUI

// MARK: - Dial View (1–10분 스냅)
struct DialView: View {
    @Binding var minutes: Int
    let isEnabled: Bool
    let ringColor: Color

    @State private var angle: Angle = .zero
    private let minMin = 1, maxMin = 10
    
    // 초기 각도를 현재 시간에 맞게 설정
    init(minutes: Binding<Int>, isEnabled: Bool, ringColor: Color) {
        self._minutes = minutes
        self.isEnabled = isEnabled
        self.ringColor = ringColor
        self._angle = State(initialValue: .degrees(mapMinutesToAngle(minutes.wrappedValue)))
    }

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(.white.opacity(0.08), lineWidth: 18)

            Circle()
                .trim(from: 0, to: progress(for: minutes))
                .stroke(style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .fill(ringColor)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.2), value: minutes)

            VStack(spacing: 6) {
                Text("명상 시간")
                    .font(.caption)
                    .foregroundStyle(Theme.subtleText)
                Text("\(minutes)분")
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
        }
        .rotationEffect(angle)
        .gesture(isEnabled ? dragGesture : nil)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("명상 시간")
        .accessibilityValue("\(minutes)분")
        .accessibilityAdjustableAction { direction in
            guard isEnabled else { return }
            switch direction {
            case .increment: updateMinutes(to: min(maxMin, minutes + 1))
            case .decrement: updateMinutes(to: max(minMin, minutes - 1))
            default: break
            }
        }
//        .overlay(alignment: .bottom) {
//            // 작은 인디케이터 점
//            Circle().fill(.white.opacity(0.75))
//                .frame(width: 6, height: 6)
//                .offset(y: 14)
//                .opacity(isEnabled ? 1 : 0.2)
//        }
    }
 
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                updateAngle(for: value.location)
            }
            .onEnded { value in
                updateAngle(for: value.location) // 마지막 위치 업데이트
                // 제스처가 끝나면 현재 분에 맞는 각도로 부드럽게 이동
                let targetAngle = mapMinutesToAngle(minutes)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    angle = .degrees(targetAngle)
                }
            }
    }
    
    private func updateAngle(for location: CGPoint) {
        let center = CGPoint(x: 140, y: 140) // frame(width: 280, height: 280)의 중심
        let vector = CGVector(dx: location.x - center.x, dy: location.y - center.y)
        let radians = atan2(vector.dy, vector.dx)
        
        // 위쪽을 0도로 맞추기 위해 90도(π/2)를 더함
        let adjustedRadians = radians + .pi / 2
        
        // 0-360도 범위로 변환
        let degrees = (adjustedRadians * 180 / .pi).truncatingRemainder(dividingBy: 360)
        let positiveDegrees = degrees < 0 ? degrees + 360 : degrees
        
        // 360도 전체를 사용하지 않고, 300도 정도만 사용해 1-10분으로 매핑
        let totalDegreesToMap: CGFloat = 300
        let progress = min(1, max(0, positiveDegrees / totalDegreesToMap))
        
        let newMinutes = Int(round(Double(minMin) + progress * Double(maxMin - minMin)))
        
        if minutes != newMinutes {
            updateMinutes(to: newMinutes)
        }
        
        // 시각적으로 다이얼이 회전하도록 angle 상태를 업데이트
        angle = .radians(adjustedRadians)
    }

    private func updateMinutes(to newVal: Int) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        minutes = newVal
    }

    private func mapMinutesToAngle(_ m: Int) -> Double {
        let progress = Double(m - minMin) / Double(maxMin - minMin)
        let totalDegreesToMap = 300.0
        // 0-300도 범위를 반환 (회전 효과를 위해)
        return progress * totalDegreesToMap
    }
    
    private func progress(for m: Int) -> CGFloat {
        // 1-10분을 0.0-1.0 범위로 변환
        guard maxMin > minMin else { return 0 }
        return CGFloat(Double(m - minMin) / Double(maxMin - minMin))
    }
}
