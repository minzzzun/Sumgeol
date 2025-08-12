import Foundation
import Combine

// MARK: - ViewModel
final class SessionViewModel: ObservableObject {
    @Published var manager: SessionManager

    private var cancellables = Set<AnyCancellable>()

    init(manager: SessionManager = SessionManager()) {
        self.manager = manager
        
        // Manager의 @Published 프로퍼티를 ViewModel의 @Published 프로퍼티처럼 작동하게 함
        manager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }

    // MARK: - Passthrough Properties
    var state: SessionManager.State { manager.state }
    var remaining: TimeInterval { manager.remaining }
    
    var targetMinutes: Int {
        get { manager.targetMinutes }
        set { manager.targetMinutes = newValue }
    }

    // MARK: - Computed Properties for View
    var formattedRemaining: String {
        let m = Int(remaining) / 60
        let s = Int(remaining) % 60
        return String(format: "%02d:%02d", m, s)
    }

    var stateLabel: String {
        switch state {
        case .idle: return "준비됨"
        case .running: return "진행 중"
        case .paused: return "일시정지"
        case .finished: return "완료"
        }
    }

    var primaryButtonTitle: String {
        switch state {
        case .idle, .finished: return "시작"
        case .running: return "일시정지"
        case .paused: return "재개"
        }
    }

    var primaryButtonIcon: String {
        switch state {
        case .idle, .finished: return "play.fill"
        case .running: return "pause.fill"
        case .paused: return "play.fill"
        }
    }
    
    // MARK: - Intents
    func start() { manager.start() }
    func pause() { manager.pause() }
    func resume() { manager.resume() }
    func stop() { manager.stop() }
}
