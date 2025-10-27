//
//  PresetEntity+CoreDataClass.swift
//  MacroSnap
//
//  CoreData entity for macro presets (offline caching)
//

import Foundation
import CoreData

@objc(PresetEntity)
public class PresetEntity: NSManagedObject {
    // Convenience initializer
    convenience init(context: NSManagedObjectContext, id: UUID = UUID(), name: String, protein: Double, carbs: Double, fat: Double) {
        self.init(context: context)
        self.id = id
        self.name = name
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Convert to domain model
    func toDomain() -> MacroPreset {
        MacroPreset(
            id: id ?? UUID(),
            name: name ?? "",
            protein: protein,
            carbs: carbs,
            fat: fat,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }

    // Update from domain model
    func update(from preset: MacroPreset) {
        self.id = preset.id
        self.name = preset.name
        self.protein = preset.protein
        self.carbs = preset.carbs
        self.fat = preset.fat
        self.updatedAt = preset.updatedAt
    }
}

// MARK: - Fetch Requests
extension PresetEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PresetEntity> {
        return NSFetchRequest<PresetEntity>(entityName: "PresetEntity")
    }

    // Fetch all presets sorted by name
    static func fetchAllPresets(context: NSManagedObjectContext) -> [PresetEntity] {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PresetEntity.name, ascending: true)]

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch presets: \(error)")
            return []
        }
    }

}
