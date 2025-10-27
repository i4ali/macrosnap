//
//  DemoDataService.swift
//  MacroSnap
//
//  Provides hardcoded demo data for guest mode
//

import Foundation

struct DemoDataService {
    // MARK: - Demo Goals

    static let demoGoal = MacroGoal(
        proteinGoal: 180,
        carbGoal: 250,
        fatGoal: 70
    )

    // MARK: - Demo Entries for Today

    static let todayEntries: [MacroEntry] = [
        MacroEntry(
            date: Date(),
            protein: 45,
            carbs: 50,
            fat: 15,
            notes: "Breakfast - Oatmeal with protein powder"
        ),
        MacroEntry(
            date: Date(),
            protein: 40,
            carbs: 60,
            fat: 12,
            notes: "Lunch - Chicken breast with rice"
        ),
        MacroEntry(
            date: Date(),
            protein: 35,
            carbs: 40,
            fat: 10,
            notes: "Snack - Greek yogurt"
        )
    ]

    // MARK: - Demo Entries for Last 7 Days

    static func entriesForLast7Days() -> [MacroEntry] {
        let calendar = Calendar.current
        var entries: [MacroEntry] = []

        // Generate entries for the last 7 days
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else {
                continue
            }

            let startOfDay = calendar.startOfDay(for: date)

            // 2-4 meals per day
            let mealCount = Int.random(in: 2...4)

            for mealIndex in 0..<mealCount {
                let protein = Double.random(in: 30...50)
                let carbs = Double.random(in: 40...70)
                let fat = Double.random(in: 10...20)

                let mealNames = ["Breakfast", "Lunch", "Snack", "Dinner"]
                let mealName = mealIndex < mealNames.count ? mealNames[mealIndex] : "Meal"

                // Add some time offset for each meal
                let mealTime = calendar.date(byAdding: .hour, value: 3 * mealIndex, to: startOfDay) ?? startOfDay

                let entry = MacroEntry(
                    date: mealTime,
                    protein: protein,
                    carbs: carbs,
                    fat: fat,
                    notes: dayOffset == 0 ? mealName : nil  // Only today has notes in demo
                )

                entries.append(entry)
            }
        }

        return entries.sorted { $0.date > $1.date }
    }

    // MARK: - Demo Daily Totals

    /// Calculate total macros for a specific date from demo entries
    static func totalMacros(for date: Date, from entries: [MacroEntry]) -> (protein: Double, carbs: Double, fat: Double) {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)

        let dayEntries = entries.filter {
            calendar.isDate($0.date, inSameDayAs: targetDay)
        }

        let totalProtein = dayEntries.reduce(0.0) { $0 + $1.protein }
        let totalCarbs = dayEntries.reduce(0.0) { $0 + $1.carbs }
        let totalFat = dayEntries.reduce(0.0) { $0 + $1.fat }

        return (totalProtein, totalCarbs, totalFat)
    }

    /// Get today's totals
    static func todayTotals() -> (protein: Double, carbs: Double, fat: Double) {
        let totalProtein = todayEntries.reduce(0.0) { $0 + $1.protein }
        let totalCarbs = todayEntries.reduce(0.0) { $0 + $1.carbs }
        let totalFat = todayEntries.reduce(0.0) { $0 + $1.fat }

        return (totalProtein, totalCarbs, totalFat)
    }

    // MARK: - Demo Statistics

    /// Calculate 7-day average
    static func weeklyAverage() -> (protein: Double, carbs: Double, fat: Double) {
        let entries = entriesForLast7Days()
        let calendar = Calendar.current

        var dailyTotals: [(protein: Double, carbs: Double, fat: Double)] = []

        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else {
                continue
            }

            let totals = totalMacros(for: date, from: entries)
            dailyTotals.append(totals)
        }

        guard !dailyTotals.isEmpty else {
            return (0, 0, 0)
        }

        let avgProtein = dailyTotals.reduce(0.0) { $0 + $1.protein } / Double(dailyTotals.count)
        let avgCarbs = dailyTotals.reduce(0.0) { $0 + $1.carbs } / Double(dailyTotals.count)
        let avgFat = dailyTotals.reduce(0.0) { $0 + $1.fat } / Double(dailyTotals.count)

        return (avgProtein, avgCarbs, avgFat)
    }

    /// Demo streak count (consecutive days)
    static let demoStreak = 5

    // MARK: - Demo Presets (Pro Feature)

    static let demoPresets = [
        (name: "Chicken & Rice", protein: 40.0, carbs: 60.0, fat: 12.0),
        (name: "Protein Shake", protein: 30.0, carbs: 5.0, fat: 3.0),
        (name: "Oatmeal Bowl", protein: 25.0, carbs: 50.0, fat: 10.0),
        (name: "Salmon & Veggies", protein: 35.0, carbs: 20.0, fat: 15.0)
    ]
}
