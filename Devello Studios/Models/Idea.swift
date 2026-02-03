import Foundation

struct Idea: Identifiable, Codable {
    let id: UUID
    let text: String
    let status: String?
    let source: String?
    let createdAt: Date?
    let userId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case status
        case source
        case createdAt = "created_at"
        case userId = "user_id"
    }
}

struct IdeaInsert: Encodable {
    let text: String
    let status: String
    let source: String
    let userId: String?

    enum CodingKeys: String, CodingKey {
        case text
        case status
        case source
        case userId = "user_id"
    }
}
