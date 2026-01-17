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

    private let backendService = IOSBackendService()

    func reset() {
        outputImage = nil
        errorMessage = nil
    }

    func processLighting() async {
        guard let inputImage else {
            errorMessage = "Please select an image first."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Compress image to JPEG and convert to base64
            guard let imageData = ImageCompression.jpegData(from: inputImage) else {
                throw NSError(domain: "LightingViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
            }
            let base64String = imageData.base64EncodedString()

            // Call backend with base64 data
            let response = try await backendService.runLighting(
                imageBase64: base64String,
                style: selectedStyle
            )

            // Handle response
            guard response.ok, let outputBase64 = response.image_base64 else {
                throw NSError(domain: "LightingViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: response.error ?? "Processing failed"])
            }

            // Convert base64 response to UIImage
            guard let outputData = Data(base64Encoded: outputBase64),
                  let output = UIImage(data: outputData) else {
                throw NSError(domain: "LightingViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to decode output image"])
            }

            outputImage = output
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
