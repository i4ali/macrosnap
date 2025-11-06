//
//  FoodDatabaseService.swift
//  MacroSnap
//
//  Service for looking up food products from barcode databases
//

import Foundation
import Combine

// MARK: - Food Database Error

enum FoodDatabaseError: Error, LocalizedError {
    case productNotFound
    case invalidBarcode
    case networkError(Error)
    case invalidResponse
    case missingNutritionalData
    case parsingError

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found in database. Try manual entry or scan a different barcode."
        case .invalidBarcode:
            return "Invalid barcode format."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from food database."
        case .missingNutritionalData:
            return "Product found but nutritional data is incomplete. Please enter manually."
        case .parsingError:
            return "Error parsing product data."
        }
    }
}

// MARK: - Food Database Service

@MainActor
class FoodDatabaseService: ObservableObject {
    static let shared = FoodDatabaseService()

    @Published var isLoading = false
    @Published var lastError: FoodDatabaseError?

    private let openFoodFactsBaseURL = "https://world.openfoodfacts.net/api/v2/product"
    private let userAgent = "MacroSnap/1.1 (support@macrosnap.app)"

    // Cache for recently scanned products
    private var cache: [String: FoodProduct] = [:]
    private let cacheLimit = 20

    private init() {
        loadCache()
    }

    // MARK: - Main Lookup

    /// Lookup product by barcode (tries cache first, then API)
    func lookupByBarcode(_ barcode: String) async throws -> FoodProduct {
        isLoading = true
        defer { isLoading = false }

        // Normalize barcode
        let normalizedBarcode = BarcodeScannerService.shared.normalizeBarcode(barcode)

        // Validate barcode
        guard BarcodeScannerService.shared.validateBarcode(normalizedBarcode) else {
            throw FoodDatabaseError.invalidBarcode
        }

        // Check cache first
        if let cached = getCachedProduct(barcode: normalizedBarcode) {
            print("📦 Found product in cache: \(cached.name)")
            return cached
        }

        // Try OpenFoodFacts API
        do {
            let product = try await lookupOpenFoodFacts(barcode: normalizedBarcode)
            cacheProduct(product)
            return product
        } catch {
            print("❌ OpenFoodFacts lookup failed: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - OpenFoodFacts API

    private func lookupOpenFoodFacts(barcode: String) async throws -> FoodProduct {
        let urlString = "\(openFoodFactsBaseURL)/\(barcode)"

        guard let url = URL(string: urlString) else {
            throw FoodDatabaseError.invalidBarcode
        }

        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw FoodDatabaseError.invalidResponse
            }

            print("📡 OpenFoodFacts API Status: \(httpResponse.statusCode)")

            guard httpResponse.statusCode == 200 else {
                if httpResponse.statusCode == 404 {
                    throw FoodDatabaseError.productNotFound
                }
                throw FoodDatabaseError.invalidResponse
            }

            // Parse response
            let product = try parseOpenFoodFactsResponse(data, barcode: barcode)
            print("✅ Product found: \(product.name)")
            return product

        } catch let error as FoodDatabaseError {
            throw error
        } catch {
            throw FoodDatabaseError.networkError(error)
        }
    }

    // MARK: - Response Parsing

    private func parseOpenFoodFactsResponse(_ data: Data, barcode: String) throws -> FoodProduct {
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            guard let status = json?["status"] as? Int, status == 1 else {
                throw FoodDatabaseError.productNotFound
            }

            guard let productData = json?["product"] as? [String: Any] else {
                throw FoodDatabaseError.invalidResponse
            }

            // Extract basic info
            let name = productData["product_name"] as? String ?? "Unknown Product"
            let brand = productData["brands"] as? String
            let servingSize = productData["serving_size"] as? String

            // Extract nutritional data
            guard let nutriments = productData["nutriments"] as? [String: Any] else {
                throw FoodDatabaseError.missingNutritionalData
            }

            // Try to get per-serving data first, fall back to per-100g
            let protein: Double
            let carbs: Double
            let fat: Double
            let calories: Double?

            if let proteinServing = nutriments["proteins_serving"] as? Double {
                // Per-serving data available
                protein = proteinServing
                carbs = nutriments["carbohydrates_serving"] as? Double ?? 0
                fat = nutriments["fat_serving"] as? Double ?? 0
                calories = nutriments["energy-kcal_serving"] as? Double
            } else if let protein100g = nutriments["proteins_100g"] as? Double,
                      let servingSizeStr = servingSize {
                // Calculate from per-100g data
                let servingGrams = extractServingGrams(from: servingSizeStr)
                let multiplier = servingGrams / 100.0

                protein = protein100g * multiplier
                carbs = (nutriments["carbohydrates_100g"] as? Double ?? 0) * multiplier
                fat = (nutriments["fat_100g"] as? Double ?? 0) * multiplier
                calories = (nutriments["energy-kcal_100g"] as? Double).map { $0 * multiplier }
            } else {
                throw FoodDatabaseError.missingNutritionalData
            }

            // Validate that we have at least some nutritional data
            guard protein > 0 || carbs > 0 || fat > 0 else {
                throw FoodDatabaseError.missingNutritionalData
            }

            // Extract image URL
            let imageUrl = extractImageUrl(from: productData)

            // Create FoodProduct
            return FoodProduct(
                barcode: barcode,
                name: name,
                brand: brand,
                protein: protein,
                carbs: carbs,
                fat: fat,
                calories: calories,
                servingSize: servingSize,
                servingUnit: extractServingUnit(from: servingSize),
                imageUrl: imageUrl,
                source: .openFoodFacts
            )

        } catch let error as FoodDatabaseError {
            throw error
        } catch {
            print("❌ Parsing error: \(error)")
            throw FoodDatabaseError.parsingError
        }
    }

    // MARK: - Helper Methods

    private func extractServingGrams(from servingSize: String) -> Double {
        // Extract grams from serving size string (e.g., "68g" -> 68)
        let digits = servingSize.filter { $0.isNumber || $0 == "." }
        return Double(digits) ?? 100.0
    }

    private func extractServingUnit(from servingSize: String?) -> String? {
        guard let servingSize = servingSize else { return nil }

        // Common units
        if servingSize.lowercased().contains("bar") {
            return "bar"
        } else if servingSize.lowercased().contains("ml") {
            return "ml"
        } else if servingSize.contains("g") {
            return "g"
        } else if servingSize.lowercased().contains("oz") {
            return "oz"
        }

        return nil
    }

    private func extractImageUrl(from productData: [String: Any]) -> String? {
        // Try to get the front image
        if let images = productData["images"] as? [String: Any],
           let frontImage = images["front"] as? [String: Any],
           let url = frontImage["url"] as? String {
            return url
        }

        // Fallback to image_url
        return productData["image_url"] as? String
    }

    // MARK: - Cache Management

    private func cacheProduct(_ product: FoodProduct) {
        cache[product.barcode] = product

        // Limit cache size
        if cache.count > cacheLimit {
            // Remove oldest entries
            let sorted = cache.values.sorted { $0.scannedAt < $1.scannedAt }
            if let oldest = sorted.first {
                cache.removeValue(forKey: oldest.barcode)
            }
        }

        saveCache()
    }

    private func getCachedProduct(barcode: String) -> FoodProduct? {
        return cache[barcode]
    }

    func clearCache() {
        cache.removeAll()
        saveCache()
    }

    // MARK: - Persistence

    private var cacheFileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("food_product_cache.json")
    }

    private func saveCache() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(Array(cache.values))
            try data.write(to: cacheFileURL)
            print("💾 Saved \(cache.count) products to cache")
        } catch {
            print("❌ Failed to save cache: \(error)")
        }
    }

    private func loadCache() {
        do {
            let data = try Data(contentsOf: cacheFileURL)
            let decoder = JSONDecoder()
            let products = try decoder.decode([FoodProduct].self, from: data)

            cache = Dictionary(uniqueKeysWithValues: products.map { ($0.barcode, $0) })
            print("📦 Loaded \(cache.count) products from cache")
        } catch {
            print("ℹ️ No cache file found or failed to load cache")
        }
    }

    // MARK: - Public Cache Access

    var cachedProducts: [FoodProduct] {
        Array(cache.values).sorted { $0.scannedAt > $1.scannedAt }
    }

    var cacheCount: Int {
        cache.count
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension FoodDatabaseService {
    static var preview: FoodDatabaseService {
        let service = FoodDatabaseService()
        return service
    }
}
#endif
