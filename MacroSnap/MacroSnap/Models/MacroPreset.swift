//
//  MacroPreset.swift
//  MacroSnap
//
//  Domain model for macro presets (Pro feature)
//

import Foundation

struct MacroPreset: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var protein: Double
    var carbs: Double
    var fat: Double
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        protein: Double,
        carbs: Double,
        fat: Double,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Computed properties
    var totalCalories: Double {
        (protein * 4) + (carbs * 4) + (fat * 9)
    }

    var macroSummary: String {
        "\(Int(protein))P • \(Int(carbs))C • \(Int(fat))F"
    }
}

// MARK: - Sample Data
extension MacroPreset {
    static let sample = MacroPreset(
        name: "Chicken & Rice",
        protein: 40,
        carbs: 50,
        fat: 10
    )

    static let samples: [MacroPreset] = [
        MacroPreset(
            name: "Protein Shake",
            protein: 30,
            carbs: 5,
            fat: 2
        ),
        MacroPreset(
            name: "Oatmeal Breakfast",
            protein: 15,
            carbs: 45,
            fat: 8
        ),
        MacroPreset(
            name: "Chicken & Rice",
            protein: 40,
            carbs: 50,
            fat: 10
        ),
        MacroPreset(
            name: "Salmon Dinner",
            protein: 35,
            carbs: 30,
            fat: 15
        )
    ]
}
