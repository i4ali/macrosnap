//
//  MacroProgressRing.swift
//  MacroSnap
//
//  Progress ring component for visualizing macro progress
//

import SwiftUI

struct MacroProgressRing: View {
    let current: Double
    let goal: Double
    let color: Color
    let lineWidth: CGFloat

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return current / goal
    }

    private var displayProgress: Double {
        min(progress, 1.0)
    }

    private var isOverGoal: Bool {
        progress > 1.0
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            // Progress ring (capped at 100% visually)
            Circle()
                .trim(from: 0, to: displayProgress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: displayProgress)

            // Overflow indicator - pulsing glow when over 100%
            if isOverGoal {
                Circle()
                    .stroke(color, lineWidth: lineWidth + 2)
                    .opacity(0.3)
                    .scaleEffect(1.05)
                    .animation(
                        .easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                        value: isOverGoal
                    )
            }
        }
    }
}

// MARK: - Three Ring System

struct ThreeRingProgressView: View {
    let proteinCurrent: Double
    let proteinGoal: Double
    let carbsCurrent: Double
    let carbsGoal: Double
    let fatCurrent: Double
    let fatGoal: Double

    var body: some View {
        ZStack {
            // Fat (innermost, smallest ring)
            MacroProgressRing(
                current: fatCurrent,
                goal: fatGoal,
                color: .yellow,
                lineWidth: 12
            )
            .frame(width: 120, height: 120)

            // Carbs (middle ring)
            MacroProgressRing(
                current: carbsCurrent,
                goal: carbsGoal,
                color: .green,
                lineWidth: 12
            )
            .frame(width: 160, height: 160)

            // Protein (outermost, largest ring)
            MacroProgressRing(
                current: proteinCurrent,
                goal: proteinGoal,
                color: .blue,
                lineWidth: 12
            )
            .frame(width: 200, height: 200)
        }
        .padding(.vertical, 32)
    }
}

// MARK: - Preview
struct MacroProgressRing_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            // 50% progress
            MacroProgressRing(
                current: 90,
                goal: 180,
                color: .blue,
                lineWidth: 12
            )
            .frame(width: 200, height: 200)

            // 150% progress (overflow)
            MacroProgressRing(
                current: 270,
                goal: 180,
                color: .blue,
                lineWidth: 12
            )
            .frame(width: 200, height: 200)

            // Three rings with overflow
            ThreeRingProgressView(
                proteinCurrent: 270,
                proteinGoal: 180,
                carbsCurrent: 375,
                carbsGoal: 250,
                fatCurrent: 105,
                fatGoal: 70
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
