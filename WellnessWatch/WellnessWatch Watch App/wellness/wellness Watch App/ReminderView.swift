// ReminderView.swift — Daily reminder settings screen
import SwiftUI

struct ReminderView: View {

    @AppStorage("reminder.enabled") private var enabled: Bool = false

    @State private var hour: Int   = 20
    @State private var minute: Int = 0

    private let background = Color(red: 0.05, green: 0.05, blue: 0.1)
    private let minutes    = [0, 15, 30, 45]

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {

                    // Toggle
                    Toggle("每日提醒", isOn: $enabled)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 10))
                        .onChange(of: enabled) { _, newValue in
                            handleToggle(newValue)
                        }

                    // Time picker (only when enabled)
                    if enabled {
                        HStack(spacing: 0) {
                            // Hour picker
                            Picker("時", selection: $hour) {
                                ForEach(0..<24, id: \.self) { h in
                                    Text(String(format: "%02d", h)).tag(h)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            .onChange(of: hour) { _, _ in reschedule() }

                            Text(":")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)

                            // Minute picker (0, 15, 30, 45)
                            Picker("分", selection: $minute) {
                                ForEach(minutes, id: \.self) { m in
                                    Text(String(format: "%02d", m)).tag(m)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            .onChange(of: minute) { _, _ in reschedule() }
                        }
                        .frame(height: 80)
                        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 10))
                    }

                    // Status text
                    Text(statusText)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
            }
        }
        .navigationTitle("提醒設定")
        .task { await loadScheduledTime() }
    }

    // MARK: - Helpers

    private var statusText: String {
        if enabled {
            return "已設定 \(String(format: "%02d:%02d", hour, minute)) 提醒"
        } else {
            return "未設定提醒"
        }
    }

    private func handleToggle(_ on: Bool) {
        if on {
            Task {
                let granted = await NotificationService.shared.requestAuthorization()
                if granted {
                    NotificationService.shared.scheduleDailyReminder(hour: hour, minute: minute)
                } else {
                    enabled = false
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
        AppLogger.session("Reminder scheduled: \(hour):\(minute)")
    }

    private func loadScheduledTime() async {
        if let time = await NotificationService.shared.scheduledTime() {
            hour   = time.hour
            minute = minutes.contains(time.minute) ? time.minute : 0
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
