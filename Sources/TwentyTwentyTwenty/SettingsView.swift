import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = SettingsManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("20-20-20 Rule Settings")
                    .font(.system(size: 24, weight: .bold))
                
                Text("Take a break every 20 minutes, look 20 yards away for 20 seconds")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            Divider()
            
            // Main settings
            Form {
                Section("Break Timer") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Break Interval:")
                            Spacer()
                            TimeIntervalPicker(
                                title: "Interval",
                                value: $settings.breakInterval,
                                range: 1...120,
                                unit: .minutes
                            )
                        }
                        
                        HStack {
                            Text("Break Duration:")
                            Spacer()
                            TimeIntervalPicker(
                                title: "Duration",
                                value: $settings.breakDuration,
                                range: 5...60,
                                unit: .seconds
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Posture Reminder") {
                    Toggle("Enable Posture Reminder", isOn: $settings.postureReminderEnabled)
                    
                    if settings.postureReminderEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Reminder Interval:")
                                Spacer()
                                TimeIntervalPicker(
                                    title: "Interval",
                                    value: $settings.postureReminderInterval,
                                    range: 30...300,
                                    unit: .seconds
                                )
                            }
                            
                            HStack {
                                Text("Display Duration:")
                                Spacer()
                                TimeIntervalPicker(
                                    title: "Duration",
                                    value: $settings.postureReminderDuration,
                                    range: 0.5...5.0,
                                    unit: .seconds,
                                    step: 0.5
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .formStyle(.grouped)
            
            Spacer()
            
            // Footer info
            HStack {
                Spacer()
                Text("Changes take effect immediately")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.bottom, 10)
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
    }
}

struct TimeIntervalPicker: View {
    let title: String
    @Binding var value: TimeInterval
    let range: ClosedRange<Double>
    let unit: TimeUnit
    let step: Double
    
    enum TimeUnit {
        case minutes
        case seconds
        
        var label: String {
            switch self {
            case .minutes: return "min"
            case .seconds: return "sec"
            }
        }
    }
    
    init(title: String, value: Binding<TimeInterval>, range: ClosedRange<Double>, unit: TimeUnit, step: Double = 1.0) {
        self.title = title
        self._value = value
        self.range = range
        self.unit = unit
        self.step = step
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Stepper(value: $value, in: range, step: step) {
                TextField("", value: $value, format: .number.precision(.fractionLength(step < 1 ? 1 : 0)))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
                    .onChange(of: value) { newValue in
                        // Clamp to range and round to step
                        let rounded = round(newValue / step) * step
                        let clamped = min(max(rounded, range.lowerBound), range.upperBound)
                        if clamped != value {
                            value = clamped
                        }
                    }
            }
            
            Text(unit.label)
                .foregroundColor(.secondary)
                .frame(width: 35, alignment: .leading)
        }
    }
}
