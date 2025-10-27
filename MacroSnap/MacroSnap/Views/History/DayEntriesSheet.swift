//
//  DayEntriesSheet.swift
//  MacroSnap
//
//  Sheet to view and manage entries for a specific day
//

import SwiftUI
import CoreData

struct DayEntriesSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext

    let date: Date

    @State private var entries: [MacroEntryEntity] = []
    @State private var showEditEntry: MacroEntryEntity?
    @State private var showingDeleteAlert = false
    @State private var entryToDelete: MacroEntryEntity?
    @State private var isLoading = true

    private let calendar = Calendar.current

    init(date: Date) {
        self.date = date
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Apply custom background color if theme has one
                if let bgColor = appState.themeManager.currentTheme.backgroundColor {
                    bgColor.ignoresSafeArea()
                }

                if isLoading {
                    // Loading state
                    ProgressView()
                } else if entries.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)

                        Text("No entries for this day")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Summary Card
                            summaryCard

                            // Entries List
                            VStack(spacing: 12) {
                                ForEach(entries) { entry in
                                    EntryRow(entry: entry, onEdit: {
                                        showEditEntry = entry
                                    }, onDelete: {
                                        entryToDelete = entry
                                        showingDeleteAlert = true
                                    })
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(formattedDate)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                // Load entries when view appears
                loadEntries()
                isLoading = false
            }
            .sheet(item: $showEditEntry) { entry in
                EditEntrySheet(entry: entry)
                    .environmentObject(appState)
                    .environment(\.managedObjectContext, viewContext)
            }
            .onChange(of: showEditEntry) { newValue in
                // Reload entries when edit sheet is dismissed
                if newValue == nil {
                    loadEntries()
                }
            }
            .alert("Delete Entry", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    entryToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let entry = entryToDelete {
                        deleteEntry(entry)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this entry?")
            }
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        VStack(spacing: 12) {
            Text("Daily Total")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                MacroSummaryItem(label: "Protein", value: totalProtein, color: .blue)
                MacroSummaryItem(label: "Carbs", value: totalCarbs, color: .green)
                MacroSummaryItem(label: "Fat", value: totalFat, color: .yellow)
            }

            Text("\(Int(totalCalories)) calories")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }

    // MARK: - Computed Properties

    private var formattedDate: String {
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }

    private var totalProtein: Double {
        entries.reduce(0) { $0 + $1.protein }
    }

    private var totalCarbs: Double {
        entries.reduce(0) { $0 + $1.carbs }
    }

    private var totalFat: Double {
        entries.reduce(0) { $0 + $1.fat }
    }

    private var totalCalories: Double {
        (totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9)
    }

    // MARK: - Data Loading

    private func loadEntries() {
        print("🔍 Loading entries for date: \(date)")
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        print("📅 Start: \(startOfDay), End: \(endOfDay)")

        let fetchRequest: NSFetchRequest<MacroEntryEntity> = MacroEntryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                            startOfDay as NSDate,
                                            endOfDay as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MacroEntryEntity.date, ascending: false)]

        do {
            let fetchedEntries = try viewContext.fetch(fetchRequest)
            print("📱 Fetched \(fetchedEntries.count) entries for \(formattedDate)")

            // Force main thread update
            DispatchQueue.main.async {
                self.entries = fetchedEntries
                print("✅ Updated entries array with \(self.entries.count) items")
            }
        } catch {
            print("❌ Failed to load entries: \(error)")
            DispatchQueue.main.async {
                self.entries = []
            }
        }
    }

    // MARK: - Actions

    private func deleteEntry(_ entry: MacroEntryEntity) {
        // Save CloudKit record ID before deleting
        let ckRecordID = entry.ckRecordID

        withAnimation {
            viewContext.delete(entry)

            do {
                try viewContext.save()

                // Reload entries to update UI
                loadEntries()

                // Delete from CloudKit if it exists there
                Task {
                    if let recordID = ckRecordID, !recordID.isEmpty {
                        await appState.cloudKitSync.deleteEntry(recordID: recordID)
                    }

                    // Update notifications since entries changed
                    await appState.notificationManager.updateNotificationAfterEntry()
                }
            } catch {
                print("Failed to delete entry: \(error)")
            }
        }

        entryToDelete = nil
    }
}

// MARK: - Entry Row

struct EntryRow: View {
    let entry: MacroEntryEntity
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Time
            VStack(alignment: .leading, spacing: 2) {
                if let date = entry.date {
                    Text(timeString(from: date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Macros
            HStack(spacing: 8) {
                MacroChip(label: "P", value: Int(entry.protein), color: .blue)
                MacroChip(label: "C", value: Int(entry.carbs), color: .green)
                MacroChip(label: "F", value: Int(entry.fat), color: .yellow)
            }

            // Actions Menu
            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }

                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.05))
        )
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Macro Summary Item

struct MacroSummaryItem: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Int(value))g")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Macro Chip

struct MacroChip: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text("\(value)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Edit Entry Sheet

struct EditEntrySheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var storeManager = StoreManager.shared

    @ObservedObject var entry: MacroEntryEntity

    @State private var proteinText: String
    @State private var carbsText: String
    @State private var fatText: String
    @State private var notesText: String
    @State private var showingAlert = false
    @State private var alertMessage = ""

    init(entry: MacroEntryEntity) {
        self.entry = entry
        _proteinText = State(initialValue: String(Int(entry.protein)))
        _carbsText = State(initialValue: String(Int(entry.carbs)))
        _fatText = State(initialValue: String(Int(entry.fat)))
        _notesText = State(initialValue: entry.notes ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Macros") {
                    HStack {
                        Text("Protein")
                            .foregroundColor(.blue)
                        Spacer()
                        TextField("0", text: $proteinText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Carbs")
                            .foregroundColor(.green)
                        Spacer()
                        TextField("0", text: $carbsText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Fat")
                            .foregroundColor(.yellow)
                        Spacer()
                        TextField("0", text: $fatText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                }

                if storeManager.isPro {
                    Section("Notes") {
                        TextField("Meal name or notes", text: $notesText)
                            .onChange(of: notesText) { newValue in
                                if newValue.count > 100 {
                                    notesText = String(newValue.prefix(100))
                                }
                            }

                        Text("\(notesText.count)/100")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func saveChanges() {
        guard let protein = Double(proteinText), protein >= 0 else {
            alertMessage = "Please enter a valid protein amount"
            showingAlert = true
            return
        }

        guard let carbs = Double(carbsText), carbs >= 0 else {
            alertMessage = "Please enter a valid carbs amount"
            showingAlert = true
            return
        }

        guard let fat = Double(fatText), fat >= 0 else {
            alertMessage = "Please enter a valid fat amount"
            showingAlert = true
            return
        }

        guard protein > 0 || carbs > 0 || fat > 0 else {
            alertMessage = "Please enter at least one macro amount"
            showingAlert = true
            return
        }

        // Update entry
        entry.protein = protein
        entry.carbs = carbs
        entry.fat = fat
        if storeManager.isPro {
            entry.notes = notesText.isEmpty ? nil : notesText
        }
        entry.updatedAt = Date()

        // Clear CloudKit record ID so it gets re-uploaded on next sync
        entry.ckRecordID = nil

        do {
            try viewContext.save()

            // Trigger CloudKit sync to upload the updated entry
            Task {
                await appState.cloudKitSync.syncLocalToCloud()
            }

            dismiss()

            // Note: Parent view will reload entries automatically via onChange
        } catch {
            alertMessage = "Failed to save changes: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

