import SwiftUI

struct FloatingMenuView: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @Binding var isShowing: Bool

    @State private var showingSignIn = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            NavigationLink {
                LightingView()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Lighting Studio")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .glassEffect(.clear.interactive(), in: Capsule())
            .simultaneousGesture(TapGesture().onEnded {
                withAnimation { isShowing = false }
            })

            NavigationLink {
                ImageEditorView()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Image Editor")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .glassEffect(.clear.interactive(), in: Capsule())
            .simultaneousGesture(TapGesture().onEnded {
                withAnimation { isShowing = false }
            })

            Button {
                if supabaseManager.session == nil {
                    showingSignIn = true
                } else {
                    Task { await supabaseManager.signOut() }
                }
                withAnimation { isShowing = false }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: supabaseManager.session == nil ? "person.fill" : "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                    Text(supabaseManager.session == nil ? "Sign In" : "Sign Out")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .glassEffect(.clear.interactive(), in: Capsule())
        }
        .padding(.trailing, 20)
        .padding(.top, 80)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .opacity(isShowing ? 1 : 0)
        .offset(x: isShowing ? 0 : 50)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isShowing)
        .sheet(isPresented: $showingSignIn) {
            SignInView()
                .environmentObject(supabaseManager)
        }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color.gray.opacity(0.2).ignoresSafeArea()
            FloatingMenuView(isShowing: .constant(true))
                .environmentObject(SupabaseManager())
        }
    }
}
