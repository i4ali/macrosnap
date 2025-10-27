//
//  QuickLogSheet.swift
//  MacroSnap
//
//  Quick log modal sheet for adding macro entries (Screen 2)
//

import SwiftUI
import CoreData

enum MacroField {
    case protein, carbs, fat
}

struct QuickLogSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var storeManager = StoreManager.shared

    // Input values
    @State private var proteinText = ""
    @State private var carbsText = ""
    @State private var fatText = ""
    @State private var notesText = ""

    // Focus management
    @State private var focusedField: MacroField = .protein

    // UI states
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showProUpgrade = false
    @State private var showPresetLibrary = false
    @State private var showSavePreset = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header with Drag Handle
            VStack(spacing: 12) {
                // Drag handle
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)

                // Title and Done button
                HStack {
                    Text("Log Macros")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button(action: handleDone) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)

            // MARK: - Macro Input Fields
            VStack(spacing: 16) {
                MacroInputField(
                    label: "Protein",
                    value: $proteinText,
                    color: .blue,
                    isFocused: focusedField == .protein,
                    onTap: { focusedField = .protein }
                )

                MacroInputField(
                    label: "Carbs",
                    value: $carbsText,
                    color: .green,
                    isFocused: focusedField == .carbs,
                    onTap: { focusedField = .carbs }
                )

                MacroInputField(
                    label: "Fat",
                    value: $fatText,
                    color: .yellow,
                    isFocused: focusedField == .fat,
                    onTap: { focusedField = .fat }
                )

                // MARK: - Notes Field (Pro Feature)
                if storeManager.isPro {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("Notes (Optional)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text("\(notesText.count)/100")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        TextField("Meal name or notes", text: $notesText)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: notesText) { newValue in
                                // Limit to 100 characters
                                if newValue.count > 100 {
                                    notesText = String(newValue.prefix(100))
                                }
                            }
                    }
                } else {
                    // Pro Upgrade prompt for notes
                    Button(action: {
                        showProUpgrade = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "note.text")
                                .foregroundColor(.orange)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Add Notes")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text("Pro feature")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)

            // MARK: - Preset Buttons (Pro Feature)
            if storeManager.isPro {
                HStack(spacing: 12) {
                    // Load Preset
                    Button(action: {
                        showPresetLibrary = true
                    }) {
                        HStack {
                            Image(systemName: "square.stack.3d.up")
                            Text("Load Preset")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }

                    // Save Preset
                    Button(action: {
                        if canSavePreset {
                            showSavePreset = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus.square")
                            Text("Save Preset")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(canSavePreset ? .green : .secondary)
                        .cornerRadius(8)
                    }
                    .disabled(!canSavePreset)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }

            // MARK: - Custom Numeric Keypad
            CustomNumericKeypad { key in
                handleKeypadInput(key)
            }
            .padding(.horizontal)

            Spacer()
        }
        .sheet(isPresented: $showProUpgrade) {
            ProUpgradeView()
        }
        .sheet(isPresented: $showPresetLibrary) {
            PresetLibraryView(onPresetSelected: loadPreset)
                .environmentObject(appState)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showSavePreset) {
            SavePresetFromLogView(
                protein: Double(proteinText) ?? 0,
                carbs: Double(carbsText) ?? 0,
                fat: Double(fatText) ?? 0
            )
            .environmentObject(appState)
            .environment(\.managedObjectContext, viewContext)
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Computed Properties

    private var canSavePreset: Bool {
        guard let protein = Double(proteinText), protein > 0 else { return false }
        guard let carbs = Double(carbsText), carbs > 0 else { return false }
        guard let fat = Double(fatText), fat > 0 else { return false }
        return true
    }

    // MARK: - Actions

    private func handleKeypadInput(_ key: String) {
        let currentText: Binding<String>
        switch focusedField {
        case .protein:
            currentText = $proteinText
        case .carbs:
            currentText = $carbsText
        case .fat:
            currentText = $fatText
        }

        if key == "backspace" {
            if !currentText.wrappedValue.isEmpty {
                currentText.wrappedValue.removeLast()
            }
        } else if key == "." {
            // Only add decimal if not already present
            if !currentText.wrappedValue.contains(".") {
                currentText.wrappedValue += key
            }
        } else {
            // Add digit
            currentText.wrappedValue += key
        }
    }

    private func handleDone() {
        // Validate inputs
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

        // Ensure at least one macro is entered
        guard protein > 0 || carbs > 0 || fat > 0 else {
            alertMessage = "Please enter at least one macro amount"
            showingAlert = true
            return
        }

        // Create new entry (with notes if Pro user)
        let entry = MacroEntry(
            date: Date(),
            protein: protein,
            carbs: carbs,
            fat: fat,
            notes: storeManager.isPro && !notesText.isEmpty ? notesText : nil
        )

        // Save to CoreData
        saveEntry(entry)

        // Trigger CloudKit sync and update notifications
        Task {
            await appState.cloudKitSync.performFullSync()
            await appState.notificationManager.updateNotificationAfterEntry()
        }

        dismiss()
    }

    private func loadPreset(_ preset: MacroPreset) {
        proteinText = String(Int(preset.protein))
        carbsText = String(Int(preset.carbs))
        fatText = String(Int(preset.fat))
    }

    private func saveEntry(_ entry: MacroEntry) {
        let entity = MacroEntryEntity(
            context: viewContext,
            date: entry.date,
            protein: entry.protein,
            carbs: entry.carbs,
            fat: entry.fat,
            notes: entry.notes
        )

        do {
            try viewContext.save()
        } catch {
            alertMessage = "Failed to save entry: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - Macro Input Field

struct MacroInputField: View {
    let label: String
    @Binding var value: String
    let color: Color
    let isFocused: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Label with icon
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)

                Text(label)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(width: 80, alignment: .leading)

            // Input field
            Button(action: onTap) {
                HStack {
                    Text(value.isEmpty ? "0" : value)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(value.isEmpty ? .secondary : .primary)

                    Spacer()

                    Text("g")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isFocused ? color.opacity(0.1) : Color.gray.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isFocused ? color : Color.clear, lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Custom Numeric Keypad

struct CustomNumericKeypad: View {
    let onKeyPress: (String) -> Void

    private let keys: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "backspace"]
    ]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        KeypadButton(key: key, onPress: onKeyPress)
                    }
                }
            }
        }
    }
}

struct KeypadButton: View {
    let key: String
    let onPress: (String) -> Void

    var body: some View {
        Button(action: { onPress(key) }) {
            Group {
                if key == "backspace" {
                    Image(systemName: "delete.left.fill")
                        .font(.title3)
                } else {
                    Text(key)
                        .font(.title2)
                        .fontWeight(.medium)
                }
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Save Preset From Log View

struct SavePresetFromLogView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appState: AppState

    let protein: Double
    let carbs: Double
    let fat: Double

    @State private var name = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Preset Name") {
                    TextField("e.g., Chicken & Rice", text: $name)
                        .autocorrectionDisabled()
                }

                Section("Macros (from current entry)") {
                    HStack {
                        Text("Protein")
                        Spacer()
                        Text("\(Int(protein))g")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Carbs")
                        Spacer()
                        Text("\(Int(carbs))g")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Fat")
                        Spacer()
                        Text("\(Int(fat))g")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Save as Preset")
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
                    .disabled(name.isEmpty)
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
        guard !name.isEmpty else { return }

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

// MARK: - Preview
struct QuickLogSheet_Previews: PreviewProvider {
    static var previews: some View {
        QuickLogSheet()
            .environmentObject(AppState())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
