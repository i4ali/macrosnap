//
//  BarcodeScannerView.swift
//  MacroSnap
//
//  Camera view for scanning food product barcodes
//

import SwiftUI
import Vision
import VisionKit
import AVFoundation

// MARK: - Barcode Scanner View

struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scannerService = BarcodeScannerService.shared
    @State private var showManualEntry = false
    @State private var manualBarcode = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isProcessing = false

    let onBarcodeScanned: (String) -> Void

    var body: some View {
        ZStack {
            // Camera view
            if scannerService.isScanningSupported {
                DataScannerRepresentable(
                    recognizedItems: $scannerService.lastScannedBarcode,
                    onBarcodeScan: handleBarcodeScan
                )
                .ignoresSafeArea()
            } else {
                // Unsupported device fallback
                unsupportedDeviceView
            }

            // Overlay UI
            VStack {
                // Top bar
                topBar

                Spacer()

                // Scan guide
                scanGuide

                Spacer()

                // Bottom controls
                bottomControls
            }

            // Processing overlay
            if isProcessing {
                processingOverlay
            }
        }
        .onAppear {
            checkPermissionsAndStart()
        }
        .alert("Scanner Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
            if scannerService.lastError == .cameraAccessDenied {
                Button("Open Settings") {
                    scannerService.openSettings()
                }
            }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showManualEntry) {
            manualEntryView
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)
            }

            Spacer()

            Text("Scan Barcode")
                .font(.headline)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2)

            Spacer()

            // Placeholder for symmetry
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.4), Color.clear]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Scan Guide

    private var scanGuide: some View {
        VStack(spacing: 16) {
            // Scan frame
            RoundedRectangle(cornerRadius: 16)
                .stroke(style: StrokeStyle(lineWidth: 3, dash: [10, 5]))
                .foregroundColor(.white)
                .frame(width: 280, height: 160)
                .shadow(color: .black.opacity(0.3), radius: 4)
                .overlay(
                    VStack {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.7))

                        Text("Align barcode here")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                )

            // Instructions
            Text("Hold your device steady")
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.6))
                .cornerRadius(8)
        }
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 12) {
            Button(action: {
                showManualEntry = true
            }) {
                HStack {
                    Image(systemName: "keyboard")
                    Text("Enter Barcode Manually")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
            }

            Text("💡 Works with UPC, EAN, and QR codes")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.bottom, 32)
    }

    // MARK: - Unsupported Device View

    private var unsupportedDeviceView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Scanner Not Available")
                .font(.title2)
                .fontWeight(.bold)

            Text("Your device doesn't support live barcode scanning. You can enter the barcode number manually.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: {
                showManualEntry = true
            }) {
                Text("Enter Barcode Manually")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)

            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.secondary)
        }
        .padding()
    }

    // MARK: - Manual Entry View

    private var manualEntryView: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Enter the barcode number found on the product packaging")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                TextField("Barcode number", text: $manualBarcode)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                    .padding(.horizontal)

                Text("Most barcodes are 12-13 digits")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding(.top, 32)
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showManualEntry = false
                        manualBarcode = ""
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        handleManualEntry()
                    }
                    .disabled(manualBarcode.count < 8)
                }
            }
        }
    }

    // MARK: - Processing Overlay

    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)

                Text("Looking up product...")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Actions

    private func checkPermissionsAndStart() {
        Task {
            let hasPermission = await scannerService.requestCameraPermission()
            if !hasPermission {
                errorMessage = scannerService.lastError?.errorDescription ?? "Camera access denied"
                showError = true
            }
        }
    }

    private func handleBarcodeScan(_ barcode: String) {
        guard !isProcessing else { return }

        // Validate barcode
        guard scannerService.validateBarcode(barcode) else {
            errorMessage = "Invalid barcode format"
            showError = true
            return
        }

        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Normalize and return
        let normalized = scannerService.normalizeBarcode(barcode)
        isProcessing = true

        // Small delay to show the scan success
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onBarcodeScanned(normalized)
        }
    }

    private func handleManualEntry() {
        let normalized = scannerService.normalizeBarcode(manualBarcode)

        if scannerService.validateBarcode(normalized) {
            showManualEntry = false
            onBarcodeScanned(normalized)
        } else {
            errorMessage = "Please enter a valid barcode (8-13 digits)"
            showError = true
        }
    }
}

// MARK: - Data Scanner Representable

struct DataScannerRepresentable: UIViewControllerRepresentable {
    @Binding var recognizedItems: String?
    let onBarcodeScan: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [
                .barcode(symbologies: [
                    .ean13,
                    .ean8,
                    .upce,
                    .code128,
                    .qr
                ])
            ],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )

        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        if !uiViewController.isScanning {
            try? uiViewController.startScanning()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems, onBarcodeScan: onBarcodeScan)
    }

    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        @Binding var recognizedItems: String?
        let onBarcodeScan: (String) -> Void
        private var hasScanned = false

        init(recognizedItems: Binding<String?>, onBarcodeScan: @escaping (String) -> Void) {
            self._recognizedItems = recognizedItems
            self.onBarcodeScan = onBarcodeScan
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            processItem(item)
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard !hasScanned, let item = addedItems.first else { return }
            processItem(item)
        }

        private func processItem(_ item: RecognizedItem) {
            guard !hasScanned else { return }

            switch item {
            case .barcode(let barcode):
                if let payloadString = barcode.payloadStringValue {
                    hasScanned = true
                    recognizedItems = payloadString
                    onBarcodeScan(payloadString)
                }
            default:
                break
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct BarcodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScannerView { barcode in
            print("Scanned: \(barcode)")
        }
    }
}
#endif
