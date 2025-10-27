//
//  ThemeManager.swift
//  MacroSnap
//
//  Manages app theme (Pro feature)
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .darkGrey
    @AppStorage("selectedTheme") private var storedTheme: String = AppTheme.darkGrey.rawValue

    init() {
        // Load stored theme preference
        if let theme = AppTheme(rawValue: storedTheme) {
            currentTheme = theme
        }
    }

    // MARK: - Theme Management

    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        storedTheme = theme.rawValue

        print("✅ Theme set to: \(theme.displayName)")

        // TODO: Sync to CloudKit in future phase
    }

    func loadTheme() {
        // Load from UserDefaults (already handled in init via @AppStorage)
        if let theme = AppTheme(rawValue: storedTheme) {
            currentTheme = theme
            print("✅ Loaded theme: \(theme.displayName)")
        }
    }

    // MARK: - Color Accessors (for easy access throughout the app)

    var accentColor: Color {
        currentTheme.accentColor
    }

    var proteinColor: Color {
        currentTheme.proteinColor
    }

    var carbsColor: Color {
        currentTheme.carbsColor
    }

    var fatColor: Color {
        currentTheme.fatColor
    }

    var backgroundGradient: LinearGradient {
        currentTheme.backgroundGradient
    }
}
