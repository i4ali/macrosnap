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
    }

    // MARK: - Actions

    private func handleAddEntry() {
        showQuickLog = true
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
