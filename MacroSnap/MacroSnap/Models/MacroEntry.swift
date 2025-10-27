//
//  MacroEntry.swift
//  MacroSnap
//
//  Domain model for macro entries
//

import Foundation

struct MacroEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var protein: Double
    var carbs: Double
    var fat: Double
    var notes: String?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        date: Date,
        protein: Double,
        carbs: Double,
        fat: Double,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Computed properties
    var totalCalories: Double {
        (protein * 4) + (carbs * 4) + (fat * 9)
    }

    // Date helpers
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Sample Data
extension MacroEntry {
    static let sample = MacroEntry(
        date: Date(),
        protein: 40,
        carbs: 30,
        fat: 10,
        notes: "Chicken breast with rice"
    )

    static let samples: [MacroEntry] = [
        MacroEntry(
            date: Date(),
            protein: 45,
            carbs: 50,
            fat: 15,
            notes: "Breakfast"
        ),
        MacroEntry(
            date: Date(),
            protein: 40,
            carbs: 60,
            fat: 12,
            notes: "Lunch"
        ),
        MacroEntry(
            date: Date(),
            protein: 35,
            carbs: 40,
            fat: 10
        )
    ]
}
