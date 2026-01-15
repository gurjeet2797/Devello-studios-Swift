import Foundation

enum AppConfig {
    static var supabaseURL: URL {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let url = URL(string: value) else {
            preconditionFailure("Missing SUPABASE_URL in Info.plist")
        }
        return url
    }

    static var supabaseAnonKey: String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
              !value.isEmpty else {
            preconditionFailure("Missing SUPABASE_ANON_KEY in Info.plist")
        }
        return value
    }

    static var backendBaseURL: URL {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "BACKEND_BASE_URL") as? String,
              let url = URL(string: value) else {
            preconditionFailure("Missing BACKEND_BASE_URL in Info.plist")
        }
        return url
    }

    static var magicLinkRedirectURL: URL {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_REDIRECT_URL") as? String,
              let url = URL(string: value) else {
            preconditionFailure("Missing SUPABASE_REDIRECT_URL in Info.plist")
        }
        return url
    }

    static let storageBucket = "images"
}
