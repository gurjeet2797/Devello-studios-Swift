import Foundation

enum LightingStyle: String, CaseIterable, Identifiable {
    case dramaticDaylight = "Dramatic Daylight"
    case middayBright = "Midday Bright"
    case cozyEvening = "Cozy Evening"

    var id: String { rawValue }
}

struct IOSLightingRequest: Encodable {
    let image_url: String
    let style: String
}

struct IOSSingleEditRequest: Encodable {
    let image_url: String
    let hotspot: IOSHotspot
    let prompt: String
}

struct IOSHotspot: Codable {
    let x: Double
    let y: Double
}

struct IOSJobResponse: Decodable {
    let ok: Bool
    let status: String?
    let output_url: String?
    let request_id: String?
    let job_id: String?
    let error: String?
    let code: String?
}

struct IOSActionResponse: Decodable {
    let ok: Bool
    let status: String?
    let output_url: String?
    let input_url: String?
    let request_id: String?
    let job_id: String?
    let model: String?
    let error: String?
    let code: String?
}
