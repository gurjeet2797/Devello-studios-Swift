import UIKit
import Photos

enum ImageEngine {
    static func loadImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        return image
    }

    /// Load image from either a regular URL or a data URL (base64)
    static func loadImage(from urlString: String) async throws -> UIImage {
        // Handle data URLs (e.g., "data:image/png;base64,...")
        if urlString.hasPrefix("data:") {
            return try loadImageFromDataURL(urlString)
        }

        // Handle regular URLs
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        return try await loadImage(from: url)
    }

    private static func loadImageFromDataURL(_ dataURL: String) throws -> UIImage {
        // Parse data URL: "data:image/png;base64,..."
        guard let commaIndex = dataURL.firstIndex(of: ",") else {
            throw URLError(.cannotDecodeContentData)
        }

        let base64String = String(dataURL[dataURL.index(after: commaIndex)...])
        guard let imageData = Data(base64Encoded: base64String) else {
            throw URLError(.cannotDecodeContentData)
        }

        guard let image = UIImage(data: imageData) else {
            throw URLError(.cannotDecodeContentData)
        }

        return image
    }

    static func saveToPhotos(_ image: UIImage) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
                guard status == .authorized || status == .limited else {
            throw NSError(
                        domain: "ImageEngine",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"]
            )
                }

        try await PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
}
