//
//  ProgressSnapshotGenerator.swift
//  MacroSnap
//
//  Generates shareable snapshot images of macro progress
//

import SwiftUI
import UIKit

class ProgressSnapshotGenerator {
    static let shared = ProgressSnapshotGenerator()

    private init() {}

    /// Generate a shareable image of today's progress
    /// - Parameters:
    ///   - proteinCurrent: Current protein intake
    ///   - proteinGoal: Protein goal
    ///   - carbsCurrent: Current carbs intake
    ///   - carbsGoal: Carbs goal
    ///   - fatCurrent: Current fat intake
    ///   - fatGoal: Fat goal
    ///   - date: The date for the snapshot
    ///   - entryCount: Number of entries logged
    ///   - theme: Current theme for styling
    /// - Returns: High-resolution UIImage ready for sharing
    @MainActor
    func generateSnapshot(
        proteinCurrent: Double,
        proteinGoal: Double,
        carbsCurrent: Double,
        carbsGoal: Double,
        fatCurrent: Double,
        fatGoal: Double,
        date: Date,
        entryCount: Int,
        theme: AppTheme
    ) -> UIImage? {
        // Create the snapshot view
        let snapshotView = ProgressSnapshotView(
            proteinCurrent: proteinCurrent,
            proteinGoal: proteinGoal,
            carbsCurrent: carbsCurrent,
            carbsGoal: carbsGoal,
            fatCurrent: fatCurrent,
            fatGoal: fatGoal,
            date: date,
            entryCount: entryCount,
            backgroundColor: theme.backgroundColor ?? Color(.systemBackground)
        )

        // Use ImageRenderer to convert SwiftUI view to UIImage
        let renderer = ImageRenderer(content: snapshotView)

        // Set high resolution for quality (3x for retina displays)
        renderer.scale = 3.0

        // Render the image
        guard let uiImage = renderer.uiImage else {
            print("❌ Failed to render snapshot image")
            return nil
        }

        print("✅ Successfully generated snapshot image: \(uiImage.size)")
        return uiImage
    }

    /// Calculate total calories from macros
    static func calculateCalories(protein: Double, carbs: Double, fat: Double) -> Int {
        return Int((protein * 4) + (carbs * 4) + (fat * 9))
    }
}
