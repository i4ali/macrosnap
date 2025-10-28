//
//  ProgressSnapshotView.swift
//  MacroSnap
//
//  Shareable snapshot view optimized for social media
//

import SwiftUI

struct ProgressSnapshotView: View {
    let proteinCurrent: Double
    let proteinGoal: Double
    let carbsCurrent: Double
    let carbsGoal: Double
    let fatCurrent: Double
    let fatGoal: Double
    let date: Date
    let entryCount: Int
    let backgroundColor: Color

    private var totalCalories: Int {
        Int((proteinCurrent * 4) + (carbsCurrent * 4) + (fatCurrent * 9))
    }

    private var goalCalories: Int {
        Int((proteinGoal * 4) + (carbsGoal * 4) + (fatGoal * 9))
    }

    var body: some View {
        ZStack {
            // Background
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 40) {
                // MARK: - Header
                VStack(spacing: 8) {
                    Text("My Progress")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.primary)

                    Text(date.formatted(date: .long, time: .omitted))
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)

                Spacer()

                // MARK: - Progress Rings
                ThreeRingProgressView(
                    proteinCurrent: proteinCurrent,
                    proteinGoal: proteinGoal,
                    carbsCurrent: carbsCurrent,
                    carbsGoal: carbsGoal,
                    fatCurrent: fatCurrent,
                    fatGoal: fatGoal
                )
                .scaleEffect(1.2) // Make rings larger for snapshot

                Spacer()

                // MARK: - Stats
                VStack(spacing: 24) {
                    // Calorie Summary
                    VStack(spacing: 8) {
                        Text("\(totalCalories) / \(goalCalories)")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundColor(.primary)

                        Text("calories")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.secondary)
                    }

                    // Macro Breakdown
                    HStack(spacing: 32) {
                        MacroStatCard(
                            label: "Protein",
                            current: proteinCurrent,
                            goal: proteinGoal,
                            color: .blue
                        )

                        MacroStatCard(
                            label: "Carbs",
                            current: carbsCurrent,
                            goal: carbsGoal,
                            color: .green
                        )

                        MacroStatCard(
                            label: "Fat",
                            current: fatCurrent,
                            goal: fatGoal,
                            color: .yellow
                        )
                    }
                    .padding(.horizontal, 40)

                    // Entry count
                    Text("\(entryCount) \(entryCount == 1 ? "entry" : "entries") today")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // MARK: - Branding
                HStack(spacing: 8) {
                    Text("Tracked with")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.secondary)

                    Text("MacroSnap")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)

                    Text("💪")
                        .font(.system(size: 20))
                }
                .padding(.bottom, 60)
            }
        }
        .frame(width: 1080, height: 1350) // Instagram portrait dimensions
    }
}

// MARK: - Macro Stat Card

struct MacroStatCard: View {
    let label: String
    let current: Double
    let goal: Double
    let color: Color

    private var percentage: Int {
        guard goal > 0 else { return 0 }
        return Int((current / goal) * 100)
    }

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Text("\(percentage)%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(color)
                )

            Text(label)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)

            Text("\(Int(current))g")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

struct ProgressSnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressSnapshotView(
            proteinCurrent: 150,
            proteinGoal: 180,
            carbsCurrent: 200,
            carbsGoal: 250,
            fatCurrent: 55,
            fatGoal: 70,
            date: Date(),
            entryCount: 4,
            backgroundColor: Color(.systemBackground)
        )
        .previewLayout(.sizeThatFits)
    }
}
