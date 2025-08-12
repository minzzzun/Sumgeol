import Foundation
import Combine

// MARK: - Session Manager
final class SessionManager: ObservableObject {
    enum State { case idle, running, paused, finished }

    @Published var state: State = .idle
    @Published var targetMinutes: Int = 5 {
        didSet {
            if state == .idle || state == .finished {
                remaining = TimeInterval(targetMinutes * 60)
            }
        }
    }
    @Published var remaining: TimeInterval

    private var timer: Timer?

    init(initialMinutes: Int = 5) {
        let minutes = TimeInterval(initialMinutes * 60)
        self.remaining = minutes
        self.targetMinutes = initialMinutes
    }

    func start() {
        remaining = TimeInterval(targetMinutes * 60)
        state = .running
        startTimer()
    }

    func pause() {
        state = .paused
        timer?.invalidate()
    }

    func resume() {
        state = .running
        startTimer()
    }

    func stop() {
        timer?.invalidate()
        state = .finished
        // Note: We can reset remaining time here or keep it to show the last session time.
        // Let's reset to the target time for the next session.
        remaining = TimeInterval(targetMinutes * 60)
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            guard self.state == .running else { return }
            
            self.remaining = max(0, self.remaining - 1)
            
            if self.remaining <= 0 {
                self.timer?.invalidate()
                self.state = .finished
                // 완료 시 로컬 알림/사운드 훅 추가 가능
            }
        }
        // UI 업데이트를 부드럽게 하기 위해 RunLoop에 추가
        RunLoop.main.add(timer!, forMode: .common)
    }
}
