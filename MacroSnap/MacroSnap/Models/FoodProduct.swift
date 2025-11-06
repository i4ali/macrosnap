//
//  FoodProduct.swift
//  MacroSnap
//
//  Domain model for scanned food products from barcode database
//

import Foundation

// MARK: - Food Data Source

enum FoodDataSource: String, Codable {
    case openFoodFacts = "OpenFoodFacts"
    case usda = "USDA"
    case cached = "Cached"
    case manual = "Manual"
}

// MARK: - Food Product

struct FoodProduct: Identifiable, Codable, Equatable {
    let id: UUID
    let barcode: String
    let name: String
    let brand: String?

    // Nutritional info (per serving)
    let protein: Double      // grams
    let carbs: Double        // grams
    let fat: Double          // grams
    let calories: Double?    // kcal (optional)

    // Serving info
    let servingSize: String?  // e.g., "68g", "1 bar"
    let servingUnit: String?  // e.g., "g", "ml", "bar"

    // Metadata
    let imageUrl: String?
    let source: FoodDataSource
    let scannedAt: Date

    init(
        id: UUID = UUID(),
        barcode: String,
        name: String,
        brand: String? = nil,
        protein: Double,
        carbs: Double,
        fat: Double,
        calories: Double? = nil,
        servingSize: String? = nil,
        servingUnit: String? = nil,
        imageUrl: String? = nil,
        source: FoodDataSource = .openFoodFacts,
        scannedAt: Date = Date()
    ) {
        self.id = id
        self.barcode = barcode
        self.name = name
        self.brand = brand
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.calories = calories
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.imageUrl = imageUrl
        self.source = source
        self.scannedAt = scannedAt
    }

    // MARK: - Computed Properties

    var displayName: String {
        if let brand = brand, !brand.isEmpty {
            return "\(brand) - \(name)"
        }
        return name
    }

    var calculatedCalories: Double {
        if let calories = calories {
            return calories
        }
        // Calculate from macros if not provided
        return (protein * 4) + (carbs * 4) + (fat * 9)
    }

    var servingSizeDisplay: String {
        if let size = servingSize {
            return size
        } else if let unit = servingUnit {
            return "1 \(unit)"
        }
        return "1 serving"
    }

    var hasCompleteData: Bool {
        protein > 0 && carbs >= 0 && fat >= 0 && !name.isEmpty
    }
}

// MARK: - Sample Data

extension FoodProduct {
    static let sample = FoodProduct(
        barcode: "722252100016",
        name: "Clif Bar Chocolate Chip",
        brand: "Clif Bar",
        protein: 9,
        carbs: 44,
        fat: 5,
        calories: 250,
        servingSize: "68g",
        servingUnit: "bar",
        source: .openFoodFacts
    )

    static let samples: [FoodProduct] = [
        FoodProduct(
            barcode: "722252100016",
            name: "Clif Bar Chocolate Chip",
            brand: "Clif Bar",
            protein: 9,
            carbs: 44,
            fat: 5,
            calories: 250,
            servingSize: "68g",
            servingUnit: "bar",
            source: .openFoodFacts
        ),
        FoodProduct(
            barcode: "888849000028",
            name: "Quest Bar Chocolate Chip",
            brand: "Quest Nutrition",
            protein: 21,
            carbs: 24,
            fat: 9,
            calories: 200,
            servingSize: "60g",
            servingUnit: "bar",
            source: .openFoodFacts
        ),
        FoodProduct(
            barcode: "748927023480",
            name: "Gold Standard Whey Protein",
            brand: "Optimum Nutrition",
            protein: 24,
            carbs: 3,
            fat: 1,
            calories: 120,
            servingSize: "30g",
            servingUnit: "scoop",
            source: .openFoodFacts
        )
    ]
}
