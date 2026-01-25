//
//  ReceiptScanner.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/18/26.
//

import SwiftUI
import Vision
import PhotosUI
import UniformTypeIdentifiers

/// A single drink item extracted from a receipt
struct ParsedReceiptItem: Equatable, Identifiable {
    var id = UUID()
    var drinkName: String
    var price: Double?
    var size: DrinkSize?
    var sugarLevel: SugarLevel?
    var iceLevel: IceLevel?
    var bubbleLevel: BubbleLevel?
    
    var displayDescription: String {
        var parts: [String] = []
        if let size = size {
            parts.append(size.localizedName)
        }
        if let sugar = sugarLevel {
            parts.append(sugar.localizedName)
        }
        if let ice = iceLevel {
            parts.append(ice.localizedName)
        }
        if let bubble = bubbleLevel {
            parts.append(bubble.localizedName)
        }
        if let price = price {
            parts.append(String(format: "$%.2f", price))
        }
        return parts.isEmpty ? drinkName : "\(drinkName) • \(parts.joined(separator: " • "))"
    }
}

/// Result from scanning and parsing a receipt
struct ParsedReceipt: Equatable {
    var brandName: String?           // Detected brand name from receipt
    var matchedBrandName: String?    // Matched to existing brand in database
    var items: [ParsedReceiptItem]   // Array of drink items found
    var totalPrice: Double?          // Total price if found
    var rawText: String
    
    var hasAnyData: Bool {
        brandName != nil || !items.isEmpty || totalPrice != nil
    }
    
    /// For backward compatibility - returns the first item's data
    var firstItem: ParsedReceiptItem? {
        items.first
    }
}

// MARK: - Receipt Processing Service

/// Result type for receipt processing that includes error information
struct ReceiptProcessingResult {
    var receipt: ParsedReceipt
    var usedFallback: Bool
    var error: Error?
}

/// Unified service for processing receipt images
/// Uses Gemini API as primary method with Vision OCR as fallback
class ReceiptProcessingService {
    
    /// Process a receipt image using Gemini API with OCR fallback
    /// - Parameter image: The receipt image to process
    /// - Returns: ReceiptProcessingResult with parsed data and processing info
    static func processImage(_ image: UIImage) async -> ReceiptProcessingResult {
        // Try Gemini first if configured
        if GeminiConfig.isConfigured {
            do {
                let receipt = try await GeminiService.processReceiptImage(image)
                print("Receipt processed successfully with Gemini API")
                
                // Decrement free scan count after successful Gemini API usage
                await MainActor.run {
                    FreeUsageManager.shared.useOneScan()
                }
                
                return ReceiptProcessingResult(receipt: receipt, usedFallback: false, error: nil)
            } catch {
                print("Gemini API failed: \(error.localizedDescription), falling back to OCR")
                // Fall through to OCR fallback
            }
        } else {
            print("Gemini API not configured, using OCR fallback")
        }
        
        // Fallback to Vision OCR (free - doesn't count against limit)
        let receipt = await ReceiptOCRService.processImage(image)
        return ReceiptProcessingResult(receipt: receipt, usedFallback: true, error: nil)
    }
}

// MARK: - Receipt OCR Service (Fallback)

/// Vision-based OCR service for processing receipt images (used as fallback)
class ReceiptOCRService {
    private static let parser = ReceiptParser()
    
    /// Performs OCR on the image and returns parsed receipt data
    static func processImage(_ image: UIImage) async -> ParsedReceipt {
        let text = await performOCR(on: image)
        return parser.parse(text)
    }
    
    /// Performs OCR on the image using Vision framework with bilingual support
    static func performOCR(on image: UIImage) async -> String {
        guard let cgImage = image.cgImage else { return "" }
        
        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    print("OCR error: \(error.localizedDescription)")
                    continuation.resume(returning: "")
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                
                // Sort observations by vertical position (top to bottom)
                let sortedObservations = observations.sorted {
                    $0.boundingBox.minY > $1.boundingBox.minY
                }
                
                // Extract text from observations
                let recognizedStrings = sortedObservations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                let fullText = recognizedStrings.joined(separator: "\n")
                continuation.resume(returning: fullText)
            }
            
            // Configure for accurate recognition with bilingual support
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            // Support English, Simplified Chinese, and Traditional Chinese
            request.recognitionLanguages = ["en-US", "zh-Hans", "zh-Hant"]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform OCR: \(error.localizedDescription)")
                continuation.resume(returning: "")
            }
        }
    }
}

// MARK: - Camera Scanner (Single Shot)

/// SwiftUI wrapper for UIImagePickerController - simple single-shot camera for receipt scanning
struct ReceiptScannerView: UIViewControllerRepresentable {
    @Binding var parsedReceipt: ParsedReceipt?
    @Binding var isProcessing: Bool
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No dynamic updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ReceiptScannerView
        
        init(_ parent: ReceiptScannerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.isProcessing = true
            parent.dismiss()
            
            // Get the captured image
            guard let image = info[.originalImage] as? UIImage else {
                parent.isProcessing = false
                return
            }
            
            // Process using Gemini with OCR fallback
            Task {
                let result = await ReceiptProcessingService.processImage(image)
                
                await MainActor.run {
                    parent.parsedReceipt = result.receipt
                    parent.isProcessing = false
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Photo Library Picker

/// SwiftUI wrapper for PHPickerViewController to select receipt images from photo library
struct ReceiptPhotoPickerView: UIViewControllerRepresentable {
    @Binding var parsedReceipt: ParsedReceipt?
    @Binding var isProcessing: Bool
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No dynamic updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ReceiptPhotoPickerView
        
        init(_ parent: ReceiptPhotoPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Dismiss picker first
            parent.dismiss()
            
            guard let result = results.first else {
                return
            }
            
            parent.isProcessing = true
            
            // Load the image
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Failed to load image: \(error.localizedDescription)")
                    Task { @MainActor in
                        self.parent.isProcessing = false
                    }
                    return
                }
                
                guard let image = object as? UIImage else {
                    Task { @MainActor in
                        self.parent.isProcessing = false
                    }
                    return
                }
                
                // Process using Gemini with OCR fallback
                Task {
                    let result = await ReceiptProcessingService.processImage(image)
                    
                    await MainActor.run {
                        self.parent.parsedReceipt = result.receipt
                        self.parent.isProcessing = false
                    }
                }
            }
        }
    }
}

// MARK: - File Picker

/// SwiftUI wrapper for UIDocumentPickerViewController to select receipt images from Files
struct ReceiptFilePickerView: UIViewControllerRepresentable {
    @Binding var parsedReceipt: ParsedReceipt?
    @Binding var isProcessing: Bool
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Allow image file types
        let supportedTypes: [UTType] = [.image, .jpeg, .png, .heic, .heif]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No dynamic updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: ReceiptFilePickerView
        
        init(_ parent: ReceiptFilePickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                return
            }
            
            parent.isProcessing = true
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access security-scoped resource")
                parent.isProcessing = false
                return
            }
            
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            // Load image from URL
            guard let imageData = try? Data(contentsOf: url),
                  let image = UIImage(data: imageData) else {
                print("Failed to load image from file")
                Task { @MainActor in
                    self.parent.isProcessing = false
                }
                return
            }
            
            // Process using Gemini with OCR fallback
            Task {
                let result = await ReceiptProcessingService.processImage(image)
                
                await MainActor.run {
                    self.parent.parsedReceipt = result.receipt
                    self.parent.isProcessing = false
                }
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // User cancelled - no action needed
        }
    }
}

// MARK: - Helper Functions

/// Check if camera is available for receipt scanning
func isCameraScanningSupported() -> Bool {
    UIImagePickerController.isSourceTypeAvailable(.camera)
}
