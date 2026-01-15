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
    @Published var lastRequestId: String?

    private var supabaseManager: SupabaseManager?
    private let backendService = IOSBackendService()

    func configure(supabaseManager: SupabaseManager) {
        self.supabaseManager = supabaseManager
    }

    func reset() {
        outputImage = nil
        errorMessage = nil
        lastRequestId = nil
    }

    func processLighting() async {
        guard let inputImage else {
            errorMessage = "Please select an image first."
            return
        }

        guard let accessToken = supabaseManager?.accessToken else {
            errorMessage = "Please sign in to continue."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            guard let imageData = ImageCompression.jpegData(from: inputImage) else {
                throw NSError(domain: "LightingViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
            }

            let storageService = SupabaseStorageService(client: supabaseManager!.client)
            let imageURL = try await storageService.uploadImage(data: imageData)

            let response = try await backendService.runLighting(
                imageURL: imageURL.absoluteString,
                style: selectedStyle,
                bearerToken: accessToken
            )

            let finalURL = try await resolveOutputURL(from: response, bearerToken: accessToken)
            outputImage = try await ImageEngine.loadImage(from: finalURL)
            lastRequestId = response.request_id
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func resolveOutputURL(from response: IOSActionResponse, bearerToken: String) async throws -> URL {
        if let output = response.output_url, let url = URL(string: output) {
            return url
        }

        if response.status == "processing", let jobId = response.job_id ?? response.request_id {
            return try await pollJob(jobId: jobId, bearerToken: bearerToken)
        }

        throw NSError(domain: "LightingViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve output image"])
    }

    private func pollJob(jobId: String, bearerToken: String) async throws -> URL {
        var attempt = 0
        while attempt < 30 {
            let result = try await backendService.pollJob(jobId: jobId, bearerToken: bearerToken)
            if let output = result.output_url, let url = URL(string: output) {
                return url
            }
            if result.status != "processing" {
                throw NSError(domain: "LightingViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: result.error ?? "Job failed"])
            }
            attempt += 1
            try await Task.sleep(nanoseconds: 2_000_000_000)
        }
        throw NSError(domain: "LightingViewModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "Processing timed out"])
    }
}
