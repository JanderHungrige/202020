# 20-20-20 Rule macOS App

A macOS menu bar application that helps you follow the 20-20-20 rule: every 20 minutes, look at something 20 yards away for 20 seconds.

## Features

- **Break Reminders**: Automatically dims your screen and shows a reminder every 20 minutes (configurable)
- **Menu Bar Integration**: Easy access from the macOS menu bar (top bar near Apple logo)
- **Customizable Settings**: Adjust break intervals, durations, and more
- **Posture Reminder**: Optional reminder that shows a posture icon periodically (every 1 minute for 1 second by default)
- **Skip Functionality**: Skip breaks when needed
- **Multi-Screen Support**: Works across all connected displays
- **Modular Architecture**: Easy to extend, modify, or remove features

## Architecture

The app is built with a modular architecture for easy maintenance. Each component is independent and can be modified without affecting others:

- **SettingsManager**: Manages all app settings with UserDefaults persistence
- **TimerManager**: Handles the break timer logic with Combine for reactive updates
- **ScreenOverlayManager**: Manages screen dimming and break reminders across all screens
- **PostureReminderManager**: Handles posture reminder functionality independently
- **MenuBarManager**: Manages menu bar icon and menu interactions
- **SettingsView**: SwiftUI view for configuring app settings

## Building and Running

### Quick Start: Create .app Bundle

The easiest way to create a standalone app:

```bash
./create-app.sh
```

This will:
1. Build the app in release mode
2. Create a `TwentyTwentyTwenty.app` bundle
3. Make it ready to double-click and run (no terminal needed!)

You can then:
- Double-click `TwentyTwentyTwenty.app` to run it
- Drag it to `/Applications` to install it permanently

### Create DMG for Distribution

To create a DMG installer file:

```bash
./create-dmg.sh
```

This creates `TwentyTwentyTwenty.dmg` that users can:
1. Double-click to mount
2. Drag the app to Applications
3. Eject when done

### Option 1: Using Swift Package Manager (Development)

For development/testing:

1. Build the project:
```bash
swift build -c release
```

2. Run the app:
```bash
swift run -c release
```

Or use the build script:
```bash
./build.sh
```

**Note**: This requires the terminal to stay open. Use `create-app.sh` for a standalone app.

### Option 2: Using Xcode

1. Open the project in Xcode:
```bash
open Package.swift
```

2. Select the `TwentyTwentyTwenty` scheme
3. Build and run (⌘R)

## Installation

After building, the app runs as a menu bar accessory (no dock icon). It will appear in your menu bar with an eye icon.

**Note**: On first run, macOS may ask for Screen Recording permissions to display overlays. Grant this permission in System Settings > Privacy & Security > Screen Recording.

## Usage

1. **Menu Bar Icon**: Look for the eye icon (👁️) in your menu bar (top right, near the Apple logo)
2. **Toggle On/Off**: Click the icon and select "Enable" or "Disable"
3. **Open Settings**: Click the icon and select "Settings..." (or press ⌘,)
4. **During Breaks**: 
   - The screen will dim and show a countdown
   - Click "Skip" to skip the current break
   - The break automatically ends after the configured duration

## Settings

Configure the app through the Settings window:

- **Break Interval**: How often to show break reminders (default: 20 minutes)
- **Break Duration**: How long each break lasts (default: 20 seconds)
- **Posture Reminder**: 
  - Enable/disable the posture reminder
  - Set reminder interval (default: 1 minute)
  - Set display duration (default: 1 second)

All changes take effect immediately.

## Requirements

- macOS 13.0 (Ventura) or later
- Swift 5.9 or later
- Xcode 14.0 or later (for building)

## Development

### Adding New Features

The modular architecture makes it easy to add features:

1. Create a new manager class (e.g., `NewFeatureManager`)
2. Add settings to `SettingsManager` if needed
3. Initialize and connect in `AppDelegate`
4. Add UI components if needed

### Modifying Existing Features

Each manager is independent:
- Modify `TimerManager` to change break logic
- Modify `ScreenOverlayManager` to change overlay appearance
- Modify `PostureReminderManager` to change reminder behavior
- Modify `SettingsView` to add/remove settings

### Removing Features

Simply:
1. Remove the manager initialization from `AppDelegate`
2. Remove related settings from `SettingsManager` (optional)
3. Remove UI components (if any)

## License

This project is provided as-is for personal use.
