import Foundation
import Combine

/// Manages application settings with persistence
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    private let userDefaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private enum Keys {
        static let breakInterval = "breakInterval"
        static let breakDuration = "breakDuration"
        static let isEnabled = "isEnabled"
        static let postureReminderEnabled = "postureReminderEnabled"
        static let postureReminderInterval = "postureReminderInterval"
        static let postureReminderDuration = "postureReminderDuration"
    }
    
    // Default values
    private let defaultBreakInterval: TimeInterval = 20 * 60 // 20 minutes
    private let defaultBreakDuration: TimeInterval = 20 // 20 seconds
    private let defaultPostureReminderInterval: TimeInterval = 60 // 1 minute
    private let defaultPostureReminderDuration: TimeInterval = 1 // 1 second
    
    @Published var breakInterval: TimeInterval {
        didSet {
            userDefaults.set(breakInterval, forKey: Keys.breakInterval)
        }
    }
    
    @Published var breakDuration: TimeInterval {
        didSet {
            userDefaults.set(breakDuration, forKey: Keys.breakDuration)
        }
    }
    
    @Published var isEnabled: Bool {
        didSet {
            userDefaults.set(isEnabled, forKey: Keys.isEnabled)
        }
    }
    
    @Published var postureReminderEnabled: Bool {
        didSet {
            userDefaults.set(postureReminderEnabled, forKey: Keys.postureReminderEnabled)
        }
    }
    
    @Published var postureReminderInterval: TimeInterval {
        didSet {
            userDefaults.set(postureReminderInterval, forKey: Keys.postureReminderInterval)
        }
    }
    
    @Published var postureReminderDuration: TimeInterval {
        didSet {
            userDefaults.set(postureReminderDuration, forKey: Keys.postureReminderDuration)
        }
    }
    
    private init() {
        // Load from UserDefaults or use defaults
        self.breakInterval = userDefaults.object(forKey: Keys.breakInterval) as? TimeInterval ?? defaultBreakInterval
        self.breakDuration = userDefaults.object(forKey: Keys.breakDuration) as? TimeInterval ?? defaultBreakDuration
        self.isEnabled = userDefaults.object(forKey: Keys.isEnabled) as? Bool ?? true
        self.postureReminderEnabled = userDefaults.object(forKey: Keys.postureReminderEnabled) as? Bool ?? false
        self.postureReminderInterval = userDefaults.object(forKey: Keys.postureReminderInterval) as? TimeInterval ?? defaultPostureReminderInterval
        self.postureReminderDuration = userDefaults.object(forKey: Keys.postureReminderDuration) as? TimeInterval ?? defaultPostureReminderDuration
    }
}
