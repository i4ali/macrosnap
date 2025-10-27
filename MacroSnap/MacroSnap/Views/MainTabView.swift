//
//  MainTabView.swift
//  MacroSnap
//
//  Main tab bar navigation (Today, History, Settings)
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // Custom background color (if theme has one)
            if let bgColor = appState.themeManager.currentTheme.backgroundColor {
                bgColor.ignoresSafeArea()
            }

            TabView(selection: $selectedTab) {
                // Tab 1: Today
                TodayView()
                    .tabItem {
                        Label("Today", systemImage: "chart.pie.fill")
                    }
                    .tag(0)

                // Tab 2: History
                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "calendar")
                    }
                    .tag(1)

                // Tab 3: Settings
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
        }
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AppState())
    }
}
