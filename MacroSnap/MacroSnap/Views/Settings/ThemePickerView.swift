//
//  ThemePickerView.swift
//  MacroSnap
//
//  Theme picker for Pro users
//

import SwiftUI

struct ThemePickerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @StateObject private var storeManager = StoreManager.shared
    @State private var showProUpgrade = false

    var body: some View {
        NavigationView {
            List {
                // Free Themes
                Section {
                    ForEach([AppTheme.system, AppTheme.dark, AppTheme.darkGrey, AppTheme.slate, AppTheme.light], id: \.self) { theme in
                        ThemeRow(
                            theme: theme,
                            isSelected: appState.themeManager.currentTheme == theme,
                            onSelect: {
                                appState.themeManager.setTheme(theme)
                            }
                        )
                    }
                } header: {
                    Text("Free Themes")
                }

                // Pro Themes
                Section {
                    ForEach([AppTheme.mint, AppTheme.sunset, AppTheme.ocean], id: \.self) { theme in
                        if storeManager.isPro {
                            ThemeRow(
                                theme: theme,
                                isSelected: appState.themeManager.currentTheme == theme,
                                onSelect: {
                                    appState.themeManager.setTheme(theme)
                                }
                            )
                        } else {
                            Button(action: {
                                showProUpgrade = true
                            }) {
                                HStack(spacing: 12) {
                                    // Theme Preview
                                    HStack(spacing: 4) {
                                        ForEach(theme.previewColors, id: \.self) { color in
                                            Circle()
                                                .fill(color)
                                                .frame(width: 12, height: 12)
                                        }
                                    }
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.1))
                                    )

                                    Text(theme.displayName)
                                        .foregroundColor(.primary)

                                    Spacer()

                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Pro Themes")
                } footer: {
                    if !storeManager.isPro {
                        Text("Upgrade to Pro to unlock custom themes")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showProUpgrade) {
                ProUpgradeView()
            }
        }
    }
}

// MARK: - Theme Row

struct ThemeRow: View {
    let theme: AppTheme
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Theme Preview
                HStack(spacing: 4) {
                    ForEach(theme.previewColors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                )

                // Theme Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.displayName)
                        .font(.body)
                        .foregroundColor(.primary)

                    if theme == .system {
                        Text("Follows device settings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Selected Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.accentColor)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
struct ThemePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ThemePickerView()
            .environmentObject(AppState())
    }
}
