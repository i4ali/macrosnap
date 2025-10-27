//
//  CustomDailyGoalsView.swift
//  MacroSnap
//
//  Pro Feature: Set different goals for each day of the week
//

import SwiftUI
import CoreData

struct CustomDailyGoalsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appState: AppState

    // Selected day (0 = Monday, 6 = Sunday, -1 = Default)
    @State private var selectedDay: Int = -1

    // Goal inputs
    @State private var proteinGoal = ""
    @State private var carbsGoal = ""
    @State private var fatGoal = ""

    // UI states
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    // Fetch all goals
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GoalEntity.dayOfWeek, ascending: true)],
        animation: .default
    )
    private var allGoals: FetchedResults<GoalEntity>

    private let daysOfWeek = [
        "Default",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday"
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Day Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(-1..<7, id: \.self) { day in
                            DayButton(
                                title: dayTitle(for: day),
                                isSelected: selectedDay == day,
                                hasCustomGoal: hasGoal(for: day)
                            ) {
                                selectedDay = day
                                loadGoals(for: day)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                }
                .background(Color(.systemGroupedBackground))

                // MARK: - Goals Editor
                Form {
                    Section {
                        HStack {
                            Label("Protein", systemImage: "circle.fill")
                                .foregroundColor(.blue)

                            Spacer()

                            TextField("180", text: $proteinGoal)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)

                            Text("g")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Label("Carbs", systemImage: "circle.fill")
                                .foregroundColor(.green)

                            Spacer()

                            TextField("250", text: $carbsGoal)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)

                            Text("g")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Label("Fat", systemImage: "circle.fill")
                                .foregroundColor(.yellow)

                            Spacer()

                            TextField("70", text: $fatGoal)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)

                            Text("g")
                                .foregroundColor(.secondary)
                        }
                    } header: {
                        Text(selectedDay == -1 ? "Default Goals" : "\(dayTitle(for: selectedDay)) Goals")
                    } footer: {
                        if selectedDay == -1 {
                            Text("These goals are used when no specific day is set.")
                        } else {
                            Text("Custom goals for \(dayTitle(for: selectedDay)).")
                        }
                    }

                    Section {
                        Button(action: saveGoals) {
                            HStack {
                                Spacer()
                                Text("Save Goals")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }

                        if selectedDay != -1 && hasGoal(for: selectedDay) {
                            Button(role: .destructive, action: deleteGoals) {
                                HStack {
                                    Spacer()
                                    Text("Use Default Goals")
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Custom Daily Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadGoals(for: selectedDay)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Helpers

    private func dayTitle(for day: Int) -> String {
        if day == -1 {
            return "Default"
        }
        return daysOfWeek[day + 1]
    }

    private func hasGoal(for day: Int) -> Bool {
        return allGoals.contains { $0.dayOfWeek == Int16(day) }
    }

    private func getGoal(for day: Int) -> GoalEntity? {
        return allGoals.first { $0.dayOfWeek == Int16(day) }
    }

    private func loadGoals(for day: Int) {
        if let goal = getGoal(for: day) {
            proteinGoal = String(Int(goal.proteinGoal))
            carbsGoal = String(Int(goal.carbGoal))
            fatGoal = String(Int(goal.fatGoal))
        } else if day == -1 {
            // Load default goal
            let defaultGoal = appState.getCurrentGoal()
            proteinGoal = String(Int(defaultGoal.proteinGoal))
            carbsGoal = String(Int(defaultGoal.carbGoal))
            fatGoal = String(Int(defaultGoal.fatGoal))
        } else {
            // Use default goal as template
            let defaultGoal = appState.getCurrentGoal()
            proteinGoal = String(Int(defaultGoal.proteinGoal))
            carbsGoal = String(Int(defaultGoal.carbGoal))
            fatGoal = String(Int(defaultGoal.fatGoal))
        }
    }

    // MARK: - Actions

    private func saveGoals() {
        // Validate inputs
        guard let protein = Double(proteinGoal), protein > 0 else {
            alertTitle = "Invalid Input"
            alertMessage = "Please enter a valid protein goal"
            showingAlert = true
            return
        }

        guard let carbs = Double(carbsGoal), carbs > 0 else {
            alertTitle = "Invalid Input"
            alertMessage = "Please enter a valid carbs goal"
            showingAlert = true
            return
        }

        guard let fat = Double(fatGoal), fat > 0 else {
            alertTitle = "Invalid Input"
            alertMessage = "Please enter a valid fat goal"
            showingAlert = true
            return
        }

        // Save to CoreData
        if let existingGoal = getGoal(for: selectedDay) {
            // Update existing
            existingGoal.proteinGoal = protein
            existingGoal.carbGoal = carbs
            existingGoal.fatGoal = fat
            existingGoal.updatedAt = Date()
        } else {
            // Create new
            let newGoal = GoalEntity(context: viewContext)
            newGoal.id = UUID()
            newGoal.proteinGoal = protein
            newGoal.carbGoal = carbs
            newGoal.fatGoal = fat
            newGoal.dayOfWeek = Int16(selectedDay)
            newGoal.createdAt = Date()
            newGoal.updatedAt = Date()
        }

        do {
            try viewContext.save()

            // Trigger CloudKit sync
            Task {
                await appState.cloudKitSync.performFullSync()
            }

            alertTitle = "Success"
            alertMessage = "Goals saved successfully"
            showingAlert = true
        } catch {
            alertTitle = "Error"
            alertMessage = "Failed to save goals: \(error.localizedDescription)"
            showingAlert = true
        }
    }

    private func deleteGoals() {
        guard let goal = getGoal(for: selectedDay) else { return }

        // Delete from CloudKit first (if it has a record ID)
        if let ckRecordID = goal.ckRecordID {
            Task {
                await appState.cloudKitSync.deleteGoal(recordID: ckRecordID)
            }
        }

        // Then delete from local CoreData
        viewContext.delete(goal)

        do {
            try viewContext.save()

            // Reload default goals
            loadGoals(for: selectedDay)

            alertTitle = "Success"
            alertMessage = "Custom goals removed. Using default goals."
            showingAlert = true
        } catch {
            alertTitle = "Error"
            alertMessage = "Failed to delete goals: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - Day Button Component

struct DayButton: View {
    let title: String
    let isSelected: Bool
    let hasCustomGoal: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .primary)

                if hasCustomGoal && !isSelected {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 4, height: 4)
                } else if hasCustomGoal && isSelected {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 4, height: 4)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 4, height: 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

struct CustomDailyGoalsView_Previews: PreviewProvider {
    static var previews: some View {
        CustomDailyGoalsView()
            .environmentObject(AppState())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
