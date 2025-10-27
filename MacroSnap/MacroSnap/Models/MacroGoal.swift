//
//  MacroGoal.swift
//  MacroSnap
//
//  Domain model for macro goals
//

import Foundation

struct MacroGoal: Identifiable, Codable, Equatable {
    let id: UUID
    var proteinGoal: Double
    var carbGoal: Double
    var fatGoal: Double
    let dayOfWeek: Int?  // nil = default goal, 0-6 = Sun-Sat
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        proteinGoal: Double,
        carbGoal: Double,
        fatGoal: Double,
        dayOfWeek: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.proteinGoal = proteinGoal
        self.carbGoal = carbGoal
        self.fatGoal = fatGoal
        self.dayOfWeek = dayOfWeek
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Computed properties
    var totalCalorieGoal: Double {
        (proteinGoal * 4) + (carbGoal * 4) + (fatGoal * 9)
    }

    var isDefaultGoal: Bool {
        dayOfWeek == nil
    }

    var dayName: String? {
        guard let day = dayOfWeek else { return nil }
        let formatter = DateFormatter()
        return formatter.weekdaySymbols[day]
    }
}

// MARK: - Sample Data
extension MacroGoal {
    static let `default` = MacroGoal(
        proteinGoal: 180,
        carbGoal: 250,
        fatGoal: 70
    )

    static let sample = MacroGoal(
        proteinGoal: 180,
        carbGoal: 250,
        fatGoal: 70
    )

    // Sample goals for different days (Pro feature - carb cycling)
    static let samples: [MacroGoal] = [
        MacroGoal(proteinGoal: 180, carbGoal: 250, fatGoal: 70), // Default
        MacroGoal(proteinGoal: 180, carbGoal: 300, fatGoal: 60, dayOfWeek: 1), // Monday - high carb
        MacroGoal(proteinGoal: 180, carbGoal: 200, fatGoal: 80, dayOfWeek: 3), // Wednesday - moderate
        MacroGoal(proteinGoal: 180, carbGoal: 100, fatGoal: 90, dayOfWeek: 0)  // Sunday - low carb
    ]
}
