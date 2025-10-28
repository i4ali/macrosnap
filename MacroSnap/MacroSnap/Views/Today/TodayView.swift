//
//  TodayView.swift
//  MacroSnap
//
//  Today screen - Main tracking interface (Screen 1)
//

import SwiftUI
import CoreData

struct TodayView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showQuickLog = false
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false

    // Fetch today's entries from CoreData
    @FetchRequest private var coreDataEntries: FetchedResults<MacroEntryEntity>

    init() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        _coreDataEntries = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \MacroEntryEntity.createdAt, ascending: false)],
            predicate: NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate),
            animation: .default
        )
    }

    // Get current data (demo or real)
    private var goal: MacroGoal {
        appState.getCurrentGoal()
    }

    private var todayEntries: [MacroEntry] {
        return coreDataEntries.map { $0.toDomain() }
    }

    // Calculate totals from entries
    private var totalProtein: Double {
        todayEntries.reduce(0) { $0 + $1.protein }
    }

    private var totalCarbs: Double {
        todayEntries.reduce(0) { $0 + $1.carbs }
    }

    private var totalFat: Double {
        todayEntries.reduce(0) { $0 + $1.fat }
    }

    private var totalCalories: Double {
        (totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9)
    }

    private var goalCalories: Double {
        (goal.proteinGoal * 4) + (goal.carbGoal * 4) + (goal.fatGoal * 9)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Apply custom background color if theme has one
            if let bgColor = appState.themeManager.currentTheme.backgroundColor {
                bgColor.ignoresSafeArea()
            }

            ScrollView {
                VStack(spacing: 32) {
                    // MARK: - Date Display
                    HStack {
                        Text("Today")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Spacer()

                        Text(Date().formatted(date: .abbreviated, time: .omitted))
                            .font(.headline)
                            .foregroundColor(.secondary)

                        // Share button
                        Button(action: shareProgress) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                                .foregroundColor(.blue)
                                .padding(.leading, 8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // MARK: - Progress Rings
                    ThreeRingProgressView(
                        proteinCurrent: totalProtein,
                        proteinGoal: goal.proteinGoal,
                        carbsCurrent: totalCarbs,
                        carbsGoal: goal.carbGoal,
                        fatCurrent: totalFat,
                        fatGoal: goal.fatGoal
                    )

                    // MARK: - Calorie Summary
                    VStack(spacing: 4) {
                        Text("\(Int(totalCalories)) / \(Int(goalCalories)) kcal")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("\(todayEntries.count) \(todayEntries.count == 1 ? "entry" : "entries") today")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // MARK: - Progress Bars
                    VStack(spacing: 20) {
                        MacroProgressBar(
                            label: "Protein",
                            current: totalProtein,
                            goal: goal.proteinGoal,
                            color: .blue
                        )

                        MacroProgressBar(
                            label: "Carbs",
                            current: totalCarbs,
                            goal: goal.carbGoal,
                            color: .green
                        )

                        MacroProgressBar(
                            label: "Fat",
                            current: totalFat,
                            goal: goal.fatGoal,
                            color: .yellow
                        )
                    }
                    .padding(.horizontal)

                    // Extra padding at bottom for floating button
                    Spacer()
                        .frame(height: 80)
                }
            }
            .navigationBarHidden(true)

            // MARK: - Floating Action Button
            Button(action: handleAddEntry) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.blue)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showQuickLog) {
            QuickLogSheet()
        }
        .onChange(of: shareImage) { image in
            if image != nil {
                showShareSheet = true
            }
        }
    }

    // MARK: - Actions

    private func handleAddEntry() {
        showQuickLog = true
    }

    private func shareProgress() {
        print("📸 Generating progress snapshot...")

        // Generate snapshot image
        let image = ProgressSnapshotGenerator.shared.generateSnapshot(
            proteinCurrent: totalProtein,
            proteinGoal: goal.proteinGoal,
            carbsCurrent: totalCarbs,
            carbsGoal: goal.carbGoal,
            fatCurrent: totalFat,
            fatGoal: goal.fatGoal,
            date: Date(),
            entryCount: todayEntries.count,
            theme: appState.themeManager.currentTheme
        )

        if let image = image {
            print("✅ Snapshot generated successfully")
            shareImage = image
            presentShareSheet(for: image)
        } else {
            print("❌ Failed to generate snapshot")
        }
    }

    private func presentShareSheet(for image: UIImage) {
        print("📤 Presenting share sheet...")

        // Get the active window scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ Could not find root view controller")
            return
        }

        // Find the topmost view controller
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }

        print("📤 Found top view controller: \(type(of: topController))")

        // Create activity view controller
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        // For iPad - set source view
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topController.view
            popover.sourceRect = CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        print("📤 Presenting UIActivityViewController...")
        topController.present(activityVC, animated: true) {
            print("✅ Share sheet presented successfully")
        }
    }
}

// MARK: - Preview
struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
            .environmentObject(AppState())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
