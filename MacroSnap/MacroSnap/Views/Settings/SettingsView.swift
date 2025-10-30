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

    // Watch for default goal changes to auto-refresh UI
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "dayOfWeek == -1"),
        animation: .default
    )
    private var defaultGoals: FetchedResults<GoalEntity>

    // UI states
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showProUpgrade = false
    @State private var showThemePicker = false
    @State private var showCustomGoals = false
    @State private var showEditGoals = false
    @State private var refreshTrigger = UUID() // Force view refresh when goals change

    // Get current goal from FetchRequest for reactive updates
    private var currentGoal: MacroGoal {
        if let goalEntity = defaultGoals.first {
            return MacroGoal(
                proteinGoal: goalEntity.proteinGoal,
                carbGoal: goalEntity.carbGoal,
                fatGoal: goalEntity.fatGoal
            )
        }
        return appState.getCurrentGoal()
    }

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
                        Text("Get unlimited history, unlimited presets, custom themes, and more with a one-time purchase.")
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
                                icon: "square.stack.3d.up",
                                title: "Unlimited Macro Presets",
                                description: "Save unlimited presets (free: 2)"
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
                    Button(action: {
                        showEditGoals = true
                    }) {
                        HStack {
                            Text("Daily Goals")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()

                            Text("Edit")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .buttonStyle(.plain)

                    // Protein Goal
                    HStack {
                        Label("Protein", systemImage: "circle.fill")
                            .foregroundColor(.blue)

                        Spacer()

                        Text("\(Int(currentGoal.proteinGoal))")
                            .foregroundColor(.primary)

                        Text("g")
                            .foregroundColor(.secondary)
                    }

                    // Carbs Goal
                    HStack {
                        Label("Carbs", systemImage: "circle.fill")
                            .foregroundColor(.green)

                        Spacer()

                        Text("\(Int(currentGoal.carbGoal))")
                            .foregroundColor(.primary)

                        Text("g")
                            .foregroundColor(.secondary)
                    }

                    // Fat Goal
                    HStack {
                        Label("Fat", systemImage: "circle.fill")
                            .foregroundColor(.yellow)

                        Spacer()

                        Text("\(Int(currentGoal.fatGoal))")
                            .foregroundColor(.primary)

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

                // MARK: - Reminders Section
                Section {
                    Toggle(isOn: Binding(
                        get: { appState.notificationManager.streakRemindersEnabled },
                        set: { newValue in
                            Task {
                                if newValue && !appState.notificationManager.isAuthorized {
                                    let granted = await appState.notificationManager.requestAuthorization()
                                    if granted {
                                        appState.notificationManager.streakRemindersEnabled = true
                                    }
                                } else {
                                    appState.notificationManager.streakRemindersEnabled = newValue
                                }
                            }
                        }
                    )) {
                        Label("Streak Reminders", systemImage: "bell.fill")
                            .foregroundColor(.primary)
                    }

                    if appState.notificationManager.streakRemindersEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: Binding(
                                get: { appState.notificationManager.reminderTime },
                                set: { appState.notificationManager.reminderTime = $0 }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .foregroundColor(.primary)
                    }
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("Get reminded to keep your streak alive. You'll receive a daily notification at your chosen time.")
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
                        Text("1.1.0")
                            .foregroundColor(.primary)
                    }

                    HStack {
                        Text("Build")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("2")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                }
                .scrollContentBackground(.hidden)
                .id("settings-list")  // Stable ID to prevent view recreation
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
            .sheet(isPresented: $showEditGoals) {
                EditGoalsSheet(
                    initialProtein: currentGoal.proteinGoal,
                    initialCarbs: currentGoal.carbGoal,
                    initialFat: currentGoal.fatGoal
                )
                .environmentObject(appState)
                .environment(\.managedObjectContext, viewContext)
            }
            .onChange(of: defaultGoals.first?.updatedAt) { _ in
                // Force view refresh when goals are updated
                refreshTrigger = UUID()
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .navigationViewStyle(.stack)
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
