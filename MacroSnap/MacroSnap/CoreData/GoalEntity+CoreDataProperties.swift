//
//  GoalEntity+CoreDataProperties.swift
//  MacroSnap
//
//  CoreData entity properties for macro goals
//

import Foundation
import CoreData

extension GoalEntity {

    @NSManaged public var id: UUID?
    @NSManaged public var proteinGoal: Double
    @NSManaged public var carbGoal: Double
    @NSManaged public var fatGoal: Double
    @NSManaged public var dayOfWeek: Int16  // -1 = default goal, 0-6 = Sun-Sat
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var ckRecordID: String?  // CloudKit record ID
    @NSManaged public var ckSystemFields: Data?  // CloudKit system fields (encoded)

}

extension GoalEntity : Identifiable {

}
