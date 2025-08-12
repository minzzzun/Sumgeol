import SwiftUI

// MARK: - Content
struct ContentView: View {
    @StateObject private var vm = SessionViewModel()
    @State private var haptics = HapticsManager()

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 28) {
                // 제목
                Text(AppConstants.appTitle)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 8)

                // Dial + Breathing Layer
                ZStack {
                    // 호흡 애니메이션: 진행 중일 때만
                    BreathingCircle(isActive: vm.state == .running)
                        .fill(Theme.primary.gradient)
                        .frame(width: 260, height: 260)
                        .opacity(vm.state == .running ? 1 : 0.18)

                    // 다이얼
                    DialView(
                        minutes: $vm.targetMinutes,
                        isEnabled: vm.state == .idle || vm.state == .finished,
                        ringColor: Theme.primary
                    )
                    .frame(width: 280, height: 280)
                    .accessibilityHidden(vm.state == .running)
                }

                // 남은 시간 / 상태
                VStack(spacing: 6) {
                    Text(vm.stateLabel)
                        .font(.headline)
                        .foregroundStyle(Theme.subtleText)

                    Text(vm.formattedRemaining)
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                        .animation(.easeInOut(duration: 0.2), value: vm.remaining)
                }

                // 컨트롤 버튼
                controlButtons
                    .padding(.top, 4)

                // 보조 안내
                Text("다이얼을 돌려 1–10분 설정 • 시작을 누르면 호흡이 시작됩니다")
                    .font(.footnote)
                    .foregroundStyle(Theme.subtleText)
                    .padding(.bottom, 8)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 22)
        }
        .onAppear { haptics.prepare() }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 14) {
            Button {
                switch vm.state {
                case .idle, .finished:
                    vm.start()
                    haptics.impact(.medium)
                case .running:
                    vm.pause()
                    haptics.impact(.light)
                case .paused:
                    vm.resume()
                    haptics.impact(.light)
                }
            } label: {
                Label(vm.primaryButtonTitle, systemImage: vm.primaryButtonIcon)
                    .font(.system(.headline, design: .rounded))
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(FilledCapsule(color: Theme.accent))

            Button(role: .destructive) {
                vm.stop()
                haptics.impact(.rigid)
            } label: {
                Label("종료", systemImage: "xmark.circle")
                    .font(.system(.headline, design: .rounded))
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(OutlineCapsule(color: Theme.primary))
            .disabled(vm.state == .idle)
            .opacity(vm.state == .idle ? 0.4 : 1)
        }
    }
}