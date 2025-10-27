//
//  AppTheme.swift
//  MacroSnap
//
//  Theme system for Pro users
//

import SwiftUI

enum AppTheme: String, CaseIterable, Codable {
    case system = "system"
    case dark = "dark"
    case darkGrey = "darkGrey"
    case light = "light"
    case mint = "mint"
    case sunset = "sunset"
    case ocean = "ocean"

    var displayName: String {
        switch self {
        case .system:
            return "System"
        case .dark:
            return "Dark"
        case .darkGrey:
            return "Dark Grey"
        case .light:
            return "Light"
        case .mint:
            return "Mint"
        case .sunset:
            return "Sunset"
        case .ocean:
            return "Ocean"
        }
    }

    var icon: String {
        switch self {
        case .system:
            return "gear"
        case .dark:
            return "moon.fill"
        case .darkGrey:
            return "moon.stars.fill"
        case .light:
            return "sun.max.fill"
        case .mint:
            return "leaf.fill"
        case .sunset:
            return "sunset.fill"
        case .ocean:
            return "drop.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .dark, .darkGrey, .ocean:
            return .dark
        case .light, .mint, .sunset:
            return .light
        }
    }

    // Primary accent color
    var accentColor: Color {
        switch self {
        case .system, .dark, .darkGrey, .light:
            return .blue
        case .mint:
            return Color(red: 0.2, green: 0.8, blue: 0.6)
        case .sunset:
            return Color(red: 1.0, green: 0.5, blue: 0.3)
        case .ocean:
            return Color(red: 0.2, green: 0.6, blue: 0.9)
        }
    }

    // Secondary color
    var secondaryColor: Color {
        switch self {
        case .system, .dark, .darkGrey, .light:
            return .gray
        case .mint:
            return Color(red: 0.1, green: 0.6, blue: 0.5)
        case .sunset:
            return Color(red: 0.9, green: 0.4, blue: 0.5)
        case .ocean:
            return Color(red: 0.3, green: 0.5, blue: 0.7)
        }
    }

    // Protein color
    var proteinColor: Color {
        switch self {
        case .system, .dark, .darkGrey, .light:
            return .blue
        case .mint:
            return Color(red: 0.2, green: 0.8, blue: 0.6)
        case .sunset:
            return Color(red: 1.0, green: 0.6, blue: 0.4)
        case .ocean:
            return Color(red: 0.3, green: 0.7, blue: 1.0)
        }
    }

    // Carbs color
    var carbsColor: Color {
        switch self {
        case .system, .dark, .darkGrey, .light:
            return .green
        case .mint:
            return Color(red: 0.4, green: 0.9, blue: 0.5)
        case .sunset:
            return Color(red: 1.0, green: 0.8, blue: 0.3)
        case .ocean:
            return Color(red: 0.4, green: 0.8, blue: 0.7)
        }
    }

    // Fat color
    var fatColor: Color {
        switch self {
        case .system, .dark, .darkGrey, .light:
            return .yellow
        case .mint:
            return Color(red: 0.9, green: 0.9, blue: 0.3)
        case .sunset:
            return Color(red: 1.0, green: 0.4, blue: 0.5)
        case .ocean:
            return Color(red: 0.5, green: 0.7, blue: 0.9)
        }
    }

    // Background gradient (for themed sections)
    var backgroundGradient: LinearGradient {
        switch self {
        case .system, .dark, .darkGrey, .light:
            return LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .mint:
            return LinearGradient(
                colors: [Color(red: 0.2, green: 0.8, blue: 0.6).opacity(0.15), Color(red: 0.4, green: 0.9, blue: 0.5).opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sunset:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.5, blue: 0.3).opacity(0.15), Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ocean:
            return LinearGradient(
                colors: [Color(red: 0.2, green: 0.6, blue: 0.9).opacity(0.15), Color(red: 0.4, green: 0.8, blue: 0.7).opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // Preview color for theme picker
    var previewColors: [Color] {
        [proteinColor, carbsColor, fatColor]
    }

    // Custom background color (nil means use system default)
    var backgroundColor: Color? {
        switch self {
        case .darkGrey:
            return Color(red: 0.13, green: 0.13, blue: 0.14) // Dark grey - subtle but visible difference from pure black
        case .system, .dark, .light, .mint, .sunset, .ocean:
            return nil
        }
    }

    var isPro: Bool {
        switch self {
        case .system, .dark, .darkGrey, .light:
            return false
        case .mint, .sunset, .ocean:
            return true
        }
    }
}
