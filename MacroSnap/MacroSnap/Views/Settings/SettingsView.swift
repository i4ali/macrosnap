//
//  SettingsView.swift
//  MacroSnap
//
//  Settings screen - Goals, preferences, and sync (Screen 4)
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var storeManager = StoreManager.shared

    // Goal inputs
    @State private var proteinGoal = ""
    @State private var carbsGoal = ""
    @State private var fatGoal = ""

    // UI states
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isEditing = false
    @State private var showProUpgrade = false
    @State private var showThemePicker = false
    @State private var showCustomGoals = false

    var body: some View {
        NavigationView {
            ZStack {
                // Apply custom background color if theme has one
                if let bgColor = appState.themeManager.currentTheme.backgroundColor {
                    bgColor.ignoresSafeArea()
                }

                List {
                    // MARK: - Pro Section
                Section {
                    if storeManager.isPro {
                        // Pro Badge - User has Pro
                        HStack(spacing: 12) {
                            Image(systemName: "star.circle.fill")
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("MacroSnap Pro")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text("All features unlocked")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 4)
                    } else {
                        // Upgrade to Pro Button
                        Button(action: {
                            print("🔵 Upgrade to Pro button tapped")
                            showProUpgrade = true
                            print("🔵 showProUpgrade set to: \(showProUpgrade)")
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "star.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Upgrade to Pro")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text("Unlock all premium features")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderless)
                    }
                } header: {
                    Text(storeManager.isPro ? "Subscription" : "Pro Features")
                } footer: {
                    if !storeManager.isPro {
                        Text("Get unlimited history, notes, presets, themes, and more with a one-time purchase.")
                    }
                }

                // MARK: - Pro Features List (for Pro users)
                if storeManager.isPro {
                    Section {
                        DisclosureGroup {
                            ProFeatureRow(
                                icon: "calendar",
                                title: "Unlimited History",
                                description: "Access all your past macro entries"
                            )

                            ProFeatureRow(
                                icon: "note.text",
                                title: "Notes & Meal Names",
                                description: "Add context to your entries"
                            )

                            ProFeatureRow(
                                icon: "square.stack.3d.up",
                                title: "Macro Presets",
                                description: "Save & reuse favorite meals"
                            )

                            ProFeatureRow(
                                icon: "paintpalette",
                                title: "Custom Themes",
                                description: "5 beautiful color schemes"
                            )

                            ProFeatureRow(
                                icon: "calendar.badge.clock",
                                title: "Custom Daily Goals",
                                description: "Different goals per day"
                            )

                            ProFeatureRow(
                                icon: "chart.bar",
                                title: "Advanced Analytics",
                                description: "Week & month view charts"
                            )

                            ProFeatureRow(
                                icon: "square.and.arrow.up",
                                title: "Export Data",
                                description: "Download your data as CSV"
                            )
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text("View Unlocked Features")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }

                // MARK: - Daily Goals Section
                Section {
                    HStack {
                        Text("Daily Goals")
                            .font(.headline)

                        Spacer()

                        if isEditing {
                            Button("Cancel") {
                                loadCurrentGoals()
                                isEditing = false
                            }
                            .font(.subheadline)

                            Button("Save") {
                                saveGoals()
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        } else {
                            Button("Edit") {
                                isEditing = true
                            }
                            .font(.subheadline)
                        }
                    }

                    // Protein Goal
                    HStack {
                        Label("Protein", systemImage: "circle.fill")
                            .foregroundColor(.blue)

                        Spacer()

                        if isEditing {
                            TextField("180", text: $proteinGoal)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        } else {
                            Text("\(Int(appState.getCurrentGoal().proteinGoal))")
                        }

                        Text("g")
                            .foregroundColor(.secondary)
                    }

                    // Carbs Goal
                    HStack {
                        Label("Carbs", systemImage: "circle.fill")
                            .foregroundColor(.green)

                        Spacer()

                        if isEditing {
                            TextField("250", text: $carbsGoal)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        } else {
                            Text("\(Int(appState.getCurrentGoal().carbGoal))")
                        }

                        Text("g")
                            .foregroundColor(.secondary)
                    }

                    // Fat Goal
                    HStack {
                        Label("Fat", systemImage: "circle.fill")
                            .foregroundColor(.yellow)

                        Spacer()

                        if isEditing {
                            TextField("70", text: $fatGoal)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        } else {
                            Text("\(Int(appState.getCurrentGoal().fatGoal))")
                        }

                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    // Custom Goals (Pro Feature)
                    if storeManager.isPro {
                        Button(action: {
                            showCustomGoals = true
                        }) {
                            HStack {
                                Label("Custom Daily Goals", systemImage: "calendar.badge.clock")
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Goals")
                } footer: {
                    if storeManager.isPro {
                        Text("Set different goals for each day of the week with Custom Daily Goals.")
                    } else {
                        Text("Set your daily macro targets. These will be used to calculate your progress.")
                    }
                }

                // MARK: - Appearance Section
                Section("Appearance") {
                    Button(action: {
                        if storeManager.isPro || !appState.themeManager.currentTheme.isPro {
                            showThemePicker = true
                        } else {
                            showProUpgrade = true
                        }
                    }) {
                        HStack {
                            Label("Theme", systemImage: "paintpalette")
                                .foregroundColor(.primary)

                            Spacer()

                            // Current theme preview
                            HStack(spacing: 4) {
                                ForEach(appState.themeManager.currentTheme.previewColors, id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 8, height: 8)
                                }
                            }

                            Text(appState.themeManager.currentTheme.displayName)
                                .foregroundColor(.secondary)

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }

                // MARK: - iCloud Sync
                Section {
                    HStack {
                        Label("iCloud Sync", systemImage: "icloud")
                        Spacer()
                        Text("Automatic")
                            .foregroundColor(.secondary)
                    }

                    // Export Data (Pro Feature)
                    if storeManager.isPro {
                        Button(action: exportData) {
                            HStack {
                                Label("Export Data", systemImage: "square.and.arrow.up")
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Data")
                } footer: {
                    if storeManager.isPro {
                        Text("Your data syncs automatically via iCloud. Export your complete history as CSV.")
                    } else {
                        Text("Your data syncs automatically across all your devices via iCloud.")
                    }
                }

                // MARK: - Support & Legal
                Section("Support & Legal") {
                    Link(destination: URL(string: "https://macrosnap.app/privacy")!) {
                        HStack {
                            Label("Privacy Policy", systemImage: "hand.raised.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Link(destination: URL(string: "https://macrosnap.app/support")!) {
                        HStack {
                            Label("Contact Support", systemImage: "envelope.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // MARK: - App Info
                Section("About") {
                    HStack {
                        Text("Version")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.primary)
                    }

                    HStack {
                        Text("Build")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showProUpgrade) {
                print("🟢 ProUpgradeView sheet is presenting")
                return ProUpgradeView()
            }
            .onChange(of: showProUpgrade) { newValue in
                print("🟡 showProUpgrade changed to: \(newValue)")
            }
            .sheet(isPresented: $showThemePicker) {
                ThemePickerView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showCustomGoals) {
                CustomDailyGoalsView()
                    .environmentObject(appState)
                    .environment(\.managedObjectContext, viewContext)
            }
            .onAppear {
                loadCurrentGoals()
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Actions

    private func exportData() {
        print("📊 Export Data tapped - fetching entries...")

        // Fetch all entries
        let fetchRequest: NSFetchRequest<MacroEntryEntity> = MacroEntryEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MacroEntryEntity.date, ascending: false)]

        do {
            let entries = try viewContext.fetch(fetchRequest)
            print("📊 Fetched \(entries.count) entries")

            if entries.isEmpty {
                alertTitle = "No Data"
                alertMessage = "You don't have any entries to export yet."
                showingAlert = true
                return
            }

            // Generate CSV
            if let fileURL = CSVExporter.shared.generateCSV(from: entries) {
                print("📊 CSV generated at: \(fileURL.path)")

                // Present share sheet directly using UIKit
                DispatchQueue.main.async {
                    self.presentShareSheet(for: fileURL)
                }
            } else {
                print("❌ CSV generation failed")
                alertTitle = "Export Failed"
                alertMessage = "Failed to generate CSV file."
                showingAlert = true
            }
        } catch {
            print("❌ Error fetching entries: \(error)")
            alertTitle = "Error"
            alertMessage = "Failed to fetch entries: \(error.localizedDescription)"
            showingAlert = true
        }
    }

    private func presentShareSheet(for fileURL: URL) {
        print("📊 Presenting share sheet for: \(fileURL.path)")

        // Get the active window scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ Could not find root view controller")
            alertTitle = "Error"
            alertMessage = "Could not present share sheet"
            showingAlert = true
            return
        }

        // Find the topmost view controller
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }

        print("📊 Found top view controller: \(type(of: topController))")

        // Create activity view controller
        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

        // For iPad - set source view
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topController.view
            popover.sourceRect = CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        print("📊 Presenting UIActivityViewController...")
        topController.present(activityVC, animated: true) {
            print("✅ Share sheet presented successfully")
        }
    }

    private func loadCurrentGoals() {
        let currentGoal = appState.getCurrentGoal()
        proteinGoal = String(Int(currentGoal.proteinGoal))
        carbsGoal = String(Int(currentGoal.carbGoal))
        fatGoal = String(Int(currentGoal.fatGoal))
    }

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

        // Create goal entity
        let goal = MacroGoal(
            proteinGoal: protein,
            carbGoal: carbs,
            fatGoal: fat
        )

        // Save to CoreData
        saveGoalToDatabase(goal)

        isEditing = false

        alertTitle = "Success"
        alertMessage = "Your daily goals have been updated"
        showingAlert = true
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

            // Trigger CloudKit sync
            Task {
                await appState.cloudKitSync.performFullSync()
            }

        } catch {
            alertTitle = "Error"
            alertMessage = "Failed to save goals: \(error.localizedDescription)"
            showingAlert = true
        }
    }

}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()

        return SettingsView()
            .environmentObject(appState)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
