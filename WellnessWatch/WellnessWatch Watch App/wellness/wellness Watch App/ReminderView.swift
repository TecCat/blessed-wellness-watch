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
                Toggle("每日提醒", isOn: $enabled)
                    .onChange(of: enabled) { _, newValue in
                        handleToggle(newValue)
                    }
            }

            // MARK: Time picker rows (only when enabled)
            if enabled {
                Section("提醒時間") {
                    // Hour
                    Picker("小時", selection: $hour) {
                        ForEach(0..<24, id: \.self) { h in
                            Text(String(format: "%02d 時", h)).tag(h)
                        }
                    }
                    .onChange(of: hour) { _, _ in reschedule() }

                    // Minute
                    Picker("分鐘", selection: $minute) {
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
        .navigationTitle("提醒設定")
        .task { await loadState() }
    }

    // MARK: - Helpers

    private var statusText: String {
        guard enabled else { return "未設定提醒" }
        #if targetEnvironment(simulator)
        return "每天 \(String(format: "%02d:%02d", hour, minute)) 提醒練習\n(模擬器不推送通知，實機有效)"
        #else
        return "每天 \(String(format: "%02d:%02d", hour, minute)) 提醒練習"
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
