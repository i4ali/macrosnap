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
        return min(current / goal, 1.0)
    }

    private var percentage: Int {
        Int(progress * 100)
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
                    .foregroundColor(.secondary)
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
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
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
                label: "Protein",
                current: 120,
                goal: 180,
                color: .blue
            )

            MacroProgressBar(
                label: "Carbs",
                current: 200,
                goal: 250,
                color: .green
            )

            MacroProgressBar(
                label: "Fat",
                current: 50,
                goal: 70,
                color: .yellow
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
