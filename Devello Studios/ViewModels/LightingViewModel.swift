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

    private var supabaseManager: SupabaseManager?
    private let backendService = IOSBackendService()

    func configure(supabaseManager: SupabaseManager) {
        self.supabaseManager = supabaseManager
    }

    func reset() {
        outputImage = nil
        errorMessage = nil
    }

    func processLighting() async {
        guard let inputImage else {
            errorMessage = "Please select an image first."
            return
        }

        guard let supabaseManager else {
            errorMessage = "Service not configured."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Compress image
            guard let imageData = ImageCompression.jpegData(from: inputImage) else {
                throw NSError(domain: "LightingViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
            }

            // Upload to Supabase storage to get public URL
            let storageService = SupabaseStorageService(client: supabaseManager.client)
            let imageURL = try await storageService.uploadImage(data: imageData)

            // Call backend (no auth required)
            let response = try await backendService.runLighting(
                imageURL: imageURL.absoluteString,
                style: selectedStyle
            )

            // Handle response
            guard response.ok, let outputURLString = response.output_url else {
                throw NSError(domain: "LightingViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: response.error ?? "Processing failed"])
            }

            // Load the output image
            outputImage = try await ImageEngine.loadImage(from: outputURLString)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
