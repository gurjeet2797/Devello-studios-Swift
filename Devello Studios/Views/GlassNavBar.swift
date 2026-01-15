import SwiftUI

struct GlassNavBar: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @Binding var isMenuOpen: Bool
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        HStack(spacing: DevelloStyle.Spacing.md) {
            Image("devellologo")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .padding(8)
                .glassEffect(.regular.interactive(), in: Circle())

            Text("home")
                .font(.custom("Snell Roundhand", size: 18))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .glassEffect(.regular.interactive(), in: Capsule())

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isDarkMode.toggle()
                }
            } label: {
                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 36, height: 36)
            }
            .glassEffect(.regular.interactive(), in: Circle())

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isMenuOpen.toggle()
                }
            } label: {
                Image(systemName: isMenuOpen ? "xmark" : "line.3.horizontal")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 36, height: 36)
            }
            .glassEffect(.regular.interactive(), in: Circle())
        }
        .padding(.horizontal, DevelloStyle.Spacing.lg)
        .padding(.top, DevelloStyle.Spacing.md)
        .padding(.bottom, DevelloStyle.Spacing.sm)
    }
}

#Preview {
    GlassNavBar(isMenuOpen: .constant(false))
        .environmentObject(SupabaseManager())
}
