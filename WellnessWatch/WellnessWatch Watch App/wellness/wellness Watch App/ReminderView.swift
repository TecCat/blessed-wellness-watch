// ReminderView.swift — Daily reminder settings screen
import SwiftUI

struct ReminderView: View {

    @State private var enabled: Bool = false
    @State private var hour: Int     = 20
    @State private var minute: Int   = 0

    private let minuteOptions = [0, 15, 30, 45]

    var body: some View {
        List {
            // MARK: Toggle row
            Section {
                Toggle(L.dailyReminder, isOn: $enabled)
                    .onChange(of: enabled) { _, newValue in
                        handleToggle(newValue)
                    }
            }

            // MARK: Time picker rows (only when enabled)
            if enabled {
                Section(L.reminderTime) {
                    // Hour
                    Picker(L.hourLabel, selection: $hour) {
                        ForEach(0..<24, id: \.self) { h in
                            Text(String(format: "%02d 時", h)).tag(h)
                        }
                    }
                    .onChange(of: hour) { _, _ in reschedule() }

                    // Minute
                    Picker(L.minuteLabel, selection: $minute) {
                        ForEach(minuteOptions, id: \.self) { m in
                            Text(String(format: "%02d 分", m)).tag(m)
                        }
                    }
                    .onChange(of: minute) { _, _ in reschedule() }
                }
            }

            // MARK: Status row
            Section {
                Text(statusText)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(L.navTitleReminder)
        .task { await loadState() }
    }

    // MARK: - Helpers

    private var statusText: String {
        guard enabled else { return L.reminderOff }
        #if targetEnvironment(simulator)
        return String(format: L.reminderSet, hour, minute) + "\n" + L.reminderSimNote
        #else
        return String(format: L.reminderSet, hour, minute)
        #endif
    }

    private func handleToggle(_ on: Bool) {
        if on {
            Task {
                let granted = await NotificationService.shared.requestAuthorization()
                if granted {
                    NotificationService.shared.scheduleDailyReminder(hour: hour, minute: minute)
                } else {
                    await MainActor.run { enabled = false }
                    AppLogger.error("Notification permission denied", category: "notification")
                }
            }
        } else {
            NotificationService.shared.cancelDailyReminder()
        }
    }

    private func reschedule() {
        guard enabled else { return }
        NotificationService.shared.scheduleDailyReminder(hour: hour, minute: minute)
    }

    private func loadState() async {
        if let time = await NotificationService.shared.scheduledTime() {
            hour    = time.hour
            minute  = minuteOptions.contains(time.minute) ? time.minute : 0
            enabled = true
        } else {
            enabled = false
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ReminderView()
    }
    .environmentObject(AppNav())
}
