import Foundation

enum LightingStyle: String, CaseIterable, Identifiable {
    case dramaticDaylight = "Dramatic Daylight"
    case middayBright = "Midday Bright"
    case cozyEvening = "Cozy Evening"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dramaticDaylight:
            return "Daylight"
        case .middayBright:
            return "Midday"
        case .cozyEvening:
            return "Evening"
        }
    }

    var icon: String {
        switch self {
        case .dramaticDaylight:
            return "sun.max.fill"
        case .middayBright:
            return "sun.min.fill"
        case .cozyEvening:
            return "moon.fill"
        }
    }
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

struct IOSIdeaSparkRequest: Encodable {
    let idea: String
}

struct IOSIdeaSparkResponse: Decodable {
    let ok: Bool
    let draft: String?
    let error: String?
}
