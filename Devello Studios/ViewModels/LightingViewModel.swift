import Foundation
import UIKit
import Combine

@MainActor
final class LightingViewModel: ObservableObject {
    @Published var inputImage: UIImage?
    @Published var outputImage: UIImage?
    @Published var selectedStyle: LightingStyle = .dramaticDaylight
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAfterImage = true

    private let backendService = IOSBackendService()

    func reset() {
        outputImage = nil
        errorMessage = nil
        showingAfterImage = true
    }

    func toggleBeforeAfter() {
        showingAfterImage.toggle()
    }

    func processLighting() async {
        guard let inputImage else {
            errorMessage = "Please select an image first."
            return
        }

        isLoading = true
        errorMessage = nil
        outputImage = nil
        showingAfterImage = true

        do {
            // Compress image to JPEG and convert to base64 off the main thread
            let base64String = try await Task.detached(priority: .userInitiated) { () -> String in
                guard let imageData = ImageCompression.jpegData(from: inputImage) else {
                    throw NSError(domain: "LightingViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
                }
                return imageData.base64EncodedString()
            }.value

            // Call backend with base64 data
            let response = try await backendService.runLighting(
                imageBase64: base64String,
                style: selectedStyle
            )

            // Handle response
            guard response.ok, let outputBase64 = response.image_base64 else {
                throw NSError(domain: "LightingViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: response.error ?? "Processing failed"])
            }

            // Convert base64 response to UIImage with safe resizing off the main thread
            let output = try await Task.detached(priority: .userInitiated) { () -> UIImage in
                guard let outputData = Data(base64Encoded: outputBase64) else {
                    throw NSError(domain: "LightingViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to decode base64 data"])
                }
                guard let image = ImageCompression.safeImageFromData(outputData) else {
                    throw NSError(domain: "LightingViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to decode output image"])
                }
                return image
            }.value

            outputImage = output
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
