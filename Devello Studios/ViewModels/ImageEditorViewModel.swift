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
        markers = []
    }

    func processSingleEdit() async {
        guard let inputImage else {
            errorMessage = "Please select an image first."
            return
        }

        guard let supabaseManager else {
            errorMessage = "Service not configured."
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
            // Compress image
            guard let imageData = ImageCompression.jpegData(from: inputImage) else {
                throw NSError(domain: "ImageEditorViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
            }

            // Upload to Supabase storage to get public URL
            let storageService = SupabaseStorageService(client: supabaseManager.client)
            let imageURL = try await storageService.uploadImage(data: imageData)

            let hotspot = IOSHotspot(
                x: Double(firstMarker.normalizedPoint.x),
                y: Double(firstMarker.normalizedPoint.y)
            )

            // Call backend (no auth required)
            let response = try await backendService.runSingleEdit(
                imageURL: imageURL.absoluteString,
                hotspot: hotspot,
                prompt: firstMarker.prompt
            )

            // Handle response
            guard response.ok, let outputURLString = response.output_url else {
                throw NSError(domain: "ImageEditorViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: response.error ?? "Processing failed"])
            }

            // Load the output image
            outputImage = try await ImageEngine.loadImage(from: outputURLString)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
