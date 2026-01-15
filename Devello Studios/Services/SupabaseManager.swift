import Foundation
import Supabase
import Combine

@MainActor
final class SupabaseManager: ObservableObject {
    @Published private(set) var session: Session?

    let client: SupabaseClient

    init() {
        client = SupabaseClient(
            supabaseURL: AppConfig.supabaseURL,
            supabaseKey: AppConfig.supabaseAnonKey,
            options: SupabaseClientOptions(
                auth: .init(emitLocalSessionAsInitialSession: true)
            )
        )
    }

    var accessToken: String? {
        session?.accessToken
    }

    func restoreSession() async {
        do {
            session = try await client.auth.session
        } catch {
            session = nil
        }
    }

    func signIn(email: String, password: String) async throws {
        session = try await client.auth.signIn(email: email, password: password)
    }

    func sendMagicLink(email: String) async throws {
        try await client.auth.signInWithOTP(
            email: email,
            redirectTo: AppConfig.magicLinkRedirectURL
        )
    }

    func signInWithApple(idToken: String, nonce: String?) async throws {
        session = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
    }

    func handleAuthCallback(url: URL) async {
        do {
            session = try await client.auth.session(from: url)
        } catch {
            // Ignore invalid callback URLs
        }
    }

    func signOut() async {
        do {
            try await client.auth.signOut()
        } catch {
            // Ignore sign out errors
        }
        session = nil
    }
}
