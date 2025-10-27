//
//  PresetEntity+CoreDataProperties.swift
//  MacroSnap
//
//  CoreData properties for PresetEntity
//

import Foundation
import CoreData

extension PresetEntity {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var protein: Double
    @NSManaged public var carbs: Double
    @NSManaged public var fat: Double
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var ckRecordID: String?  // CloudKit record ID
    @NSManaged public var ckSystemFields: Data?  // CloudKit system fields (encoded)
}

extension PresetEntity: Identifiable {
}
