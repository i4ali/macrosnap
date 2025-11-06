# Barcode Scanner Implementation Plan

## Overview
Add barcode scanning to MacroSnap using **Option 1**: Scan button inside Quick Log Sheet. Use free APIs (OpenFoodFacts) for product lookup.

## UI/UX Design - Option 1 (Chosen)

### Current Flow
```
Today View → [+ Button] → Quick Log Sheet → Manual Entry
```

### New Flow with Scanner
```
Today View → [+ Button] → Quick Log Sheet
                              ↓
                         [Scan Barcode Button]
                              ↓
                         Camera Scanner
                              ↓
                    Auto-fill Quick Log Sheet
                              ↓
                    User reviews/edits → Done
```

### Modified Quick Log Sheet Layout
```
┌─────────────────────────────────┐
│  Log Macros              [Done] │
│ ─────                            │
│                                 │
│  ● Protein    [ 40       ] g    │
│  ● Carbs      [ 30       ] g    │
│  ● Fat        [ 10       ] g    │
│                                 │
│  📝 Notes (Optional)             │
│  [___________________]          │
│                                 │
│  ┌───────────────────────────┐  │  ← NEW!
│  │  📷  Scan Barcode         │  │
│  └───────────────────────────┘  │
│                                 │
│  [Load Preset] [Save Preset]    │
│                                 │
│  [ 1 ]   [ 2 ]   [ 3 ]          │
│  [ 4 ]   [ 5 ]   [ 6 ]          │
│  [ 7 ]   [ 8 ]   [ 9 ]          │
│  [ . ]   [ 0 ]   [ ← ]          │
└─────────────────────────────────┘
```

### After Successful Scan
```
┌─────────────────────────────────┐
│  Log Macros              [Done] │
│ ─────                            │
│  ✓ Found: Clif Bar Choc Chip    │  ← NEW INDICATOR
│                                 │
│  ● Protein    [ 9        ] g    │  ← AUTO-FILLED
│  ● Carbs      [ 44       ] g    │  ← AUTO-FILLED
│  ● Fat        [ 5        ] g    │  ← AUTO-FILLED
│                                 │
│  📝 Notes (Optional)             │
│  [Clif Bar Chocolate Chip__]    │  ← AUTO-FILLED
│                                 │
│  ┌───────────────────────────┐  │
│  │  📷  Scan Different Item  │  │  ← BUTTON TEXT CHANGE
│  └───────────────────────────┘  │
│                                 │
│  [Load Preset] [Save Preset]    │
│                                 │
│  [ 1 ]   [ 2 ]   [ 3 ]          │
│  [ 4 ]   [ 5 ]   [ 6 ]          │
│  [ 7 ]   [ 8 ]   [ 9 ]          │
│  [ . ]   [ 0 ]   [ ← ]          │
└─────────────────────────────────┘
```

---

## Technical Stack

### Barcode Detection
- **Framework**: VisionKit's `DataScannerViewController` (iOS 16+)
- **Target iOS**: 18.6+ (already set in project)
- **Supported Formats**: EAN-13, UPC-A, UPC-E, Code 128, QR codes
- **Hardware**: Requires A12 Bionic or later

### Food Database APIs

#### Primary: OpenFoodFacts
- **Website**: https://world.openfoodfacts.org
- **API Endpoint**: `https://world.openfoodfacts.net/api/v2/product/{barcode}`
- **Cost**: 100% FREE, no API key required
- **Rate Limit**: No strict limit for personal apps (be reasonable)
- **User-Agent**: Required - "MacroSnap/1.1 (support@macrosnap.app)"
- **Database Size**: 3+ million products worldwide
- **Data Quality**: Community-driven, varies by product

**Example Response Structure:**
```json
{
  "status": 1,
  "product": {
    "product_name": "Clif Bar Chocolate Chip",
    "brands": "Clif Bar",
    "serving_size": "68g",
    "nutriments": {
      "proteins_100g": 13.24,
      "carbohydrates_100g": 64.71,
      "fat_100g": 7.35,
      "proteins_serving": 9,
      "carbohydrates_serving": 44,
      "fat_serving": 5,
      "energy-kcal_serving": 250
    },
    "images": {
      "front_url": "..."
    }
  }
}
```

#### Fallback: USDA FoodData Central
- **Website**: https://fdc.nal.usda.gov
- **API Endpoint**: `https://api.nal.usda.gov/fdc/v1/foods/search`
- **Cost**: FREE, requires API key (free signup)
- **Rate Limit**: 1,000 requests/hour per IP
- **Database**: Government-verified nutritional data
- **Use Case**: When OpenFoodFacts doesn't have the product

---

## Implementation Phases

### Phase 1: Core Barcode Scanner Service
**Estimated Time**: 2-3 hours

#### Files to Create:

**1. `MacroSnap/Services/BarcodeScannerService.swift`**
```swift
// Wrapper around VisionKit's DataScannerViewController
// Responsibilities:
// - Check device capability (A12+, iOS 16+)
// - Request camera permissions
// - Configure barcode scanner
// - Emit scanned barcode results
// - Handle errors (no permission, unsupported device)
```

**Key Features:**
- Device capability check: `DataScannerViewController.isSupported`
- Camera permission handling
- Barcode type configuration (focus on EAN-13, UPC-A)
- Delegate pattern for scan results
- Error handling enum

**2. `MacroSnap/Views/Components/BarcodeScannerView.swift`**
```swift
// SwiftUI wrapper using UIViewControllerRepresentable
// Responsibilities:
// - Display camera view
// - Show scan guide overlay
// - Visual feedback on detection
// - Manual barcode entry fallback
// - Close/dismiss actions
```

**UI Elements:**
- Camera preview (full screen)
- Scan guide rectangle overlay
- "Scanning..." indicator
- "✕ Close" button (top left)
- "Enter Barcode Manually" button (bottom)
- Haptic feedback on successful scan

#### Camera Permission Setup:

**Modify `Info.plist`** (or add to project settings):
```xml
<key>NSCameraUsageDescription</key>
<string>MacroSnap needs camera access to scan food barcodes for quick macro entry.</string>
```

---

### Phase 2: Food Database Integration
**Estimated Time**: 1-2 hours

#### Files to Create:

**1. `MacroSnap/Models/FoodProduct.swift`**
```swift
// Domain model for scanned food products
struct FoodProduct {
    let barcode: String
    let name: String
    let brand: String?

    // Nutritional info
    let protein: Double      // grams per serving
    let carbs: Double        // grams per serving
    let fat: Double          // grams per serving
    let calories: Double?    // optional

    // Serving info
    let servingSize: String? // e.g., "68g", "1 bar"
    let servingUnit: String? // e.g., "g", "ml"

    // Metadata
    let imageUrl: String?
    let source: FoodDataSource // .openFoodFacts, .usda, .cached
}

enum FoodDataSource {
    case openFoodFacts
    case usda
    case cached
}
```

**2. `MacroSnap/Services/FoodDatabaseService.swift`**
```swift
// Handles API calls to food databases
class FoodDatabaseService {
    // Primary: OpenFoodFacts lookup
    func lookupByBarcode(_ barcode: String) async throws -> FoodProduct

    // Fallback: USDA lookup
    func searchUSDA(_ query: String) async throws -> [FoodProduct]

    // Helper: Parse OpenFoodFacts response
    private func parseOpenFoodFacts(_ json: [String: Any]) -> FoodProduct?

    // Helper: Calculate per-serving macros from per-100g
    private func calculateServingMacros(...)

    // Cache: Store recent lookups
    private func cacheProduct(_ product: FoodProduct)
    private func getCachedProduct(barcode: String) -> FoodProduct?
}
```

**API Error Handling:**
```swift
enum FoodDatabaseError: Error {
    case productNotFound
    case invalidBarcode
    case networkError(Error)
    case invalidResponse
    case missingNutritionalData
}
```

**Data Mapping Logic:**
```
OpenFoodFacts → MacroSnap
================================
product_name → name
brands → brand
serving_size → servingSize

If serving data available:
  nutriments.proteins_serving → protein
  nutriments.carbohydrates_serving → carbs
  nutriments.fat_serving → fat

Else (calculate from per-100g):
  nutriments.proteins_100g → protein (adjust by serving)
  nutriments.carbohydrates_100g → carbs (adjust by serving)
  nutriments.fat_100g → fat (adjust by serving)
```

---

### Phase 3: UI Integration (Quick Log Sheet)
**Estimated Time**: 1-2 hours

#### Files to Modify:

**1. `MacroSnap/Views/Today/QuickLogSheet.swift`**

**Changes Required:**

**A. Add State Variables**
```swift
@State private var showBarcodeScanner = false
@State private var scannedProduct: FoodProduct?
@State private var isLoadingProduct = false
```

**B. Add "Scan Barcode" Button**
```swift
// Insert between Notes field and Preset buttons
Button(action: {
    showBarcodeScanner = true
}) {
    HStack {
        Image(systemName: "barcode.viewfinder")
        Text(scannedProduct == nil ? "Scan Barcode" : "Scan Different Item")
            .font(.subheadline)
            .fontWeight(.medium)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
    .background(Color.blue)
    .foregroundColor(.white)
    .cornerRadius(10)
}
```

**C. Add Scanned Product Indicator**
```swift
// Show above macro input fields if product scanned
if let product = scannedProduct {
    HStack {
        Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.green)
        Text("Found: \(product.name)")
            .font(.subheadline)
            .foregroundColor(.secondary)
        Spacer()
    }
    .padding(.horizontal)
    .padding(.vertical, 8)
}
```

**D. Add Sheet Presentation**
```swift
.sheet(isPresented: $showBarcodeScanner) {
    BarcodeScannerView { barcode in
        handleBarcodeScanned(barcode)
    }
}
```

**E. Add Barcode Handling Logic**
```swift
private func handleBarcodeScanned(_ barcode: String) {
    showBarcodeScanner = false
    isLoadingProduct = true

    Task {
        do {
            let product = try await FoodDatabaseService.shared.lookupByBarcode(barcode)
            await MainActor.run {
                scannedProduct = product
                autoFillFromProduct(product)
                isLoadingProduct = false
            }
        } catch {
            await MainActor.run {
                isLoadingProduct = false
                handleProductLookupError(error)
            }
        }
    }
}

private func autoFillFromProduct(_ product: FoodProduct) {
    proteinText = String(Int(product.protein))
    carbsText = String(Int(product.carbs))
    fatText = String(Int(product.fat))

    if !product.name.isEmpty {
        notesText = product.name
    }
}
```

---

### Phase 4: Error Handling & Edge Cases
**Estimated Time**: 1 hour

#### Scenarios to Handle:

**1. Product Not Found**
```swift
Alert: "Product Not Found"
Message: "We couldn't find nutritional info for this barcode. You can:
• Enter macros manually
• Try scanning again
• Report missing product"

Actions:
[Manual Entry] [Try Again] [Cancel]
```

**2. No Camera Access**
```swift
Alert: "Camera Access Required"
Message: "MacroSnap needs camera access to scan barcodes. Enable it in Settings?"

Actions:
[Open Settings] [Cancel]

// Deeplink to Settings
if let url = URL(string: UIApplication.openSettingsURLString) {
    UIApplication.shared.open(url)
}
```

**3. Unsupported Device (< A12 Bionic)**
```swift
Alert: "Barcode Scanner Unavailable"
Message: "Your device doesn't support live barcode scanning. You can enter the barcode number manually."

Actions:
[Manual Entry] [OK]
```

**4. Invalid/Incomplete Nutritional Data**
```swift
// Show warning, allow editing
HStack {
    Image(systemName: "exclamationmark.triangle")
        .foregroundColor(.orange)
    Text("Incomplete data. Please verify macros.")
        .font(.caption)
}
```

**5. Network Error (Offline)**
```swift
Alert: "No Internet Connection"
Message: "Check cached products or try again when online."

Actions:
[View Cache] [Retry] [Cancel]
```

**6. Multiple Serving Sizes**
```swift
// If OpenFoodFacts provides multiple serving options
// Default to "per serving" if available
// Show picker if user wants to change
Picker("Serving Size", selection: $selectedServing) {
    Text("1 bar (68g)").tag(0)
    Text("100g").tag(1)
}
```

---

### Phase 5: Polish & Optimization
**Estimated Time**: 1 hour

#### Enhancements:

**1. Recent Scans Cache**
- Store last 20 scanned products in UserDefaults
- Quick access without rescanning
- Integration with Preset Library

**2. Loading States**
```swift
// While scanning
ProgressView()
    .progressViewStyle(.circular)

// While looking up product
HStack {
    ProgressView()
    Text("Looking up product...")
}
```

**3. Haptic Feedback**
```swift
import CoreHaptics

// Success haptic on barcode detected
let generator = UINotificationFeedbackGenerator()
generator.notificationOccurred(.success)

// Error haptic on failure
generator.notificationOccurred(.error)
```

**4. Manual Barcode Entry Fallback**
```swift
// Add to BarcodeScannerView
TextField("Enter barcode number", text: $manualBarcode)
    .keyboardType(.numberPad)
    .textFieldStyle(.roundedBorder)

Button("Look Up") {
    onBarcodeScanned(manualBarcode)
}
```

**5. Smooth Animations**
```swift
.transition(.move(edge: .bottom).combined(with: .opacity))
.animation(.spring(response: 0.3, dampingFraction: 0.8), value: scannedProduct)
```

---

## File Structure

```
MacroSnap/
├── Models/
│   ├── MacroEntry.swift (existing)
│   ├── MacroGoal.swift (existing)
│   └── FoodProduct.swift (NEW)
│
├── Services/
│   ├── CloudKitSync.swift (existing)
│   ├── StoreManager.swift (existing)
│   ├── BarcodeScannerService.swift (NEW)
│   └── FoodDatabaseService.swift (NEW)
│
├── Views/
│   ├── Components/
│   │   ├── ThreeRingProgressView.swift (existing)
│   │   └── BarcodeScannerView.swift (NEW)
│   │
│   └── Today/
│       ├── TodayView.swift (existing)
│       └── QuickLogSheet.swift (MODIFY)
│
├── Utils/
│   └── (existing utilities)
│
└── Info.plist (MODIFY - add camera permission)
```

---

## Privacy & Permissions

### Required Permission
**Camera Usage** (NSCameraUsageDescription):
```
MacroSnap needs camera access to scan food barcodes for quick macro entry.
```

### User Data
- No barcode data sent to MacroSnap servers
- All API calls go directly to OpenFoodFacts/USDA
- Cached products stored locally only
- No personal data collected

---

## Testing Plan

### Test Cases

**1. Barcode Scanning**
- [ ] Scan EAN-13 barcode (European)
- [ ] Scan UPC-A barcode (US/Canada)
- [ ] Scan QR code with product URL
- [ ] Scan in poor lighting conditions
- [ ] Scan damaged/partial barcode
- [ ] Scan multiple barcodes in view

**2. Product Lookup**
- [ ] Popular product (Clif Bar, protein powder)
- [ ] International product
- [ ] Store brand product
- [ ] Unknown/rare product
- [ ] Product with missing data

**3. Data Accuracy**
- [ ] Verify protein matches label
- [ ] Verify carbs matches label
- [ ] Verify fat matches label
- [ ] Check serving size conversion

**4. Error Scenarios**
- [ ] No camera permission
- [ ] Airplane mode (offline)
- [ ] Invalid barcode format
- [ ] API timeout
- [ ] Unsupported device

**5. UI/UX**
- [ ] Scan button appears correctly
- [ ] Camera view opens smoothly
- [ ] Fields auto-fill correctly
- [ ] Can edit after scan
- [ ] Loading indicators work
- [ ] Haptic feedback fires

**6. Edge Cases**
- [ ] Scan, then scan different product
- [ ] Scan, then use preset (what takes priority?)
- [ ] Background/foreground app transitions
- [ ] Low memory conditions

### Test Products (Common Barcodes)
- Clif Bar Chocolate Chip: `722252100016`
- Quest Bar Chocolate Chip: `888849000028`
- Optimum Nutrition Gold Standard Whey: `748927023480`
- Kind Bar Dark Chocolate: `602652171970`

---

## API Integration Details

### OpenFoodFacts API

**Request:**
```swift
let barcode = "722252100016"
let url = "https://world.openfoodfacts.net/api/v2/product/\(barcode)"

var request = URLRequest(url: URL(string: url)!)
request.setValue("MacroSnap/1.1 (support@macrosnap.app)",
                 forHTTPHeaderField: "User-Agent")

let (data, response) = try await URLSession.shared.data(for: request)
```

**Response Handling:**
```swift
struct OpenFoodFactsResponse: Decodable {
    let status: Int  // 1 = found, 0 = not found
    let product: Product?

    struct Product: Decodable {
        let product_name: String?
        let brands: String?
        let serving_size: String?
        let nutriments: Nutriments

        struct Nutriments: Decodable {
            let proteins_serving: Double?
            let carbohydrates_serving: Double?
            let fat_serving: Double?
            let proteins_100g: Double?
            let carbohydrates_100g: Double?
            let fat_100g: Double?
        }
    }
}
```

### USDA FoodData Central API (Fallback)

**Request:**
```swift
let apiKey = "YOUR_API_KEY" // Store in Config
let query = "722252100016"
let url = "https://api.nal.usda.gov/fdc/v1/foods/search"
    + "?query=\(query)"
    + "&pageSize=1"
    + "&api_key=\(apiKey)"
```

**Note**: USDA doesn't always have barcode mapping, mainly useful for brand-name products.

---

## Future Enhancements (Post-MVP)

### v1.2 Features
- [ ] Barcode history view
- [ ] Favorite scanned products
- [ ] Custom product database (user submissions)
- [ ] OCR for nutrition labels (image scan)
- [ ] Voice-guided scanning (accessibility)

### v1.3 Features
- [ ] Batch scanning (multiple products)
- [ ] Shopping list integration
- [ ] Meal photo + barcode combination
- [ ] Nutritional insights for scanned products

### Pro Features (Potential)
- [ ] Unlimited cached products (free = 20)
- [ ] Advanced nutritional breakdown
- [ ] Product alternatives suggestions
- [ ] Export scan history

---

## Success Criteria

### Must Have (MVP)
✅ User can tap "Scan Barcode" in Quick Log Sheet
✅ Camera opens with clear scan guide
✅ Barcode detected automatically
✅ Product nutritional data auto-fills form
✅ User can edit values before saving
✅ Graceful error handling for all edge cases
✅ Works with common food products (80%+ hit rate)

### Nice to Have
✅ Haptic feedback on successful scan
✅ Manual barcode entry fallback
✅ Recent scans cache
✅ Loading animations
✅ Product images displayed

### Performance Goals
- Scanner opens in < 500ms
- Product lookup completes in < 2s
- Smooth 60fps camera preview
- No memory leaks from camera
- < 5MB additional app size

---

## Timeline Estimate

| Phase | Task | Time |
|-------|------|------|
| 1 | Core barcode scanner service | 2-3h |
| 2 | Food database integration | 1-2h |
| 3 | UI integration (Quick Log) | 1-2h |
| 4 | Error handling & edge cases | 1h |
| 5 | Polish & optimization | 1h |
| Testing | Comprehensive testing | 1h |
| **Total** | | **7-10h** |

---

## Open Questions

1. **Should we support offline mode?**
   - Cache products for offline use?
   - How many cached products (20? 50? 100?)?

2. **What if multiple serving sizes exist?**
   - Always default to "per serving"?
   - Let user pick from dropdown?

3. **Should we show product images?**
   - Helpful for confirmation
   - Adds complexity and data usage

4. **Manual barcode entry - where?**
   - In camera view?
   - Separate sheet?
   - Both?

5. **Free vs Pro feature?**
   - Should barcode scanning be free or Pro-only?
   - Recommendation: **Free** (core feature, drives engagement)

---

## Notes

- OpenFoodFacts is a non-profit, volunteer-run database
- Data quality varies - always allow user editing
- Some barcodes may not exist in any database
- International products may have better coverage in OpenFoodFacts vs USDA
- Consider adding "Report Missing Product" feature for community contribution

---

## Resources

### Documentation
- [VisionKit DataScannerViewController](https://developer.apple.com/documentation/visionkit/datascannerviewcontroller)
- [OpenFoodFacts API](https://openfoodfacts.github.io/openfoodfacts-server/api/)
- [USDA FoodData Central API](https://fdc.nal.usda.gov/api-guide.html)

### Sample Code
- [Apple VisionKit Sample](https://developer.apple.com/documentation/visionkit/scanning_data_with_the_camera)
- [SwiftUI Barcode Scanner Examples](https://www.hackingwithswift.com/books/ios-swiftui)

---

**Last Updated**: 2025-11-06
**Version**: 1.0
**Status**: Planning Phase
