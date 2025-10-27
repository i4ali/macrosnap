//
//  GoalEntity+CoreDataClass.swift
//  MacroSnap
//
//  CoreData entity for macro goals (offline caching)
//

import Foundation
import CoreData

@objc(GoalEntity)
public class GoalEntity: NSManagedObject {
    // Convenience initializer
    convenience init(context: NSManagedObjectContext, id: UUID = UUID(), proteinGoal: Double, carbGoal: Double, fatGoal: Double, dayOfWeek: Int16? = nil) {
        self.init(context: context)
        self.id = id
        self.proteinGoal = proteinGoal
        self.carbGoal = carbGoal
        self.fatGoal = fatGoal
        self.dayOfWeek = dayOfWeek ?? -1  // -1 means default goal
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Convert to domain model
    func toDomain() -> MacroGoal {
        MacroGoal(
            id: id ?? UUID(),
            proteinGoal: proteinGoal,
            carbGoal: carbGoal,
            fatGoal: fatGoal,
            dayOfWeek: dayOfWeek >= 0 ? Int(dayOfWeek) : nil,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }

    // Update from domain model
    func update(from goal: MacroGoal) {
        self.id = goal.id
        self.proteinGoal = goal.proteinGoal
        self.carbGoal = goal.carbGoal
        self.fatGoal = goal.fatGoal
        self.dayOfWeek = goal.dayOfWeek.map { Int16($0) } ?? -1
        self.updatedAt = goal.updatedAt
    }
}

// MARK: - Fetch Requests
extension GoalEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoalEntity> {
        return NSFetchRequest<GoalEntity>(entityName: "GoalEntity")
    }

    // Fetch default goal (no specific day)
    static func fetchDefaultGoal(context: NSManagedObjectContext) -> GoalEntity? {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "dayOfWeek == -1")
        request.fetchLimit = 1

        do {
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch default goal: \(error)")
            return nil
        }
    }

    // Fetch goal for specific day of week
    static func fetchGoal(for dayOfWeek: Int, context: NSManagedObjectContext) -> GoalEntity? {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "dayOfWeek == %d", Int16(dayOfWeek))
        request.fetchLimit = 1

        do {
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch goal for day \(dayOfWeek): \(error)")
            return nil
        }
    }

    // Fetch all goals
    static func fetchAllGoals(context: NSManagedObjectContext) -> [GoalEntity] {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GoalEntity.dayOfWeek, ascending: true)]

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch all goals: \(error)")
            return []
        }
    }

}
