//
//  BarcodeScannerService.swift
//  MacroSnap
//
//  Service for barcode scanning using VisionKit
//

import Foundation
import Combine
import Vision
import VisionKit
import AVFoundation

// MARK: - Barcode Scanner Error

enum BarcodeScannerError: Error, LocalizedError {
    case unsupportedDevice
    case cameraAccessDenied
    case scanningNotAvailable
    case invalidBarcode
    case cancelled

    var errorDescription: String? {
        switch self {
        case .unsupportedDevice:
            return "Your device doesn't support barcode scanning. Please use a device with A12 Bionic chip or later."
        case .cameraAccessDenied:
            return "Camera access is required to scan barcodes. Please enable it in Settings."
        case .scanningNotAvailable:
            return "Barcode scanning is not available at this time."
        case .invalidBarcode:
            return "The scanned barcode is not valid."
        case .cancelled:
            return "Scanning was cancelled."
        }
    }
}

// MARK: - Barcode Scanner Service

@MainActor
class BarcodeScannerService: ObservableObject {
    static let shared = BarcodeScannerService()

    @Published var isScanning = false
    @Published var lastScannedBarcode: String?
    @Published var lastError: BarcodeScannerError?

    private init() {}

    // MARK: - Capability Check

    /// Check if barcode scanning is supported on this device
    var isScanningSupported: Bool {
        DataScannerViewController.isSupported
    }

    /// Check if the app is available (both supported and authorized)
    var isScanningAvailable: Bool {
        DataScannerViewController.isAvailable
    }

    // MARK: - Camera Permission

    /// Request camera permission
    func requestCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            return true

        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)

        case .denied, .restricted:
            lastError = .cameraAccessDenied
            return false

        @unknown default:
            return false
        }
    }

    /// Check current camera permission status
    var cameraPermissionStatus: AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    // MARK: - Scanner Configuration

    /// Get supported barcode symbologies for food products
    func supportedBarcodeSymbologies() -> Set<DataScannerViewController.RecognizedDataType> {
        return [
            .barcode(symbologies: [.ean13, .ean8, .upce, .code128, .qr])
        ]
    }

    // MARK: - Validation

    /// Validate that a barcode string is valid for food products
    func validateBarcode(_ barcode: String) -> Bool {
        // Remove any whitespace
        let cleaned = barcode.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check length (most food barcodes are 8, 12, or 13 digits)
        guard cleaned.count >= 8 && cleaned.count <= 14 else {
            return false
        }

        // Check that it contains only digits
        guard cleaned.allSatisfy({ $0.isNumber }) else {
            return false
        }

        return true
    }

    /// Normalize barcode (handle UPC-A to EAN-13 conversion if needed)
    func normalizeBarcode(_ barcode: String) -> String {
        var cleaned = barcode.trimmingCharacters(in: .whitespacesAndNewlines)

        // Convert UPC-A (12 digits) to EAN-13 by adding leading zero
        if cleaned.count == 12 {
            cleaned = "0" + cleaned
        }

        return cleaned
    }

    // MARK: - Helper Methods

    /// Open device settings if camera access is denied
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    /// Reset scanner state
    func reset() {
        isScanning = false
        lastScannedBarcode = nil
        lastError = nil
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension BarcodeScannerService {
    static var preview: BarcodeScannerService {
        let service = BarcodeScannerService()
        return service
    }
}
#endif
