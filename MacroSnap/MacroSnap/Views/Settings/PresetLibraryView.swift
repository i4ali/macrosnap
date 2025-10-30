//
//  PresetLibraryView.swift
//  MacroSnap
//
//  Preset library for managing saved macro presets (Pro feature)
//

import SwiftUI
import CoreData

struct PresetLibraryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appState: AppState
    @StateObject private var storeManager = StoreManager.shared

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PresetEntity.name, ascending: true)],
        animation: .default
    )
    private var presets: FetchedResults<PresetEntity>

    @State private var showingAddPreset = false
    @State private var showingEditPreset = false
    @State private var selectedPreset: PresetEntity?
    @State private var showingDeleteAlert = false
    @State private var presetToDelete: PresetEntity?
    @State private var showingLimitAlert = false

    // Optional: callback when preset is selected (for Quick Log)
    var onPresetSelected: ((MacroPreset) -> Void)?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Preset Counter (for free users)
                if !storeManager.isPro && !presets.isEmpty {
                    HStack {
                        Text("\(presets.count) of 2 presets")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        if presets.count >= 2 {
                            Text("Upgrade for unlimited")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                }

                Group {
                    if presets.isEmpty {
                        emptyState
                    } else {
                        presetList
                    }
                }
            }
            .navigationTitle("Macro Presets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Check preset limit before showing add sheet
                        let presetCheck = storeManager.canCreatePreset(context: viewContext)
                        if presetCheck.canCreate {
                            showingAddPreset = true
                        } else {
                            showingLimitAlert = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPreset) {
                AddPresetView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(appState)
            }
            .sheet(item: $selectedPreset) { preset in
                EditPresetView(preset: preset)
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(appState)
            }
            .alert("Delete Preset?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let preset = presetToDelete {
                        deletePreset(preset)
                    }
                }
            } message: {
                Text("This preset will be permanently deleted.")
            }
            .alert("Preset Limit Reached", isPresented: $showingLimitAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Free users can save up to 2 presets. Upgrade to Pro for unlimited presets.")
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Presets Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Save your favorite meals as presets for quick logging")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                // Check preset limit before showing add sheet
                let presetCheck = storeManager.canCreatePreset(context: viewContext)
                if presetCheck.canCreate {
                    showingAddPreset = true
                } else {
                    showingLimitAlert = true
                }
            }) {
                Label("Create Preset", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
    }

    // MARK: - Preset List

    private var presetList: some View {
        List {
            ForEach(presets) { preset in
                PresetRow(preset: preset)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let callback = onPresetSelected {
                            // Use preset in Quick Log
                            callback(preset.toDomain())
                            dismiss()
                        } else {
                            // Edit preset
                            selectedPreset = preset
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            presetToDelete = preset
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            selectedPreset = preset
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Actions

    private func deletePreset(_ preset: PresetEntity) {
        // Delete from CloudKit first (if it has a record ID)
        if let ckRecordID = preset.ckRecordID {
            Task {
                await appState.cloudKitSync.deletePreset(recordID: ckRecordID)
            }
        }

        // Then delete from local CoreData
        viewContext.delete(preset)

        do {
            try viewContext.save()
        } catch {
            print("Failed to delete preset: \(error)")
        }
    }
}

// MARK: - Preset Row

struct PresetRow: View {
    @ObservedObject var preset: PresetEntity

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "fork.knife")
                        .foregroundColor(.white)
                        .font(.caption)
                )

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(preset.name ?? "Unnamed")
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(spacing: 8) {
                    MacroTag(label: "P", value: Int(preset.protein), color: .blue)
                    MacroTag(label: "C", value: Int(preset.carbs), color: .green)
                    MacroTag(label: "F", value: Int(preset.fat), color: .orange)
                }
            }

            Spacer()

            // Calories
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(preset.toDomain().totalCalories))")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("cal")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct MacroTag: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text("\(value)g")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Add Preset View

struct AddPresetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appState: AppState

    @State private var name = ""
    @State private var proteinText = ""
    @State private var carbsText = ""
    @State private var fatText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Preset Name") {
                    TextField("e.g., Chicken & Rice", text: $name)
                }

                Section("Macros") {
                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("0", text: $proteinText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("0", text: $carbsText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Fat")
                        Spacer()
                        TextField("0", text: $fatText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("New Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePreset()
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

    private func savePreset() {
        guard !name.isEmpty else {
            alertMessage = "Please enter a preset name"
            showingAlert = true
            return
        }

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

        let preset = PresetEntity(
            context: viewContext,
            name: name,
            protein: protein,
            carbs: carbs,
            fat: fat
        )

        do {
            try viewContext.save()

            // Trigger CloudKit sync
            Task {
                await appState.cloudKitSync.performFullSync()
            }

            dismiss()
        } catch {
            alertMessage = "Failed to save preset: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - Edit Preset View

struct EditPresetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appState: AppState

    let preset: PresetEntity

    @State private var name = ""
    @State private var proteinText = ""
    @State private var carbsText = ""
    @State private var fatText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Preset Name") {
                    TextField("e.g., Chicken & Rice", text: $name)
                }

                Section("Macros") {
                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("0", text: $proteinText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("0", text: $carbsText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Fat")
                        Spacer()
                        TextField("0", text: $fatText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        updatePreset()
                    }
                }
            }
            .onAppear {
                loadPresetData()
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func loadPresetData() {
        name = preset.name ?? ""
        proteinText = String(Int(preset.protein))
        carbsText = String(Int(preset.carbs))
        fatText = String(Int(preset.fat))
    }

    private func updatePreset() {
        guard !name.isEmpty else {
            alertMessage = "Please enter a preset name"
            showingAlert = true
            return
        }

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

        preset.name = name
        preset.protein = protein
        preset.carbs = carbs
        preset.fat = fat
        preset.updatedAt = Date()

        do {
            try viewContext.save()

            // Trigger CloudKit sync
            Task {
                await appState.cloudKitSync.performFullSync()
            }

            dismiss()
        } catch {
            alertMessage = "Failed to update preset: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - Preview
struct PresetLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        PresetLibraryView()
            .environmentObject(AppState())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
