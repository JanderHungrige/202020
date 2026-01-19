import AppKit
import SwiftUI
import Combine

/// Manages the menu bar icon and menu
class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var settingsWindow: NSWindow?
    private var settingsManager: SettingsManager
    private var timerManager: TimerManager
    private var cancellables = Set<AnyCancellable>()
    
    init(settingsManager: SettingsManager = .shared, timerManager: TimerManager) {
        self.settingsManager = settingsManager
        self.timerManager = timerManager
        setupMenuBar()
        observeSettings()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateMenu()
        updateButtonIcon()
    }
    
    private func observeSettings() {
        settingsManager.$isEnabled
            .sink { [weak self] _ in
                self?.updateMenu()
                self?.updateButtonIcon()
            }
            .store(in: &cancellables)
    }
    
    private func updateMenu() {
        guard let statusItem = statusItem else { return }
        
        let menu = NSMenu()
        
        // Toggle item
        let toggleItem = NSMenuItem(
            title: settingsManager.isEnabled ? "Disable" : "Enable",
            action: #selector(toggleEnabled),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Settings item
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(showSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit item
        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quitApplication),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    private func updateButtonIcon() {
        guard let button = statusItem?.button else { return }
        
        if settingsManager.isEnabled {
            button.image = NSImage(systemSymbolName: "eye.fill", accessibilityDescription: "20-20-20 Rule (Enabled)")
        } else {
            button.image = NSImage(systemSymbolName: "eye.slash", accessibilityDescription: "20-20-20 Rule (Disabled)")
        }
        button.image?.isTemplate = true
    }
    
    @objc private func toggleEnabled() {
        settingsManager.isEnabled.toggle()
        updateMenu()
    }
    
    @objc private func showSettings() {
        if settingsWindow == nil {
            let window = createSettingsWindow()
            settingsWindow = window
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quitApplication() {
        NSApplication.shared.terminate(nil)
    }
    
    private func createSettingsWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "20-20-20 Rule Settings"
        window.center()
        window.setFrameAutosaveName("SettingsWindow")
        window.isReleasedWhenClosed = false
        
        // Set delegate to handle window closing
        window.delegate = SettingsWindowDelegate { [weak self] in
            self?.settingsWindow = nil
        }
        
        let contentView = NSHostingView(rootView: SettingsView())
        window.contentView = contentView
        
        return window
    }
}

// Helper class to handle window closing
class SettingsWindowDelegate: NSObject, NSWindowDelegate {
    let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}
