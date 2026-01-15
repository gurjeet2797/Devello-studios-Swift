import SwiftUI

struct FloatingMenuView: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @Binding var isShowing: Bool

    @State private var showingSignIn = false

    var body: some View {
        VStack(alignment: .trailing, spacing: DevelloStyle.Spacing.md) {
            Spacer()

            VStack(alignment: .trailing, spacing: DevelloStyle.Spacing.md) {
                NavigationLink {
                    LightingView()
                } label: {
                    Text("Relight App")
                        .frame(width: 160, height: 44)
                }
                .buttonStyle(.glass)
                .tint(.yellow)

                NavigationLink {
                    ImageEditorView()
                } label: {
                    Text("Image Editor")
                        .frame(width: 160, height: 44)
                }
                .buttonStyle(.glass)
                .tint(.purple)

                Button("Product Editor") { }
                    .frame(width: 160, height: 44)
                    .buttonStyle(.glass)
                    .tint(.mint)
                    .disabled(true)

                Button(supabaseManager.session == nil ? "Sign In" : "Sign Out") {
                    if supabaseManager.session == nil {
                        showingSignIn = true
                    } else {
                        Task { await supabaseManager.signOut() }
                    }
                }
                .frame(width: 160, height: 44)
                .buttonStyle(.glass)
                .tint(.blue)
            }
        }
        .padding(.trailing, DevelloStyle.Spacing.lg)
        .padding(.top, 120)
        .padding(.bottom, 80)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .offset(x: isShowing ? 0 : 220)
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
