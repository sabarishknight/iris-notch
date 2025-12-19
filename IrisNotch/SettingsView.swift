//
//  SettingsView.swift
//  IrisNotch
//

import SwiftUI
import ServiceManagement

struct SettingsView: View {

    @ObservedObject private var manager = ReminderManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {

            // MARK: - Pause State
            if manager.isPaused {
                pausedBanner
            }

            // MARK: - Blink Section
            GroupBox(label: Label("Blink Reminder", systemImage: "eye")) {
                VStack(alignment: .leading, spacing: 12) {

                    Toggle("Enable Blink Reminder", isOn: $manager.blinkEnabled)

                    labeledSlider(
                        title: "Interval",
                        valueText: "\(Int(manager.blinkInterval)) sec",
                        value: $manager.blinkInterval,
                        range: 10...120,
                        step: 5
                    )

                    labeledSlider(
                        title: "Visible Duration",
                        valueText: "\(Int(manager.blinkDuration)) sec",
                        value: $manager.blinkDuration,
                        range: 1...5,
                        step: 1
                    )

                    countdownRow(
                        label: "Next blink in:",
                        time: "\(Int(manager.blinkRemaining)) sec",
                        color: .blue
                    )
                }
                .padding(.top, 8)
            }

            // MARK: - Look Away Section
            GroupBox(label: Label("Look-Away Reminder", systemImage: "leaf")) {
                VStack(alignment: .leading, spacing: 12) {

                    Toggle("Enable Look-Away Reminder", isOn: $manager.lookAwayEnabled)

                    labeledSlider(
                        title: "Interval",
                        valueText: "\(Int(manager.lookInterval / 60)) min",
                        value: $manager.lookInterval,
                        range: 5 * 60...60 * 60,
                        step: 5 * 60
                    )

                    labeledSlider(
                        title: "Visible Duration",
                        valueText: "\(Int(manager.lookDuration)) sec",
                        value: $manager.lookDuration,
                        range: 5...30,
                        step: 5
                    )

                    countdownRow(
                        label: "Next look-away in:",
                        time: formatTime(manager.lookRemaining),
                        color: .green
                    )
                }
                .padding(.top, 8)
            }

            // MARK: - Context Rules
            GroupBox(label: Label("When to Show Reminders", systemImage: "gearshape")) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable in fullscreen apps", isOn: $manager.allowInFullscreen)
                    Toggle("Enable during video fullscreen", isOn: $manager.allowInVideoFullscreen)
                    Toggle("Enable during meetings / calls", isOn: $manager.allowDuringMeetings)
                    Toggle("Enable during Do Not Disturb", isOn: $manager.allowDuringDND)
                }
                .padding(.top, 8)
            }

            // MARK: - System
            GroupBox(label: Label("System", systemImage: "power")) {
                Toggle("Launch at Login", isOn: launchAtLoginBinding)
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 360)
    }

    // MARK: - Paused Banner
    private var pausedBanner: some View {
        HStack {
            Image(systemName: "pause.circle.fill")
                .foregroundColor(.orange)

            Text("Reminders Paused")
                .fontWeight(.semibold)

            Spacer()

            Text(formatTime(manager.pauseRemaining))
                .monospacedDigit()
                .foregroundColor(.orange)

            Button("Resume") {
                manager.resume()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .background(Color.orange.opacity(0.12))
        .cornerRadius(10)
    }

    // MARK: - Helpers
    private func labeledSlider(
        title: String,
        valueText: String,
        value: Binding<TimeInterval>,
        range: ClosedRange<TimeInterval>,
        step: TimeInterval
    ) -> some View {
        VStack {
            HStack {
                Text(title)
                Spacer()
                Text(valueText)
                    .foregroundColor(.secondary)
            }
            Slider(value: value, in: range, step: step)
        }
    }

    private func countdownRow(label: String, time: String, color: Color) -> some View {
        HStack {
            Image(systemName: "clock")
            Text(label)
            Spacer()
            Text(time)
                .monospacedDigit()
                .foregroundColor(color)
        }
        .font(.subheadline)
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02dm %02ds", mins, secs)
    }

    // MARK: - Launch at Login Binding
    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { SMAppService.mainApp.status == .enabled },
            set: { enabled in
                do {
                    if enabled {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                } catch {
                    print("Launch at Login error:", error)
                }
            }
        )
    }
}
