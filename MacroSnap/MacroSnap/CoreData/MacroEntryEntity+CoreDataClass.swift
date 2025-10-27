//
//  MacroEntryEntity+CoreDataClass.swift
//  MacroSnap
//
//  CoreData entity for macro entries (offline caching)
//

import Foundation
import CoreData

@objc(MacroEntryEntity)
public class MacroEntryEntity: NSManagedObject {
    // Convenience initializer
    convenience init(context: NSManagedObjectContext, id: UUID = UUID(), date: Date, protein: Double, carbs: Double, fat: Double, notes: String? = nil) {
        self.init(context: context)
        self.id = id
        self.date = date
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Convert to domain model
    func toDomain() -> MacroEntry {
        MacroEntry(
            id: id ?? UUID(),
            date: date ?? Date(),
            protein: protein,
            carbs: carbs,
            fat: fat,
            notes: notes,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }

    // Update from domain model
    func update(from entry: MacroEntry) {
        self.id = entry.id
        self.date = entry.date
        self.protein = entry.protein
        self.carbs = entry.carbs
        self.fat = entry.fat
        self.notes = entry.notes
        self.updatedAt = entry.updatedAt
    }
}

// MARK: - Fetch Requests
extension MacroEntryEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MacroEntryEntity> {
        return NSFetchRequest<MacroEntryEntity>(entityName: "MacroEntryEntity")
    }

    // Fetch entries for a specific date
    static func fetchEntries(for date: Date, context: NSManagedObjectContext) -> [MacroEntryEntity] {
        let request = fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MacroEntryEntity.createdAt, ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch entries: \(error)")
            return []
        }
    }


    // Fetch entries within date range
    static func fetchEntries(from startDate: Date, to endDate: Date, context: NSManagedObjectContext) -> [MacroEntryEntity] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MacroEntryEntity.date, ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch entries: \(error)")
            return []
        }
    }
}
