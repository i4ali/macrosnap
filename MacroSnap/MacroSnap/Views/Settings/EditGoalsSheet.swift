//
//  EditGoalsSheet.swift
//  MacroSnap
//
//  Modal sheet for editing daily macro goals
//

import SwiftUI
import CoreData

struct EditGoalsSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext

    // Initial goals passed in
    let initialProtein: Double
    let initialCarbs: Double
    let initialFat: Double

    // Input values
    @State private var proteinText = ""
    @State private var carbsText = ""
    @State private var fatText = ""

    // Focus management
    @State private var focusedField: MacroField = .protein

    // UI states
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header with Drag Handle
            VStack(spacing: 12) {
                // Drag handle
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)

                // Title and buttons
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.body)
                    .foregroundColor(.secondary)

                    Spacer()

                    Text("Edit Goals")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button(action: handleSave) {
                        Text("Save")
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

            // MARK: - Goal Input Fields
            VStack(spacing: 16) {
                GoalInputField(
                    label: "Protein",
                    value: $proteinText,
                    color: .blue,
                    isFocused: focusedField == .protein,
                    onTap: { focusedField = .protein }
                )

                GoalInputField(
                    label: "Carbs",
                    value: $carbsText,
                    color: .green,
                    isFocused: focusedField == .carbs,
                    onTap: { focusedField = .carbs }
                )

                GoalInputField(
                    label: "Fat",
                    value: $fatText,
                    color: .yellow,
                    isFocused: focusedField == .fat,
                    onTap: { focusedField = .fat }
                )
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
        .onAppear {
            // Pre-populate with current goals
            proteinText = String(Int(initialProtein))
            carbsText = String(Int(initialCarbs))
            fatText = String(Int(initialFat))
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
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

    private func handleSave() {
        // Validate inputs
        guard let protein = Double(proteinText), protein > 0 else {
            alertTitle = "Invalid Input"
            alertMessage = "Please enter a valid protein goal"
            showingAlert = true
            return
        }

        guard let carbs = Double(carbsText), carbs > 0 else {
            alertTitle = "Invalid Input"
            alertMessage = "Please enter a valid carbs goal"
            showingAlert = true
            return
        }

        guard let fat = Double(fatText), fat > 0 else {
            alertTitle = "Invalid Input"
            alertMessage = "Please enter a valid fat goal"
            showingAlert = true
            return
        }

        // Create goal entity
        let goal = MacroGoal(
            proteinGoal: protein,
            carbGoal: carbs,
            fatGoal: fat
        )

        // Save to CoreData
        saveGoalToDatabase(goal)

        // Dismiss sheet
        dismiss()
    }

    private func saveGoalToDatabase(_ goal: MacroGoal) {
        // Fetch or create default goal
        let fetchRequest: NSFetchRequest<GoalEntity> = GoalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dayOfWeek == -1") // Default goal
        fetchRequest.fetchLimit = 1

        do {
            let results = try viewContext.fetch(fetchRequest)

            if let existingGoal = results.first {
                // Update existing goal
                existingGoal.proteinGoal = goal.proteinGoal
                existingGoal.carbGoal = goal.carbGoal
                existingGoal.fatGoal = goal.fatGoal
                existingGoal.updatedAt = Date()
                // Clear CloudKit data to force fresh upload
                existingGoal.ckRecordID = nil
                existingGoal.ckSystemFields = nil
            } else {
                // Create new goal
                let newGoal = GoalEntity(context: viewContext)
                newGoal.id = UUID()
                newGoal.proteinGoal = goal.proteinGoal
                newGoal.carbGoal = goal.carbGoal
                newGoal.fatGoal = goal.fatGoal
                newGoal.dayOfWeek = -1 // Default goal
                newGoal.createdAt = Date()
                newGoal.updatedAt = Date()
            }

            try viewContext.save()

            // Notify AppState that goals changed so UI refreshes
            appState.notifyGoalsChanged()

            // Upload to CloudKit
            Task {
                await appState.cloudKitSync.syncLocalToCloud()
            }

        } catch {
            alertTitle = "Error"
            alertMessage = "Failed to save goals: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - Goal Input Field

struct GoalInputField: View {
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

// MARK: - Preview
struct EditGoalsSheet_Previews: PreviewProvider {
    static var previews: some View {
        EditGoalsSheet(
            initialProtein: 180,
            initialCarbs: 250,
            initialFat: 70
        )
        .environmentObject(AppState())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
