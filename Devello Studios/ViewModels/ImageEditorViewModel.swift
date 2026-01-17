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

    private let backendService = IOSBackendService()

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
            // Compress image to JPEG and convert to base64
            guard let imageData = ImageCompression.jpegData(from: inputImage) else {
                throw NSError(domain: "ImageEditorViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
            }
            let base64String = imageData.base64EncodedString()

            let hotspot = IOSHotspot(
                x: Double(firstMarker.normalizedPoint.x),
                y: Double(firstMarker.normalizedPoint.y)
            )

            // Call backend with base64 data
            let response = try await backendService.runSingleEdit(
                imageBase64: base64String,
                hotspot: hotspot,
                prompt: firstMarker.prompt
            )

            // Handle response
            guard response.ok, let outputBase64 = response.image_base64 else {
                throw NSError(domain: "ImageEditorViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: response.error ?? "Processing failed"])
            }

            // Convert base64 response to UIImage
            guard let outputData = Data(base64Encoded: outputBase64),
                  let output = UIImage(data: outputData) else {
                throw NSError(domain: "ImageEditorViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to decode output image"])
            }

            outputImage = output
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
