import Foundation
import UIKit
import Combine

struct EditMarker: Identifiable, Equatable {
    let id: UUID
    var normalizedPoint: CGPoint
    var prompt: String

    init(id: UUID = UUID(), normalizedPoint: CGPoint, prompt: String = "") {
        self.id = id
        self.normalizedPoint = normalizedPoint
        self.prompt = prompt
    }
}

@MainActor
final class ImageEditorViewModel: ObservableObject {
    @Published var inputImage: UIImage?
    @Published var outputImage: UIImage?
    @Published var markers: [EditMarker] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedMarkerId: UUID?
    @Published var lastRequestId: String?

    private var supabaseManager: SupabaseManager?
    private let backendService = IOSBackendService()

    func configure(supabaseManager: SupabaseManager) {
        self.supabaseManager = supabaseManager
    }

    func addMarker(at normalizedPoint: CGPoint) {
        if markers.isEmpty {
            markers.append(EditMarker(normalizedPoint: normalizedPoint))
            selectedMarkerId = markers.first?.id
        } else {
            markers[0] = EditMarker(id: markers[0].id, normalizedPoint: normalizedPoint, prompt: markers[0].prompt)
            selectedMarkerId = markers[0].id
        }
    }

    func updatePrompt(for markerId: UUID, prompt: String) {
        guard let index = markers.firstIndex(where: { $0.id == markerId }) else { return }
        markers[index].prompt = prompt
    }

    func removeMarker(_ markerId: UUID) {
        markers.removeAll { $0.id == markerId }
        if selectedMarkerId == markerId {
            selectedMarkerId = nil
        }
    }

    func resetEdits() {
        outputImage = nil
        errorMessage = nil
        lastRequestId = nil
        markers = []
    }

    func processSingleEdit() async {
        guard let inputImage else {
            errorMessage = "Please select an image first."
            return
        }

        guard let accessToken = supabaseManager?.accessToken else {
            errorMessage = "Please sign in to continue."
            return
        }

        guard let firstMarker = markers.first else {
            errorMessage = "Please add a hotspot."
            return
        }

        guard !firstMarker.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a prompt for the hotspot."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            guard let imageData = ImageCompression.jpegData(from: inputImage) else {
                throw NSError(domain: "ImageEditorViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
            }

            let storageService = SupabaseStorageService(client: supabaseManager!.client)
            let imageURL = try await storageService.uploadImage(data: imageData)

            let hotspot = IOSHotspot(
                x: Double(firstMarker.normalizedPoint.x),
                y: Double(firstMarker.normalizedPoint.y)
            )

            let response = try await backendService.runSingleEdit(
                imageURL: imageURL.absoluteString,
                hotspot: hotspot,
                prompt: firstMarker.prompt,
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

        throw NSError(domain: "ImageEditorViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve output image"])
    }

    private func pollJob(jobId: String, bearerToken: String) async throws -> URL {
        var attempt = 0
        while attempt < 30 {
            let result = try await backendService.pollJob(jobId: jobId, bearerToken: bearerToken)
            if let output = result.output_url, let url = URL(string: output) {
                return url
            }
            if result.status != "processing" {
                throw NSError(domain: "ImageEditorViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: result.error ?? "Job failed"])
            }
            attempt += 1
            try await Task.sleep(nanoseconds: 2_000_000_000)
        }
        throw NSError(domain: "ImageEditorViewModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "Processing timed out"])
    }
}
