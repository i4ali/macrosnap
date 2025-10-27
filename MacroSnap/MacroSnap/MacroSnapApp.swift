//
//  MacroSnapApp.swift
//  MacroSnap
//
//  Created by Muhammad Imran Ali on 10/24/25.
//

import SwiftUI
import CoreData

@main
struct MacroSnapApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var appState = AppState()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
                .preferredColorScheme(appState.themeManager.currentTheme.colorScheme)
                .tint(appState.themeManager.currentTheme.accentColor)
                .fullScreenCover(isPresented: .constant(!hasCompletedOnboarding)) {
                    OnboardingView()
                }
        }
    }
}
