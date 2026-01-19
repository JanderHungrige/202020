import Foundation
import Combine

/// Manages the 20-20-20 rule timer
class TimerManager: ObservableObject {
    private var timer: Timer?
    private var settingsManager: SettingsManager
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isActive = false
    @Published var timeRemaining: TimeInterval = 0
    
    var onBreakTriggered: (() -> Void)?
    
    init(settingsManager: SettingsManager = .shared) {
        self.settingsManager = settingsManager
        
        // Observe settings changes
        settingsManager.$breakInterval
            .sink { [weak self] _ in
                self?.restartIfActive()
            }
            .store(in: &cancellables)
        
        settingsManager.$isEnabled
            .sink { [weak self] enabled in
                if enabled {
                    self?.start()
                } else {
                    self?.stop()
                }
            }
            .store(in: &cancellables)
    }
    
    func start() {
        guard settingsManager.isEnabled else { return }
        stop()
        
        isActive = true
        timeRemaining = settingsManager.breakInterval
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if !self.settingsManager.isEnabled {
                self.stop()
                return
            }
            
            self.timeRemaining -= 1.0
            
            if self.timeRemaining <= 0 {
                self.triggerBreak()
                self.timeRemaining = self.settingsManager.breakInterval
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isActive = false
        timeRemaining = 0
    }
    
    func skip() {
        // Reset timer to full interval
        timeRemaining = settingsManager.breakInterval
    }
    
    private func triggerBreak() {
        onBreakTriggered?()
    }
    
    private func restartIfActive() {
        if isActive {
            stop()
            start()
        }
    }
    
    deinit {
        stop()
    }
}
