import Foundation

struct IOSBackendService {
    private let client: APIClient

    init(baseURL: URL = AppConfig.backendBaseURL) {
        client = APIClient(baseURL: baseURL)
    }

    func runLighting(
        imageBase64: String,
        style: LightingStyle
    ) async throws -> IOSActionResponse {
        let request = IOSLightingRequest(image_base64: imageBase64, style: style.rawValue)
        return try await client.sendJSON(
            path: "/api/ios/lighting",
            body: request
        )
    }

    func runSingleEdit(
        imageBase64: String,
        hotspot: IOSHotspot,
        prompt: String
    ) async throws -> IOSActionResponse {
        let request = IOSSingleEditRequest(image_base64: imageBase64, hotspot: hotspot, prompt: prompt)
        return try await client.sendJSON(
            path: "/api/ios/edit",
            body: request
        )
    }
}
