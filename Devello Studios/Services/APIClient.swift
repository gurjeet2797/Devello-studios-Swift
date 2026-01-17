import Foundation

struct APIClient {
    let baseURL: URL

    func sendJSON<Request: Encodable, Response: Decodable>(
        path: String,
        method: String = "POST",
        body: Request
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            let apiError = try? JSONDecoder().decode(IOSActionResponse.self, from: data)
            let message = apiError?.error ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw NSError(domain: "APIClient", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }

        return try JSONDecoder().decode(Response.self, from: data)
    }
}
