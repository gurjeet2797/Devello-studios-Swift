import Foundation

struct IdeaService {
    let supabaseURL: URL
    let supabaseAnonKey: String
    let accessToken: String?

    func submitIdea(
        text: String,
        source: String = "ios",
        status: String = "submitted",
        userId: String? = nil
    ) async throws -> Idea {
        let endpoint = supabaseURL.appendingPathComponent("rest/v1/ideas")
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "select", value: "*")]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        if let accessToken, !accessToken.isEmpty {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        let payload = IdeaInsert(text: text, status: status, source: source, userId: userId)
        request.httpBody = try JSONEncoder().encode([payload])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            let message = parseRestErrorMessage(data: data) ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw NSError(domain: "IdeaService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let ideas = try decoder.decode([Idea].self, from: data)
        guard let idea = ideas.first else {
            throw NSError(domain: "IdeaService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No idea returned from server"]) 
        }

        return idea
    }

    func fetchIdeas(limit: Int = 50) async throws -> [Idea] {
        let endpoint = supabaseURL.appendingPathComponent("rest/v1/ideas")
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: "order", value: "created_at.desc"),
            URLQueryItem(name: "limit", value: String(limit))
        ]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        if let accessToken, !accessToken.isEmpty {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            let message = parseRestErrorMessage(data: data) ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw NSError(domain: "IdeaService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Idea].self, from: data)
    }

    private func parseRestErrorMessage(data: Data) -> String? {
        struct RestError: Decodable {
            let message: String?
        }
        return try? JSONDecoder().decode(RestError.self, from: data).message
    }
}
