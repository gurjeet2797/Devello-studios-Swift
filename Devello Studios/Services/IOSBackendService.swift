import Foundation

struct IOSBackendService {
    private let client: APIClient

    init(baseURL: URL = AppConfig.backendBaseURL) {
        client = APIClient(baseURL: baseURL)
    }

    func runLighting(
        imageURL: String,
        style: LightingStyle,
        bearerToken: String?
    ) async throws -> IOSActionResponse {
        let request = IOSLightingRequest(image_url: imageURL, style: style.rawValue)
        return try await client.sendJSON(
            path: "/api/ios/lighting",
            body: request,
            bearerToken: bearerToken
        )
    }

    func runSingleEdit(
        imageURL: String,
        hotspot: IOSHotspot,
        prompt: String,
        bearerToken: String?
    ) async throws -> IOSActionResponse {
        let request = IOSSingleEditRequest(image_url: imageURL, hotspot: hotspot, prompt: prompt)
        return try await client.sendJSON(
            path: "/api/ios/edit",
            body: request,
            bearerToken: bearerToken
        )
    }

    func pollJob(jobId: String, bearerToken: String?) async throws -> IOSJobResponse {
        return try await client.get(
            path: "/api/ios/jobs/\(jobId)",
            bearerToken: bearerToken
        )
    }
}
