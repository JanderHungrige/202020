import AppKit
import SwiftUI

/// Manages the screen overlay for break reminders
class ScreenOverlayManager: ObservableObject {
    static let shared = ScreenOverlayManager()
    
    private var windows: [NSWindow] = []
    private var settingsManager: SettingsManager
    private var timer: Timer?
    
    @Published var isShowing = false
    
    private init(settingsManager: SettingsManager = .shared) {
        self.settingsManager = settingsManager
    }
    
    func showBreakReminder(onSkip: @escaping () -> Void) {
        guard !isShowing else { return }
        
        isShowing = true
        
        // Get all screens
        let screens = NSScreen.screens
        
        for screen in screens {
            let window = createOverlayWindow(for: screen, onSkip: onSkip)
            windows.append(window)
            window.makeKeyAndOrderFront(nil)
            window.level = .screenSaver
        }
        
        // Auto-dismiss after break duration
        timer = Timer.scheduledTimer(withTimeInterval: settingsManager.breakDuration, repeats: false) { [weak self] _ in
            self?.dismiss()
        }
    }
    
    func dismiss() {
        timer?.invalidate()
        timer = nil
        
        for window in windows {
            window.close()
        }
        windows.removeAll()
        isShowing = false
    }
    
    private func createOverlayWindow(for screen: NSScreen, onSkip: @escaping () -> Void) -> NSWindow {
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame
        
        let window = NSWindow(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.backgroundColor = NSColor.black.withAlphaComponent(0.7)
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        let contentView = NSHostingView(
            rootView: BreakReminderView(
                duration: settingsManager.breakDuration,
                onSkip: {
                    onSkip()
                    self.dismiss()
                }
            )
        )
        
        window.contentView = contentView
        window.setFrame(screenFrame, display: true)
        
        return window
    }
}

struct BreakReminderView: View {
    let duration: TimeInterval
    let onSkip: () -> Void
    
    @State private var timeRemaining: TimeInterval
    
    init(duration: TimeInterval, onSkip: @escaping () -> Void) {
        self.duration = duration
        self.onSkip = onSkip
        self._timeRemaining = State(initialValue: duration)
    }
    
    var body: some View {
        ZStack {
            Color.clear
            
            VStack(spacing: 30) {
                Text("20-20-20 Rule")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Look away for 20 seconds")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.9))
                
                Text("Look at something 20 yards away")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(Int(timeRemaining))")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 120, height: 120)
                    )
                
                Button(action: onSkip) {
                    Text("Skip")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            startCountdown()
        }
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
            }
        }
    }
}
