import SwiftUI

struct FloatingMenuView: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @Binding var isShowing: Bool

    @State private var showingSignIn = false

    var body: some View {
        VStack(alignment: .trailing, spacing: DevelloStyle.Spacing.sm) {
            NavigationLink {
                LightingView()
            } label: {
                Text("Relight App")
                    .font(DevelloStyle.Fonts.body)
                    .frame(width: 150, height: 40)
            }
            .buttonStyle(.glass)

            NavigationLink {
                ImageEditorView()
            } label: {
                Text("Image Editor")
                    .font(DevelloStyle.Fonts.body)
                    .frame(width: 150, height: 40)
            }
            .buttonStyle(.glass)

            Button(supabaseManager.session == nil ? "Sign In" : "Sign Out") {
                if supabaseManager.session == nil {
                    showingSignIn = true
                } else {
                    Task { await supabaseManager.signOut() }
                }
            }
            .font(DevelloStyle.Fonts.body)
            .frame(width: 150, height: 40)
            .buttonStyle(.glass)
        }
        .padding(.trailing, DevelloStyle.Spacing.lg)
        .padding(.top, 70)
        .frame(maxWidth: .infinity, alignment: .topTrailing)
        .offset(x: isShowing ? 0 : 200)
        .animation(.easeInOut(duration: 0.3), value: isShowing)
        .sheet(isPresented: $showingSignIn) {
            SignInView()
                .environmentObject(supabaseManager)
        }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color.white.ignoresSafeArea()
            FloatingMenuView(isShowing: .constant(true))
                .environmentObject(SupabaseManager())
        }
    }
}
