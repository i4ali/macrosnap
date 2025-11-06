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

    // Barcode scanner states
    @State private var showBarcodeScanner = false
    @State private var scannedProduct: FoodProduct?
    @State private var isLoadingProduct = false
    @StateObject private var foodDatabase = FoodDatabaseService.shared

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

                // MARK: - Notes Field (Free Feature as of v1.1)
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
            }
            .padding(.horizontal)

            // MARK: - Scanned Product Indicator
            if let product = scannedProduct {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.subheadline)

                    Text("Found: \(product.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Spacer()

                    Button(action: {
                        clearScannedProduct()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }

            // MARK: - Barcode Scanner Button
            Button(action: {
                showBarcodeScanner = true
            }) {
                HStack(spacing: 8) {
                    if isLoadingProduct {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "barcode.viewfinder")
                    }

                    Text(scannedProduct == nil ? "Scan Barcode" : "Scan Different Item")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isLoadingProduct)
            .padding(.horizontal)
            .padding(.bottom, 16)

            // MARK: - Preset Buttons (Free Feature as of v1.1 - limited to 2 for free users)
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
                        // Check preset limit for free users
                        let presetCheck = storeManager.canCreatePreset(context: viewContext)
                        if presetCheck.canCreate {
                            showSavePreset = true
                        } else {
                            // Show upgrade prompt for free users who hit the limit
                            alertMessage = presetCheck.message ?? "Cannot create preset"
                            showingAlert = true
                        }
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
        .sheet(isPresented: $showBarcodeScanner) {
            BarcodeScannerView { barcode in
                handleBarcodeScanned(barcode)
            }
        }
        .overlay(
            Group {
                if isLoadingProduct {
                    loadingOverlay
                }
            }
        )
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

        // Create new entry (with notes if provided)
        let entry = MacroEntry(
            date: Date(),
            protein: protein,
            carbs: carbs,
            fat: fat,
            notes: !notesText.isEmpty ? notesText : nil
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

    // MARK: - Barcode Scanner Actions

    private func handleBarcodeScanned(_ barcode: String) {
        showBarcodeScanner = false
        isLoadingProduct = true

        Task {
            do {
                let product = try await foodDatabase.lookupByBarcode(barcode)
                await MainActor.run {
                    scannedProduct = product
                    autoFillFromProduct(product)
                    isLoadingProduct = false

                    // Provide haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            } catch {
                await MainActor.run {
                    isLoadingProduct = false
                    handleProductLookupError(error)
                }
            }
        }
    }

    private func autoFillFromProduct(_ product: FoodProduct) {
        // Fill in macro values
        proteinText = String(Int(product.protein.rounded()))
        carbsText = String(Int(product.carbs.rounded()))
        fatText = String(Int(product.fat.rounded()))

        // Fill in notes with product name (if field is empty)
        if notesText.isEmpty {
            notesText = product.displayName
        }
    }

    private func clearScannedProduct() {
        withAnimation {
            scannedProduct = nil
        }
    }

    private func handleProductLookupError(_ error: Error) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)

        if let dbError = error as? FoodDatabaseError {
            alertMessage = dbError.errorDescription ?? "Failed to lookup product"
        } else {
            alertMessage = "Failed to lookup product: \(error.localizedDescription)"
        }
        showingAlert = true
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)

                Text("Looking up product...")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
        }
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
    @StateObject private var storeManager = StoreManager.shared

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

        // Check preset limit for free users
        let presetCheck = storeManager.canCreatePreset(context: viewContext)
        if !presetCheck.canCreate {
            alertMessage = presetCheck.message ?? "Cannot create preset"
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

// MARK: - Preview
struct QuickLogSheet_Previews: PreviewProvider {
    static var previews: some View {
        QuickLogSheet()
            .environmentObject(AppState())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
