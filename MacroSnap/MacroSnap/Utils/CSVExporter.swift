//
//  CSVExporter.swift
//  MacroSnap
//
//  Generates CSV files from macro entry data
//

import Foundation
import CoreData

class CSVExporter {
    static let shared = CSVExporter()

    private init() {}

    /// Generate CSV file from macro entries
    func generateCSV(from entries: [MacroEntryEntity]) -> URL? {
        // Create CSV content
        var csvContent = "Date,Protein (g),Carbs (g),Fat (g),Calories,Notes\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        // Sort entries by date descending
        let sortedEntries = entries.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }

        for entry in sortedEntries {
            let date = dateFormatter.string(from: entry.date ?? Date())
            let protein = String(format: "%.1f", entry.protein)
            let carbs = String(format: "%.1f", entry.carbs)
            let fat = String(format: "%.1f", entry.fat)
            let calories = Int((entry.protein * 4) + (entry.carbs * 4) + (entry.fat * 9))
            let notes = cleanCSVValue(entry.notes ?? "")

            csvContent += "\(date),\(protein),\(carbs),\(fat),\(calories),\"\(notes)\"\n"
        }

        // Save to temporary file
        let fileName = "MacroSnap_Export_\(Date().timeIntervalSince1970).csv"
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)

        do {
            // Write file atomically and ensure it's accessible
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)

            // Verify file was created successfully
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                print("❌ CSV file was not created at path: \(fileURL.path)")
                return nil
            }

            print("✅ CSV file created successfully at: \(fileURL.path)")
            return fileURL
        } catch {
            print("❌ Failed to write CSV file: \(error)")
            return nil
        }
    }

    /// Clean CSV values to escape quotes and commas
    private func cleanCSVValue(_ value: String) -> String {
        return value.replacingOccurrences(of: "\"", with: "\"\"")
    }
}
