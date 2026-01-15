import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var supabaseManager: SupabaseManager

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var isSendingMagicLink = false
    @State private var magicLinkSent = false
    @State private var errorMessage: String?
    @State private var appleNonce: String?

    var body: some View {
        VStack(spacing: DevelloStyle.Spacing.lg) {
            Text("Sign In")
                .font(DevelloStyle.Fonts.title)

            VStack(spacing: DevelloStyle.Spacing.md) {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password (optional)", text: $password)
                    .textFieldStyle(.roundedBorder)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(DevelloStyle.Fonts.caption)
                    .foregroundStyle(.red)
            }

            VStack(spacing: DevelloStyle.Spacing.md) {
                Button {
                    Task {
                        await signInWithPassword()
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Sign In with Password")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || email.isEmpty || password.isEmpty)

                Button {
                    Task {
                        await sendMagicLink()
                    }
                } label: {
                    if isSendingMagicLink {
                        ProgressView()
                    } else {
                        Text(magicLinkSent ? "Magic Link Sent" : "Send Magic Link")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isSendingMagicLink || email.isEmpty)

                SignInWithAppleButton(.signIn) { request in
                    let nonce = AppleSignInHelper.randomNonceString()
                    appleNonce = nonce
                    request.requestedScopes = [.email, .fullName]
                    request.nonce = AppleSignInHelper.sha256(nonce)
                } onCompletion: { result in
                    Task {
                        await handleAppleSignIn(result: result)
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 48)
                .cornerRadius(8)
            }
        }
        .padding(DevelloStyle.Spacing.lg)
    }

    private func signInWithPassword() async {
        isLoading = true
        errorMessage = nil
        do {
            try await supabaseManager.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func sendMagicLink() async {
        isSendingMagicLink = true
        errorMessage = nil
        magicLinkSent = false
        do {
            try await supabaseManager.sendMagicLink(email: email)
            magicLinkSent = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isSendingMagicLink = false
    }

    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let tokenString = String(data: tokenData, encoding: .utf8) else {
                errorMessage = "Apple Sign In failed to provide a valid token."
                return
            }

            do {
                try await supabaseManager.signInWithApple(idToken: tokenString, nonce: appleNonce)
            } catch {
                errorMessage = error.localizedDescription
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(SupabaseManager())
}
