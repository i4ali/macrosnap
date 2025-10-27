//
//  NotificationManager.swift
//  MacroSnap
//
//  Manages local notifications for streak-based reminders
//

import Foundation
import UserNotifications
import CoreData
import Combine

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let calendar = Calendar.current

    // UserDefaults keys
    private let streakRemindersEnabledKey = "streakRemindersEnabled"
    private let streakReminderTimeKey = "streakReminderTime"
    private let lastNotificationDateKey = "lastNotificationDate"
    private let hasRequestedPermissionKey = "hasRequestedNotificationPermission"

    // Notification identifier
    private let streakNotificationIdentifier = "com.macrosnap.streakReminder"

    // MARK: - Published Properties

    @Published var isAuthorized: Bool = false
    @Published var streakRemindersEnabled: Bool {
        didSet {
            UserDefaults.standard.set(streakRemindersEnabled, forKey: streakRemindersEnabledKey)
            if streakRemindersEnabled {
                Task { await scheduleNotificationIfNeeded() }
            } else {
                cancelAllNotifications()
            }
        }
    }

    @Published var reminderTime: Date {
        didSet {
            UserDefaults.standard.set(reminderTime, forKey: streakReminderTimeKey)
            if streakRemindersEnabled {
                Task { await scheduleNotificationIfNeeded() }
            }
        }
    }

    // MARK: - Initialization

    private init() {
        // Load settings from UserDefaults
        self.streakRemindersEnabled = UserDefaults.standard.bool(forKey: streakRemindersEnabledKey)

        // Load reminder time or set default to 8:00 PM
        if let savedTime = UserDefaults.standard.object(forKey: streakReminderTimeKey) as? Date {
            self.reminderTime = savedTime
        } else {
            var components = DateComponents()
            components.hour = 20 // 8:00 PM
            components.minute = 0
            self.reminderTime = calendar.date(from: components) ?? Date()
        }

        // Check authorization status
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        await MainActor.run {
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])

            await MainActor.run {
                isAuthorized = granted
                UserDefaults.standard.set(true, forKey: hasRequestedPermissionKey)
            }

            if granted && streakRemindersEnabled {
                await scheduleNotificationIfNeeded()
            }

            return granted
        } catch {
            print("❌ Failed to request notification authorization: \(error)")
            return false
        }
    }

    var hasRequestedPermission: Bool {
        UserDefaults.standard.bool(forKey: hasRequestedPermissionKey)
    }

    // MARK: - Notification Scheduling

    func scheduleNotificationIfNeeded() async {
        guard streakRemindersEnabled, isAuthorized else {
            print("⏭️ Skipping notification schedule - not enabled or not authorized")
            return
        }

        // Check if user has already logged today
        if hasLoggedToday() {
            print("✅ User already logged today - canceling notification")
            cancelAllNotifications()
            return
        }

        // Get current streak
        let streak = getCurrentStreak()

        // Schedule notification
        await scheduleStreakReminder(streak: streak)
    }

    private func scheduleStreakReminder(streak: Int) async {
        // Cancel any existing notifications
        cancelAllNotifications()

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "MacroSnap"
        content.body = getNotificationMessage(for: streak)
        content.sound = .default
        content.badge = 1

        // Create trigger for the specified time
        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: false)

        // Create request
        let request = UNNotificationRequest(
            identifier: streakNotificationIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
            print("✅ Scheduled streak reminder for \(timeComponents.hour ?? 0):\(timeComponents.minute ?? 0) - Streak: \(streak)")

            // Save last notification date
            UserDefaults.standard.set(Date(), forKey: lastNotificationDateKey)
        } catch {
            print("❌ Failed to schedule notification: \(error)")
        }
    }

    // MARK: - Notification Messages

    private func getNotificationMessage(for streak: Int) -> String {
        switch streak {
        case 0:
            return "Get back on track - log one meal today"
        case 1...6:
            return "Keep your \(streak)-day streak going! 🔥 Log today's macros"
        case 7...29:
            return "\(streak)-day streak! Don't break it now 💪"
        default: // 30+
            return "Amazing! \(streak)-day streak! Keep crushing it 🔥"
        }
    }

    // MARK: - Cancel Notifications

    func cancelAllNotifications() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [streakNotificationIdentifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [streakNotificationIdentifier])
        print("🗑️ Canceled all streak notifications")
    }

    // MARK: - Badge Management

    /// Clear app badge when user opens the app
    func clearBadge() {
        Task {
            try? await notificationCenter.setBadgeCount(0)
        }
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [streakNotificationIdentifier])
        print("🔔 Cleared app badge and delivered notifications")
    }

    // MARK: - Helper Methods

    private func hasLoggedToday() -> Bool {
        let context = PersistenceController.shared.container.viewContext
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let fetchRequest: NSFetchRequest<MacroEntryEntity> = MacroEntryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", today as NSDate, tomorrow as NSDate)
        fetchRequest.fetchLimit = 1

        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("❌ Failed to check if user logged today: \(error)")
            return false
        }
    }

    private func getCurrentStreak() -> Int {
        let context = PersistenceController.shared.container.viewContext

        // Fetch all entries sorted by date descending
        let fetchRequest: NSFetchRequest<MacroEntryEntity> = MacroEntryEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            let entries = try context.fetch(fetchRequest)
            guard !entries.isEmpty else { return 0 }

            // Group entries by day
            var daysWithEntries = Set<Date>()
            for entry in entries {
                if let date = entry.date {
                    daysWithEntries.insert(calendar.startOfDay(for: date))
                }
            }

            // Calculate streak - start from yesterday if no entries today (give benefit of the doubt)
            let today = calendar.startOfDay(for: Date())
            let hasLoggedToday = daysWithEntries.contains(today)

            // Start counting from today if logged, otherwise from yesterday
            var currentDate = hasLoggedToday ? today : calendar.date(byAdding: .day, value: -1, to: today)!
            var streak = 0

            while daysWithEntries.contains(currentDate) {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
            }

            return streak
        } catch {
            print("❌ Failed to calculate streak: \(error)")
            return 0
        }
    }

    // MARK: - Public Update Method

    /// Call this when user logs an entry to update notification state
    func updateNotificationAfterEntry() async {
        await scheduleNotificationIfNeeded()
    }

    /// Call this when app becomes active to refresh notification state
    func refreshNotificationState() async {
        // Clear badge and delivered notifications when app opens
        clearBadge()

        // Check authorization and reschedule if needed
        await checkAuthorizationStatus()
        await scheduleNotificationIfNeeded()
    }
}
