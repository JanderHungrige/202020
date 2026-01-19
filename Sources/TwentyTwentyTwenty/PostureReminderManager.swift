import AppKit
import SwiftUI
import Combine

/// Manages the posture reminder that shows periodically
class PostureReminderManager: ObservableObject {
    static let shared = PostureReminderManager()
    
    private var timer: Timer?
    private var reminderWindows: [NSWindow] = []
    private var settingsManager: SettingsManager
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isActive = false
    
    private init(settingsManager: SettingsManager = .shared) {
        self.settingsManager = settingsManager
        
        // Observe settings changes
        settingsManager.$postureReminderEnabled
            .sink { [weak self] enabled in
                if enabled {
                    self?.start()
                } else {
                    self?.stop()
                }
            }
            .store(in: &cancellables)
        
        settingsManager.$postureReminderInterval
            .sink { [weak self] _ in
                self?.restartIfActive()
            }
            .store(in: &cancellables)
        
        settingsManager.$postureReminderDuration
            .sink { [weak self] _ in
                // Duration change doesn't require restart, just affects next display
            }
            .store(in: &cancellables)
    }
    
    func start() {
        guard settingsManager.postureReminderEnabled else { return }
        stop()
        
        isActive = true
        
        timer = Timer.scheduledTimer(withTimeInterval: settingsManager.postureReminderInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if !self.settingsManager.postureReminderEnabled {
                self.stop()
                return
            }
            
            self.showReminder()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        dismissReminder()
        isActive = false
    }
    
    private func showReminder() {
        // Dismiss any existing reminders first
        dismissReminder()
        
        let screens = NSScreen.screens
        
        for screen in screens {
            let window = createReminderWindow(for: screen)
            reminderWindows.append(window)
            window.makeKeyAndOrderFront(nil)
            window.level = .floating
        }
        
        // Auto-dismiss after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + settingsManager.postureReminderDuration) { [weak self] in
            self?.dismissReminder()
        }
    }
    
    private func dismissReminder() {
        for window in reminderWindows {
            window.close()
        }
        reminderWindows.removeAll()
    }
    
    private func createReminderWindow(for screen: NSScreen) -> NSWindow {
        let screenFrame = screen.frame
        let centerX = screenFrame.midX
        let centerY = screenFrame.midY
        
        let windowSize: CGFloat = 100
        let windowFrame = NSRect(
            x: centerX - windowSize / 2,
            y: centerY - windowSize / 2,
            width: windowSize,
            height: windowSize
        )
        
        let window = NSWindow(
            contentRect: windowFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        let contentView = NSHostingView(rootView: PostureReminderIcon())
        window.contentView = contentView
        
        return window
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

struct PostureReminderIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.8))
                .frame(width: 80, height: 80)
            
            Image(systemName: "figure.stand")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}
