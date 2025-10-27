//
//  CloudKitConfig.swift
//  MacroSnap
//
//  CloudKit container configuration and record types
//

import Foundation
import CloudKit

struct CloudKitConfig {
    // MARK: - Container

    /// CloudKit container identifier
    static let containerIdentifier = "iCloud.MAHR.Partners.MacroSnap"

    /// Shared CloudKit container instance
    static let container = CKContainer(identifier: containerIdentifier)

    /// Private database (user's personal data)
    static var privateDatabase: CKDatabase {
        container.privateCloudDatabase
    }

    // MARK: - Record Types

    enum RecordType: String {
        case macroEntry = "MacroEntry"
        case goal = "Goal"
        case preset = "Preset"
        case userPreferences = "UserPreferences"
    }

    // MARK: - Zone

    /// Custom zone for organizing records
    static let customZoneName = "MacroSnapZone"
    static let customZone = CKRecordZone(zoneName: customZoneName)

    // MARK: - Subscription

    /// Subscription ID for database changes
    static let subscriptionID = "macrosnap-changes"
}

// MARK: - Record Field Names

extension CloudKitConfig {
    enum MacroEntryFields {
        static let date = "date"
        static let protein = "protein"
        static let carbs = "carbs"
        static let fat = "fat"
        static let notes = "notes"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }

    enum GoalFields {
        static let proteinGoal = "proteinGoal"
        static let carbGoal = "carbGoal"
        static let fatGoal = "fatGoal"
        static let dayOfWeek = "dayOfWeek" // -1 for default, 0-6 for specific days
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }

    enum PresetFields {
        static let name = "name"
        static let protein = "protein"
        static let carbs = "carbs"
        static let fat = "fat"
        static let createdAt = "createdAt"
    }

    enum UserPreferencesFields {
        static let theme = "theme"
        static let isPro = "isPro"
        static let updatedAt = "updatedAt"
    }
}
