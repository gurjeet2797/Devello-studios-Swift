import Foundation

struct IOSBackendService {
    private let client: APIClient

    init(baseURL: URL = AppConfig.backendBaseURL) {
        client = APIClient(baseURL: baseURL)
    }

    func runLighting(
        imageURL: String,
        style: LightingStyle
    ) async throws -> IOSActionResponse {
        let request = IOSLightingRequest(image_url: imageURL, style: style.rawValue)
        return try await client.sendJSON(
            path: "/api/ios/lighting",
            body: request
        )
    }

    func runSingleEdit(
        imageURL: String,
        hotspot: IOSHotspot,
        prompt: String
    ) async throws -> IOSActionResponse {
        let request = IOSSingleEditRequest(image_url: imageURL, hotspot: hotspot, prompt: prompt)
        return try await client.sendJSON(
            path: "/api/ios/edit",
            body: request
        )
    }
}
