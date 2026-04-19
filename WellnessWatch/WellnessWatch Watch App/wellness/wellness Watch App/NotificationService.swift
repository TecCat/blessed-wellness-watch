// NotificationService.swift — Daily practice reminder scheduling
import UserNotifications
import Foundation

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private let reminderID = "daily-practice-reminder"
    private let hourKey    = "reminder.hour"
    private let minuteKey  = "reminder.minute"

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        // Simulator does not support notifications — always return true so UI works
        #if targetEnvironment(simulator)
        return true
        #else
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            AppLogger.error("Notification auth failed: \(error)", category: "notification")
            return false
        }
        #endif
    }

    // MARK: - Schedule

    func scheduleDailyReminder(hour: Int, minute: Int) {
        cancelDailyReminder()

        let content = UNMutableNotificationContent()
        content.title = "時間練習了 🧘"
        content.body  = "今天還沒練習，花幾分鐘放鬆一下吧"
        content.sound = .default

        var components = DateComponents()
        components.hour   = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: reminderID, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                AppLogger.error("Schedule reminder failed: \(error)", category: "notification")
            }
        }

        UserDefaults.standard.set(hour,   forKey: hourKey)
        UserDefaults.standard.set(minute, forKey: minuteKey)
        AppLogger.session("Reminder scheduled: \(hour):\(minute)")
    }

    // MARK: - Cancel

    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderID])
        UserDefaults.standard.removeObject(forKey: hourKey)
        UserDefaults.standard.removeObject(forKey: minuteKey)
    }

    // MARK: - Query

    func scheduledTime() async -> (hour: Int, minute: Int)? {
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        guard pending.contains(where: { $0.identifier == reminderID }) else { return nil }
        let h = UserDefaults.standard.integer(forKey: hourKey)
        let m = UserDefaults.standard.integer(forKey: minuteKey)
        // integer(forKey:) returns 0 when key absent; treat unset hour 0 as valid only if key exists
        guard UserDefaults.standard.object(forKey: hourKey) != nil else { return nil }
        return (hour: h, minute: m)
    }
}
