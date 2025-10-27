//
//  AppState.swift
//  MacroSnap
//
//  Central app state management - coordinates data and theming
//

import Foundation
import SwiftUI
import Combine
import CoreData

@MainActor
class AppState: ObservableObject {
    let themeManager = ThemeManager()
    let cloudKitSync: CloudKitSyncService
    let notificationManager = NotificationManager.shared

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Initialize CloudKit sync service
        let context = PersistenceController.shared.container.viewContext
        self.cloudKitSync = CloudKitSyncService(viewContext: context)

        // Forward changes from child ObservableObjects
        themeManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        cloudKitSync.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        notificationManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Load theme from UserDefaults
        themeManager.loadTheme()

        // Note: CloudKit sync is triggered automatically when CloudKit becomes available
    }

    // MARK: - Data Access

    /// Get current goal from CoreData
    /// Pro users can have custom goals per day of week
    func getCurrentGoal() -> MacroGoal {
        let context = PersistenceController.shared.container.viewContext

        // Get current day of week (0 = Monday, 6 = Sunday)
        let calendar = Calendar.current
        var dayOfWeek = calendar.component(.weekday, from: Date())
        // Convert Sunday (1) to 6, Monday (2) to 0, etc.
        dayOfWeek = (dayOfWeek + 5) % 7

        // Try to find day-specific goal first (Pro feature)
        if let dayGoal = GoalEntity.fetchGoal(for: dayOfWeek, context: context) {
            return dayGoal.toDomain()
        }

        // Fallback to default goal
        if let defaultGoal = GoalEntity.fetchDefaultGoal(context: context) {
            return defaultGoal.toDomain()
        } else {
            return MacroGoal.default
        }
    }

    /// Get today's entries from CoreData
    func getTodayEntries() -> [MacroEntry] {
        let context = PersistenceController.shared.container.viewContext
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let fetchRequest = MacroEntryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", today as NSDate, tomorrow as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MacroEntryEntity.date, ascending: false)]

        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { $0.toDomain() }
        } catch {
            print("Failed to fetch today's entries: \(error)")
            return []
        }
    }

    /// Notify views that goals have changed
    /// Call this after updating goals in CoreData to refresh UI
    func notifyGoalsChanged() {
        objectWillChange.send()
    }
}
