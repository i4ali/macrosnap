//
//  StoreManager.swift
//  MacroSnap
//
//  Handles StoreKit 2 in-app purchases and Pro status
//

import Foundation
import StoreKit
import Combine
import CoreData

// Product ID for Pro purchase
enum ProductID: String, CaseIterable {
    case pro = "MAHR.Partners.MacroSnap.pro"

    var displayName: String {
        switch self {
        case .pro:
            return "MacroSnap Pro"
        }
    }

    var displayPrice: String {
        return "$4.99"
    }
}

@MainActor
class StoreManager: ObservableObject {
    // Singleton instance
    static let shared = StoreManager()

    // Published properties
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isPro: Bool = false

    // Transaction listener
    private var transactionListener: Task<Void, Error>?

    // UserDefaults keys
    private let proStatusKey = "isProUser"

    // MARK: - Initialization

    private init() {
        // Load Pro status from UserDefaults
        isPro = UserDefaults.standard.bool(forKey: proStatusKey)

        // Start listening for transactions
        transactionListener = listenForTransactions()

        // Load products and check purchase status
        Task {
            await loadProducts()
            await updatePurchaseStatus()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Product Loading

    func loadProducts() async {
        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIDs)
            print("✅ Loaded \(products.count) products")
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            // Update purchase status
            await updatePurchaseStatus()

            // Finish the transaction
            await transaction.finish()

            return transaction

        case .userCancelled:
            return nil

        case .pending:
            return nil

        @unknown default:
            return nil
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async throws {
        try await AppStore.sync()
        await updatePurchaseStatus()
    }

    // MARK: - Purchase Status

    func updatePurchaseStatus() async {
        var purchasedIDs: Set<String> = []

        // Check all transactions
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Add to purchased products
                purchasedIDs.insert(transaction.productID)

            } catch {
                print("❌ Transaction verification failed: \(error)")
            }
        }

        purchasedProductIDs = purchasedIDs
        isPro = purchasedIDs.contains(ProductID.pro.rawValue)

        // Save Pro status locally
        UserDefaults.standard.set(isPro, forKey: proStatusKey)

        print("📦 Purchase status updated. Pro: \(isPro)")

        // TODO: Sync Pro status to CloudKit in future phase
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Listen for transaction updates
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    // Update purchase status
                    await self.updatePurchaseStatus()

                    // Finish the transaction
                    await transaction.finish()
                } catch {
                    print("❌ Transaction update failed: \(error)")
                }
            }
        }
    }

    // MARK: - Verification

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Preset Limit Management

    /// Check if user can create a new preset (free users limited to 2, Pro users unlimited)
    func canCreatePreset(context: NSManagedObjectContext) -> (canCreate: Bool, message: String?) {
        if isPro {
            return (true, nil)
        }

        let fetchRequest: NSFetchRequest<PresetEntity> = PresetEntity.fetchRequest()
        let count = (try? context.count(for: fetchRequest)) ?? 0

        if count >= 2 {
            return (false, "Free users can save up to 2 presets. Upgrade to Pro for unlimited presets.")
        }
        return (true, nil)
    }
}

// MARK: - Errors

enum StoreError: Error, LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}
