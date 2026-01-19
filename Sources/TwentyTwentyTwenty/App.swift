import SwiftUI
import AppKit

@main
struct TwentyTwentyTwentyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarManager: MenuBarManager?
    private var timerManager: TimerManager?
    private var postureReminderManager: PostureReminderManager?
    private var settingsManager = SettingsManager.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Prevent app from terminating when windows close
        // This is crucial for menu bar apps
        NSApp.delegate = self
        
        // Initialize managers
        timerManager = TimerManager(settingsManager: settingsManager)
        postureReminderManager = PostureReminderManager.shared
        menuBarManager = MenuBarManager(
            settingsManager: settingsManager,
            timerManager: timerManager!
        )
        
        // Connect timer to screen overlay
        timerManager?.onBreakTriggered = { [weak self] in
            ScreenOverlayManager.shared.showBreakReminder { [weak self] in
                self?.timerManager?.skip()
            }
        }
        
        // Start services if enabled
        if settingsManager.isEnabled {
            timerManager?.start()
        }
        
        if settingsManager.postureReminderEnabled {
            postureReminderManager?.start()
        }
    }
    
    // Prevent app from terminating when the last window closes
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    // Prevent automatic termination
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Don't reopen windows automatically, but keep the app running
        return false
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        timerManager?.stop()
        postureReminderManager?.stop()
        ScreenOverlayManager.shared.dismiss()
    }
}
