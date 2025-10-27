//
//  MacroEntryEntity+CoreDataProperties.swift
//  MacroSnap
//
//  CoreData entity properties for macro entries
//

import Foundation
import CoreData

extension MacroEntryEntity {

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var protein: Double
    @NSManaged public var carbs: Double
    @NSManaged public var fat: Double
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var ckRecordID: String?  // CloudKit record ID
    @NSManaged public var ckSystemFields: Data?  // CloudKit system fields (encoded)

}

extension MacroEntryEntity : Identifiable {

}
