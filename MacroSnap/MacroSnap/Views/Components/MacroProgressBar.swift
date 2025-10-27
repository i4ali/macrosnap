//
//  MacroProgressBar.swift
//  MacroSnap
//
//  Progress bar showing macro grams with precise counts
//

import SwiftUI

struct MacroProgressBar: View {
    let label: String
    let current: Double
    let goal: Double
    let color: Color

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return current / goal
    }

    private var displayProgress: Double {
        // Cap visual progress at 1.0 (100%) for the bar
        min(progress, 1.0)
    }

    private var percentage: Int {
        // Show actual percentage, even if over 100%
        Int(progress * 100)
    }

    private var isOverGoal: Bool {
        progress > 1.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label and values
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(Int(current))g / \(Int(goal))g")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("(\(percentage)%)")
                    .font(.caption)
                    .fontWeight(isOverGoal ? .semibold : .regular)
                    .foregroundColor(isOverGoal ? color : .secondary)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(0.2))
                        .frame(height: 8)

                    // Progress fill
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(width: geometry.size.width * displayProgress, height: 8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: displayProgress)

                    // Overflow stripes when over 100%
                    if isOverGoal {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.5), color.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width, height: 8)
                    }
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Preview
struct MacroProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MacroProgressBar(
                label: "Protein (50%)",
                current: 90,
                goal: 180,
                color: .blue
            )

            MacroProgressBar(
                label: "Carbs (100%)",
                current: 250,
                goal: 250,
                color: .green
            )

            MacroProgressBar(
                label: "Fat (150%)",
                current: 105,
                goal: 70,
                color: .yellow
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
