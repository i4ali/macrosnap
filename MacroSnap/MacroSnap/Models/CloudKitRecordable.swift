//
//  CloudKitRecordable.swift
//  MacroSnap
//
//  Protocol for converting between CoreData entities and CloudKit records
//

import Foundation
import CloudKit
import CoreData

/// Protocol for entities that can be synced with CloudKit
protocol CloudKitRecordable {
    /// Convert the entity to a CloudKit record
    func toCKRecord() -> CKRecord

    /// Update the entity from a CloudKit record
    func update(from record: CKRecord)

    /// The CloudKit record ID
    var ckRecordID: String? { get set }

    /// CloudKit system fields (encoded data)
    var ckSystemFields: Data? { get set }
}

// MARK: - Helper Extensions

extension CloudKitRecordable {
    /// Get or create a CKRecord for this entity
    func getOrCreateRecord(recordType: String) -> CKRecord {
        // Try to decode existing record from system fields
        if let systemFields = ckSystemFields,
           let coder = try? NSKeyedUnarchiver(forReadingFrom: systemFields),
           let record = CKRecord(coder: coder) {
            return record
        }

        // Create new record
        let recordID: CKRecord.ID
        if let existingID = ckRecordID {
            recordID = CKRecord.ID(recordName: existingID, zoneID: CloudKitConfig.customZone.zoneID)
        } else {
            recordID = CKRecord.ID(zoneID: CloudKitConfig.customZone.zoneID)
        }

        return CKRecord(recordType: recordType, recordID: recordID)
    }

    /// Save CloudKit system fields after a successful sync
    mutating func saveSystemFields(from record: CKRecord) {
        // Save record ID
        ckRecordID = record.recordID.recordName

        // Encode and save system fields
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: coder)
        ckSystemFields = coder.encodedData
    }
}

// MARK: - MacroEntryEntity + CloudKit

extension MacroEntryEntity: CloudKitRecordable {
    func toCKRecord() -> CKRecord {
        let record = getOrCreateRecord(recordType: CloudKitConfig.RecordType.macroEntry.rawValue)

        record[CloudKitConfig.MacroEntryFields.date] = date as? CKRecordValue
        record[CloudKitConfig.MacroEntryFields.protein] = protein as CKRecordValue
        record[CloudKitConfig.MacroEntryFields.carbs] = carbs as CKRecordValue
        record[CloudKitConfig.MacroEntryFields.fat] = fat as CKRecordValue
        record[CloudKitConfig.MacroEntryFields.notes] = notes as? CKRecordValue
        record[CloudKitConfig.MacroEntryFields.createdAt] = createdAt as? CKRecordValue
        record[CloudKitConfig.MacroEntryFields.updatedAt] = updatedAt as? CKRecordValue

        return record
    }

    func update(from record: CKRecord) {
        date = record[CloudKitConfig.MacroEntryFields.date] as? Date
        protein = record[CloudKitConfig.MacroEntryFields.protein] as? Double ?? 0
        carbs = record[CloudKitConfig.MacroEntryFields.carbs] as? Double ?? 0
        fat = record[CloudKitConfig.MacroEntryFields.fat] as? Double ?? 0
        notes = record[CloudKitConfig.MacroEntryFields.notes] as? String
        createdAt = record[CloudKitConfig.MacroEntryFields.createdAt] as? Date
        // If updatedAt is missing (old records), use createdAt as fallback
        updatedAt = record[CloudKitConfig.MacroEntryFields.updatedAt] as? Date ?? createdAt ?? Date()

        // Save system fields
        var mutableSelf = self
        mutableSelf.saveSystemFields(from: record)
    }
}

// MARK: - GoalEntity + CloudKit

extension GoalEntity: CloudKitRecordable {
    func toCKRecord() -> CKRecord {
        let record = getOrCreateRecord(recordType: CloudKitConfig.RecordType.goal.rawValue)

        record[CloudKitConfig.GoalFields.proteinGoal] = proteinGoal as CKRecordValue
        record[CloudKitConfig.GoalFields.carbGoal] = carbGoal as CKRecordValue
        record[CloudKitConfig.GoalFields.fatGoal] = fatGoal as CKRecordValue
        record[CloudKitConfig.GoalFields.dayOfWeek] = dayOfWeek as CKRecordValue
        record[CloudKitConfig.GoalFields.createdAt] = createdAt as? CKRecordValue
        record[CloudKitConfig.GoalFields.updatedAt] = updatedAt as? CKRecordValue

        return record
    }

    func update(from record: CKRecord) {
        proteinGoal = record[CloudKitConfig.GoalFields.proteinGoal] as? Double ?? 0
        carbGoal = record[CloudKitConfig.GoalFields.carbGoal] as? Double ?? 0
        fatGoal = record[CloudKitConfig.GoalFields.fatGoal] as? Double ?? 0
        dayOfWeek = record[CloudKitConfig.GoalFields.dayOfWeek] as? Int16 ?? -1
        createdAt = record[CloudKitConfig.GoalFields.createdAt] as? Date
        // If updatedAt is missing (old records), use createdAt as fallback
        updatedAt = record[CloudKitConfig.GoalFields.updatedAt] as? Date ?? createdAt ?? Date()

        // Save system fields
        var mutableSelf = self
        mutableSelf.saveSystemFields(from: record)
    }
}

// MARK: - PresetEntity + CloudKit

extension PresetEntity: CloudKitRecordable {
    func toCKRecord() -> CKRecord {
        let record = getOrCreateRecord(recordType: CloudKitConfig.RecordType.preset.rawValue)

        record[CloudKitConfig.PresetFields.name] = name as? CKRecordValue
        record[CloudKitConfig.PresetFields.protein] = protein as CKRecordValue
        record[CloudKitConfig.PresetFields.carbs] = carbs as CKRecordValue
        record[CloudKitConfig.PresetFields.fat] = fat as CKRecordValue
        record[CloudKitConfig.PresetFields.createdAt] = createdAt as? CKRecordValue
        record["updatedAt"] = updatedAt as? CKRecordValue

        return record
    }

    func update(from record: CKRecord) {
        name = record[CloudKitConfig.PresetFields.name] as? String
        protein = record[CloudKitConfig.PresetFields.protein] as? Double ?? 0
        carbs = record[CloudKitConfig.PresetFields.carbs] as? Double ?? 0
        fat = record[CloudKitConfig.PresetFields.fat] as? Double ?? 0
        createdAt = record[CloudKitConfig.PresetFields.createdAt] as? Date
        // If updatedAt is missing (old records), use createdAt as fallback
        updatedAt = record["updatedAt"] as? Date ?? createdAt ?? Date()

        // Save system fields
        var mutableSelf = self
        mutableSelf.saveSystemFields(from: record)
    }
}
