import Foundation

enum LightingStyle: String, CaseIterable, Identifiable {
    case dramaticDaylight = "Dramatic Daylight"
    case middayBright = "Midday Bright"
    case cozyEvening = "Cozy Evening"

    var id: String { rawValue }
}

struct IOSLightingRequest: Encodable {
    let image_base64: String
    let style: String
}

struct IOSSingleEditRequest: Encodable {
    let image_base64: String
    let hotspot: IOSHotspot
    let prompt: String
}

struct IOSHotspot: Codable {
    let x: Double
    let y: Double
}

struct IOSActionResponse: Decodable {
    let ok: Bool
    let image_base64: String?
    let error: String?
}
