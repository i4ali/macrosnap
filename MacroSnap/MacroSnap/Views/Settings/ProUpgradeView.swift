//
//  ProUpgradeView.swift
//  MacroSnap
//
//  Pro upgrade purchase flow UI
//

import SwiftUI
import StoreKit

struct ProUpgradeView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var storeManager = StoreManager.shared

    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSuccess = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: - Header
                    VStack(spacing: 12) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("MacroSnap Pro")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Unlock the full potential")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 24)

                    // MARK: - Pro Features List
                    VStack(spacing: 16) {
                        ProFeatureRow(
                            icon: "calendar",
                            title: "Unlimited History",
                            description: "Access your complete macro tracking history"
                        )

                        ProFeatureRow(
                            icon: "note.text",
                            title: "Notes & Meal Names",
                            description: "Add notes and names to your macro entries"
                        )

                        ProFeatureRow(
                            icon: "square.stack.3d.up",
                            title: "Macro Presets",
                            description: "Save and reuse your favorite meals"
                        )

                        ProFeatureRow(
                            icon: "paintpalette",
                            title: "Custom Themes",
                            description: "Personalize your app with beautiful themes"
                        )

                        ProFeatureRow(
                            icon: "calendar.day.timeline.leading",
                            title: "Custom Daily Goals",
                            description: "Set different goals for each day of the week"
                        )

                        ProFeatureRow(
                            icon: "chart.xyaxis.line",
                            title: "Advanced Analytics",
                            description: "Week and month view charts with trends"
                        )

                        ProFeatureRow(
                            icon: "square.and.arrow.up",
                            title: "Export Data",
                            description: "Export your history to CSV format"
                        )
                    }
                    .padding(.horizontal)

                    // MARK: - Pricing
                    VStack(spacing: 8) {
                        if let product = storeManager.products.first {
                            Text(product.displayPrice)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        } else {
                            Text("$4.99")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }

                        Text("One-time purchase")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("No subscription • Lifetime access")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)

                    // MARK: - Purchase Buttons
                    VStack(spacing: 12) {
                        // Purchase Button
                        Button(action: handlePurchase) {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Upgrade to Pro")
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .disabled(isPurchasing || isRestoring || storeManager.products.isEmpty)

                        // Restore Button
                        Button(action: handleRestore) {
                            HStack {
                                if isRestoring {
                                    ProgressView()
                                } else {
                                    Text("Restore Purchases")
                                        .font(.subheadline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.blue)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .disabled(isPurchasing || isRestoring)
                    }
                    .padding(.horizontal)

                    // MARK: - Footer
                    Text("Purchase once, use forever. All features included.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Purchase Successful!", isPresented: $showingSuccess) {
                Button("OK") {
                    showingSuccess = false
                    // Delay dismiss to ensure alert is fully dismissed first
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        dismiss()
                    }
                }
            } message: {
                Text("You now have access to all Pro features!")
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .task {
                // Load products if not already loaded
                if storeManager.products.isEmpty {
                    await storeManager.loadProducts()
                }
            }
            .onChange(of: storeManager.isPro) { isPro in
                // Auto-dismiss when user becomes Pro (after alert is dismissed)
                if isPro && !showingSuccess {
                    // Slight delay to ensure alert is fully dismissed
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func handlePurchase() {
        guard let product = storeManager.products.first else {
            errorMessage = "Product not available. Please try again."
            showingError = true
            return
        }

        Task {
            isPurchasing = true
            defer { isPurchasing = false }

            do {
                let transaction = try await storeManager.purchase(product)

                if transaction != nil {
                    // Purchase successful
                    showingSuccess = true
                }
                // If transaction is nil, user cancelled - no need to show error

            } catch StoreError.failedVerification {
                errorMessage = "Transaction verification failed. Please try again."
                showingError = true
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }

    private func handleRestore() {
        Task {
            isRestoring = true
            defer { isRestoring = false }

            do {
                try await storeManager.restorePurchases()

                if storeManager.isPro {
                    showingSuccess = true
                } else {
                    errorMessage = "No previous purchases found."
                    showingError = true
                }

            } catch {
                errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
}

// MARK: - Preview
struct ProUpgradeView_Previews: PreviewProvider {
    static var previews: some View {
        ProUpgradeView()
    }
}
