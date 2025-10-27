//
//  LogMacrosIntent.swift
//  MacroSnap
//
//  Siri Shortcuts for logging macros via voice
//

import AppIntents
import CoreData

// MARK: - Log Macros Intent

struct LogMacrosIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Macros"
    static var description = IntentDescription("Quickly log your protein, carbs, and fat for today.")

    static var openAppWhenRun: Bool = false

    @Parameter(title: "Protein (grams)", description: "Grams of protein")
    var protein: Double

    @Parameter(title: "Carbs (grams)", description: "Grams of carbohydrates")
    var carbs: Double

    @Parameter(title: "Fat (grams)", description: "Grams of fat")
    var fat: Double

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Validate input
        guard protein >= 0 && carbs >= 0 && fat >= 0 else {
            return .result(dialog: "Invalid values. Please enter positive numbers for macros.")
        }

        guard protein > 0 || carbs > 0 || fat > 0 else {
            return .result(dialog: "Please enter at least one macro value.")
        }

        // Run on MainActor to access CoreData
        let result = await MainActor.run {
            // Get persistent container
            let container = PersistenceController.shared.container
            let context = container.viewContext

            // Create new entry
            let newEntry = MacroEntryEntity(context: context)
            newEntry.id = UUID()
            newEntry.date = Date()
            newEntry.protein = protein
            newEntry.carbs = carbs
            newEntry.fat = fat
            newEntry.notes = "Logged via Siri"
            newEntry.createdAt = Date()
            newEntry.updatedAt = Date()

            // Save to CoreData
            do {
                try context.save()
                return true
            } catch {
                return false
            }
        }

        if result {
            // Calculate calories
            let calories = Int((protein * 4) + (carbs * 4) + (fat * 9))

            // Create response message
            let message = formatSuccessMessage(protein: protein, carbs: carbs, fat: fat, calories: calories)

            return .result(dialog: "\(message)")
        } else {
            return .result(dialog: "Failed to log macros. Please try again.")
        }
    }

    private func formatSuccessMessage(protein: Double, carbs: Double, fat: Double, calories: Int) -> String {
        var parts: [String] = []

        if protein > 0 {
            parts.append("\(Int(protein)) grams protein")
        }
        if carbs > 0 {
            parts.append("\(Int(carbs)) grams carbs")
        }
        if fat > 0 {
            parts.append("\(Int(fat)) grams fat")
        }

        let macrosString = parts.joined(separator: ", ")
        return "Logged \(macrosString). That's \(calories) calories. Great job!"
    }
}

// MARK: - Show Macros Today Intent

struct ShowMacrosTodayIntent: AppIntent {
    static var title: LocalizedStringResource = "Show My Macros Today"
    static var description = IntentDescription("Show your macro progress for today.")

    static var openAppWhenRun: Bool = true
    static var isDiscoverable: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Run on MainActor to access CoreData
        let result = await MainActor.run { () -> (Int, Int, Int, Bool) in
            // Get persistent container
            let container = PersistenceController.shared.container
            let context = container.viewContext

            // Fetch today's entries
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            let fetchRequest: NSFetchRequest<MacroEntryEntity> = MacroEntryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "date >= %@ AND date < %@",
                startOfDay as NSDate,
                endOfDay as NSDate
            )

            do {
                let entries = try context.fetch(fetchRequest)

                // Calculate totals
                let totalProtein = entries.reduce(0.0) { $0 + $1.protein }
                let totalCarbs = entries.reduce(0.0) { $0 + $1.carbs }
                let totalFat = entries.reduce(0.0) { $0 + $1.fat }

                return (Int(totalProtein), Int(totalCarbs), Int(totalFat), entries.isEmpty)
            } catch {
                return (0, 0, 0, true)
            }
        }

        let (totalProtein, totalCarbs, totalFat, isEmpty) = result

        if isEmpty {
            return .result(dialog: "You haven't logged any macros today yet. Time to get started!")
        }

        let totalCalories = (totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9)

        let message = "Today you've logged \(totalProtein) grams protein, \(totalCarbs) grams carbs, and \(totalFat) grams fat. That's \(totalCalories) calories total."

        return .result(dialog: "\(message)")
    }
}

// MARK: - App Shortcuts Provider

struct MacroSnapShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogMacrosIntent(),
            phrases: [
                "Log macros in \(.applicationName)",
                "Log my macros in \(.applicationName)",
                "Track macros in \(.applicationName)",
                "Track my macros in \(.applicationName)",
                "Add macros to \(.applicationName)",
                "Record macros in \(.applicationName)"
            ],
            shortTitle: "Log Macros",
            systemImageName: "plus.circle.fill"
        )

        AppShortcut(
            intent: ShowMacrosTodayIntent(),
            phrases: [
                "Show my macros in \(.applicationName)",
                "Show my macros today in \(.applicationName)",
                "Show macros today in \(.applicationName)",
                "What are my macros in \(.applicationName)",
                "What are my macros today in \(.applicationName)",
                "Check my macros in \(.applicationName)",
                "View my macros in \(.applicationName)",
                "Show my progress in \(.applicationName)",
                "Show my progress today in \(.applicationName)"
            ],
            shortTitle: "Show Macros Today",
            systemImageName: "chart.pie.fill"
        )
    }
}
