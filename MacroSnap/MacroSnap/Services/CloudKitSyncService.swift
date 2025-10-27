//
//  CloudKitSyncService.swift
//  MacroSnap
//
//  Handles bidirectional sync between CoreData and CloudKit
//

import Foundation
import CloudKit
import CoreData
import Combine

@MainActor
class CloudKitSyncService: ObservableObject {
    // MARK: - Published Properties

    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?
    @Published var isCloudKitAvailable = false

    // MARK: - Private Properties

    private let container = CloudKitConfig.container
    private let database = CloudKitConfig.privateDatabase
    private let viewContext: NSManagedObjectContext

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext

        Task {
            await checkCloudKitStatus()
            await setupCustomZone()
        }
    }

    // MARK: - CloudKit Status

    /// Check if CloudKit is available and user is signed in
    func checkCloudKitStatus() async {
        do {
            let status = try await container.accountStatus()

            switch status {
            case .available:
                isCloudKitAvailable = true
                print("✅ CloudKit is available")

                // Trigger initial sync now that CloudKit is ready
                await performFullSync()

            case .noAccount:
                isCloudKitAvailable = false
                print("⚠️ No iCloud account signed in")
            case .restricted:
                isCloudKitAvailable = false
                print("⚠️ iCloud is restricted")
            case .couldNotDetermine:
                isCloudKitAvailable = false
                print("⚠️ Could not determine iCloud status")
            case .temporarilyUnavailable:
                isCloudKitAvailable = false
                print("⚠️ iCloud temporarily unavailable")
            @unknown default:
                isCloudKitAvailable = false
                print("⚠️ Unknown iCloud status")
            }
        } catch {
            isCloudKitAvailable = false
            print("❌ Failed to check CloudKit status: \(error)")
        }
    }

    // MARK: - Zone Setup

    /// Create custom zone for organizing records
    private func setupCustomZone() async {
        guard isCloudKitAvailable else { return }

        do {
            let zone = CloudKitConfig.customZone
            try await database.save(zone)
            print("✅ Custom zone created or verified")
        } catch {
            // Zone might already exist, which is fine
            print("⚠️ Zone setup: \(error.localizedDescription)")
        }
    }

    // MARK: - Full Sync

    /// Perform a full bidirectional sync
    func performFullSync() async {
        guard isCloudKitAvailable else {
            print("⚠️ Cannot sync: CloudKit not available")
            return
        }

        guard !isSyncing else {
            print("⚠️ Sync already in progress")
            return
        }

        isSyncing = true
        defer { isSyncing = false }

        print("🔄 Starting full sync...")

        // Push local changes to CloudKit
        await syncLocalToCloud()

        // Pull remote changes from CloudKit
        await syncCloudToLocal()

        lastSyncDate = Date()
        print("✅ Full sync completed")
    }

    // MARK: - Sync Local to Cloud

    /// Upload local changes to CloudKit (public for targeted syncing)
    func syncLocalToCloud() async {
        // Sync entries
        await syncEntriesToCloud()

        // Sync goals
        await syncGoalsToCloud()

        // Sync presets
        await syncPresetsToCloud()
    }

    private func syncEntriesToCloud() async {
        let fetchRequest = MacroEntryEntity.fetchRequest()
        // Only sync entries that don't have a CloudKit record ID (new entries)
        fetchRequest.predicate = NSPredicate(format: "ckRecordID == nil OR ckRecordID == %@", "")

        do {
            let entities = try viewContext.fetch(fetchRequest)

            guard !entities.isEmpty else {
                print("📦 No new entries to sync")
                return
            }

            print("📤 Uploading \(entities.count) entries to CloudKit...")

            let records = entities.map { $0.toCKRecord() }
            let savedRecords = try await saveRecordsInBatches(records)

            // Update entities with CloudKit IDs
            for (index, entity) in entities.enumerated() {
                if index < savedRecords.count {
                    let recordID = savedRecords[index].recordID.recordName
                    entity.ckRecordID = recordID
                    print("✅ Entry saved with ID: \(recordID)")
                }
            }

            try viewContext.save()
            print("✅ Successfully uploaded \(savedRecords.count) entries to CloudKit")

        } catch {
            print("❌ Failed to sync entries to CloudKit: \(error)")
            syncError = error
        }
    }

    private func syncGoalsToCloud() async {
        let fetchRequest = GoalEntity.fetchRequest()
        // Upload ALL goals, not just new ones (goals with cleared ckRecordID will be uploaded)
        fetchRequest.predicate = NSPredicate(format: "ckRecordID == nil OR ckRecordID == %@", "")

        do {
            let entities = try viewContext.fetch(fetchRequest)

            guard !entities.isEmpty else {
                print("📦 No goals to sync")
                return
            }

            print("📤 Uploading \(entities.count) goals to CloudKit...")

            let records = entities.map { $0.toCKRecord() }
            let savedRecords = try await saveRecordsInBatches(records)

            // Update entities with CloudKit IDs
            for (index, entity) in entities.enumerated() {
                if index < savedRecords.count {
                    let recordID = savedRecords[index].recordID.recordName
                    entity.ckRecordID = recordID
                    print("✅ Goal saved with ID: \(recordID)")
                }
            }

            try viewContext.save()
            print("✅ Successfully uploaded \(savedRecords.count) goals to CloudKit")

        } catch {
            print("❌ Failed to sync goals to CloudKit: \(error)")
            syncError = error
        }
    }

    private func syncPresetsToCloud() async {
        let fetchRequest = PresetEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PresetEntity.updatedAt, ascending: false)]

        do {
            let entities = try viewContext.fetch(fetchRequest)

            guard !entities.isEmpty else {
                print("📦 No presets to sync")
                return
            }

            print("📤 Uploading \(entities.count) presets to CloudKit...")

            // Separate new presets (no ckRecordID) from existing ones
            let newPresets = entities.filter { $0.ckRecordID == nil || $0.ckRecordID?.isEmpty == true }
            let existingPresets = entities.filter { $0.ckRecordID != nil && $0.ckRecordID?.isEmpty == false }

            // Upload new presets
            if !newPresets.isEmpty {
                print("📤 Uploading \(newPresets.count) new presets...")
                let records = newPresets.map { $0.toCKRecord() }
                let savedRecords = try await saveRecordsInBatches(records)

                // Update entities with CloudKit record IDs
                for (index, entity) in newPresets.enumerated() {
                    if index < savedRecords.count {
                        let recordID = savedRecords[index].recordID.recordName
                        entity.ckRecordID = recordID
                        print("✅ New preset '\(entity.name ?? "Unknown")' saved with ID: \(recordID)")
                    }
                }
            }

            // Update existing presets
            if !existingPresets.isEmpty {
                print("📤 Updating \(existingPresets.count) existing presets...")
                let records = existingPresets.map { $0.toCKRecord() }
                let savedRecords = try await saveRecordsInBatches(records)
                print("✅ Updated \(savedRecords.count) existing presets in CloudKit")
            }

            try viewContext.save()
            print("✅ Successfully synced all presets to CloudKit")

        } catch {
            print("❌ Failed to sync presets to CloudKit: \(error)")
            syncError = error
        }
    }

    // MARK: - Sync Cloud to Local

    /// Download remote changes from CloudKit
    private func syncCloudToLocal() async {
        await fetchEntriesFromCloud()
        await fetchGoalsFromCloud()
        await fetchPresetsFromCloud()
    }

    private func fetchEntriesFromCloud() async {
        // Query for all entries created after Jan 1, 2000 (which is effectively all records)
        let distantPast = Date(timeIntervalSince1970: 946684800) // Jan 1, 2000
        let query = CKQuery(recordType: CloudKitConfig.RecordType.macroEntry.rawValue, predicate: NSPredicate(format: "date >= %@", distantPast as NSDate))
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            let (results, _) = try await database.records(matching: query, inZoneWith: CloudKitConfig.customZone.zoneID)

            print("📥 Fetched \(results.count) entries from CloudKit")

            for (_, result) in results {
                switch result {
                case .success(let record):
                    updateOrCreateEntry(from: record)
                case .failure(let error):
                    print("❌ Failed to fetch entry: \(error)")
                }
            }

            try viewContext.save()

        } catch let error as CKError where error.code == .unknownItem || error.code == .invalidArguments {
            // Schema doesn't exist yet or fields not indexed - this is expected on first run
            print("⚠️ CloudKit schema not created yet for entries (this is normal on first run)")
        } catch {
            print("❌ Failed to fetch entries from CloudKit: \(error)")
            syncError = error
        }
    }

    private func fetchGoalsFromCloud() async {
        // Query for all goals created after Jan 1, 2000 (which is effectively all records)
        let distantPast = Date(timeIntervalSince1970: 946684800) // Jan 1, 2000
        let query = CKQuery(recordType: CloudKitConfig.RecordType.goal.rawValue, predicate: NSPredicate(format: "createdAt >= %@", distantPast as NSDate))
        query.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]

        do {
            let (results, _) = try await database.records(matching: query, inZoneWith: CloudKitConfig.customZone.zoneID)

            print("📥 Fetched \(results.count) goals from CloudKit")

            // Group goals by dayOfWeek and only keep the most recent
            var goalsByDay: [Int16: CKRecord] = [:]
            var duplicatesToDelete: [CKRecord.ID] = []

            for (_, result) in results {
                switch result {
                case .success(let record):
                    let dayOfWeek = record[CloudKitConfig.GoalFields.dayOfWeek] as? Int16 ?? -1

                    if let existingRecord = goalsByDay[dayOfWeek] {
                        // We already have a goal for this day - mark this one as duplicate
                        duplicatesToDelete.append(record.recordID)
                        print("🗑️ Marking duplicate goal for day \(dayOfWeek) for deletion")
                    } else {
                        // First goal for this day - keep it
                        goalsByDay[dayOfWeek] = record
                        updateOrCreateGoal(from: record)
                    }
                case .failure(let error):
                    print("❌ Failed to fetch goal: \(error)")
                }
            }

            try viewContext.save()

            // Delete duplicates from CloudKit
            if !duplicatesToDelete.isEmpty {
                print("🗑️ Deleting \(duplicatesToDelete.count) duplicate goals from CloudKit...")
                do {
                    let _ = try await database.modifyRecords(saving: [], deleting: duplicatesToDelete)
                    print("✅ Deleted \(duplicatesToDelete.count) duplicate goals from CloudKit")
                } catch {
                    print("❌ Failed to delete duplicates: \(error)")
                }
            }

        } catch let error as CKError where error.code == .unknownItem || error.code == .invalidArguments {
            // Schema doesn't exist yet or fields not indexed - this is expected on first run
            print("⚠️ CloudKit schema not created yet for goals (this is normal on first run)")
        } catch {
            print("❌ Failed to fetch goals from CloudKit: \(error)")
            syncError = error
        }
    }

    private func fetchPresetsFromCloud() async {
        // Query for all presets created after Jan 1, 2000 (which is effectively all records)
        let distantPast = Date(timeIntervalSince1970: 946684800) // Jan 1, 2000
        let query = CKQuery(recordType: CloudKitConfig.RecordType.preset.rawValue, predicate: NSPredicate(format: "createdAt >= %@", distantPast as NSDate))
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            print("🔍 Querying CloudKit for presets in zone: \(CloudKitConfig.customZone.zoneID.zoneName)")
            let (results, _) = try await database.records(matching: query, inZoneWith: CloudKitConfig.customZone.zoneID)

            print("📥 Fetched \(results.count) presets from CloudKit")

            for (_, result) in results {
                switch result {
                case .success(let record):
                    print("📦 Processing preset: \(record.recordID.recordName)")
                    updateOrCreatePreset(from: record)
                case .failure(let error):
                    print("❌ Failed to fetch preset: \(error)")
                }
            }

            try viewContext.save()

        } catch let error as CKError where error.code == .unknownItem || error.code == .invalidArguments {
            // Schema doesn't exist yet or fields not indexed - this is expected on first run
            print("⚠️ CloudKit schema not created yet for presets (Error code: \(error.code.rawValue), Message: \(error.localizedDescription))")
        } catch {
            print("❌ Failed to fetch presets from CloudKit: \(error)")
            if let ckError = error as? CKError {
                print("   Error code: \(ckError.code.rawValue)")
                print("   Error description: \(ckError.localizedDescription)")
            }
            syncError = error
        }
    }

    // MARK: - Update or Create Entities

    private func updateOrCreateEntry(from record: CKRecord) {
        let fetchRequest = MacroEntryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "ckRecordID == %@", record.recordID.recordName)
        fetchRequest.fetchLimit = 1

        do {
            let results = try viewContext.fetch(fetchRequest)

            if let existingEntity = results.first {
                existingEntity.update(from: record)
            } else {
                let newEntity = MacroEntryEntity(context: viewContext)
                newEntity.id = UUID()
                newEntity.update(from: record)
            }
        } catch {
            print("❌ Failed to update entry: \(error)")
        }
    }

    private func updateOrCreateGoal(from record: CKRecord) {
        let dayOfWeek = record[CloudKitConfig.GoalFields.dayOfWeek] as? Int16 ?? -1

        // First try to find by dayOfWeek (since each day should have only one goal)
        let fetchRequest = GoalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dayOfWeek == %d", dayOfWeek)
        fetchRequest.fetchLimit = 1

        do {
            let results = try viewContext.fetch(fetchRequest)

            if let existingEntity = results.first {
                existingEntity.update(from: record)
            } else {
                let newEntity = GoalEntity(context: viewContext)
                newEntity.id = UUID()
                newEntity.update(from: record)
            }
        } catch {
            print("❌ Failed to update goal: \(error)")
        }
    }

    private func updateOrCreatePreset(from record: CKRecord) {
        let fetchRequest = PresetEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "ckRecordID == %@", record.recordID.recordName)
        fetchRequest.fetchLimit = 1

        do {
            let results = try viewContext.fetch(fetchRequest)

            if let existingEntity = results.first {
                // Only update if CloudKit version is newer
                let cloudUpdatedAt = record["updatedAt"] as? Date ?? Date.distantPast
                let localUpdatedAt = existingEntity.updatedAt ?? Date.distantPast

                if cloudUpdatedAt > localUpdatedAt {
                    print("☁️ Updating local preset with newer CloudKit version")
                    existingEntity.update(from: record)
                } else {
                    print("💾 Keeping local preset (newer than CloudKit version)")
                }
            } else {
                let newEntity = PresetEntity(context: viewContext)
                newEntity.id = UUID()
                newEntity.update(from: record)
            }
        } catch {
            print("❌ Failed to update preset: \(error)")
        }
    }

    // MARK: - Delete from CloudKit

    /// Delete a preset from CloudKit
    func deletePreset(recordID: String) async {
        guard isCloudKitAvailable else {
            print("⚠️ Cannot delete: CloudKit not available")
            return
        }

        let ckRecordID = CKRecord.ID(recordName: recordID, zoneID: CloudKitConfig.customZone.zoneID)

        do {
            try await database.deleteRecord(withID: ckRecordID)
            print("✅ Deleted preset from CloudKit: \(recordID)")
        } catch {
            print("❌ Failed to delete preset from CloudKit: \(error)")
            syncError = error
        }
    }

    /// Delete an entry from CloudKit
    func deleteEntry(recordID: String) async {
        guard isCloudKitAvailable else {
            print("⚠️ Cannot delete: CloudKit not available")
            return
        }

        let ckRecordID = CKRecord.ID(recordName: recordID, zoneID: CloudKitConfig.customZone.zoneID)

        do {
            try await database.deleteRecord(withID: ckRecordID)
            print("✅ Deleted entry from CloudKit: \(recordID)")
        } catch {
            print("❌ Failed to delete entry from CloudKit: \(error)")
            syncError = error
        }
    }

    /// Delete a goal from CloudKit
    func deleteGoal(recordID: String) async {
        guard isCloudKitAvailable else {
            print("⚠️ Cannot delete: CloudKit not available")
            return
        }

        let ckRecordID = CKRecord.ID(recordName: recordID, zoneID: CloudKitConfig.customZone.zoneID)

        do {
            try await database.deleteRecord(withID: ckRecordID)
            print("✅ Deleted goal from CloudKit: \(recordID)")
        } catch {
            print("❌ Failed to delete goal from CloudKit: \(error)")
            syncError = error
        }
    }

    // MARK: - Helpers

    /// Save records in batches to avoid API limits
    private func saveRecordsInBatches(_ records: [CKRecord]) async throws -> [CKRecord] {
        let batchSize = 100
        let batches = stride(from: 0, to: records.count, by: batchSize).map {
            Array(records[$0..<min($0 + batchSize, records.count)])
        }

        var savedRecords: [CKRecord] = []

        for batch in batches {
            let result = try await database.modifyRecords(saving: batch, deleting: [])
            savedRecords.append(contentsOf: result.saveResults.compactMap { try? $0.value.get() })
        }

        return savedRecords
    }
}
