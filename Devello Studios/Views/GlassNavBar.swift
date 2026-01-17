import SwiftUI

struct GlassNavBar: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @Binding var isMenuOpen: Bool
    @AppStorage("isDarkMode") private var isDarkMode = false
    var onLogoTapped: (() -> Void)?
    
    init(isMenuOpen: Binding<Bool>, onLogoTapped: (() -> Void)? = nil) {
        self._isMenuOpen = isMenuOpen
        self.onLogoTapped = onLogoTapped
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                onLogoTapped?()
            } label: {
                Image("devellologo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            .frame(width: 40, height: 40)
            .glassEffect(.clear.interactive(), in: Circle())

            Spacer()

            Button {
                isDarkMode.toggle()
            } label: {
                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isDarkMode ? .white : .black)
                    .contentTransition(.symbolEffect(.replace))
            }
            .frame(width: 40, height: 40)
            .glassEffect(.clear.interactive(), in: Circle())

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isMenuOpen.toggle()
                }
            } label: {
                Image(systemName: isMenuOpen ? "xmark" : "line.3.horizontal")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isDarkMode ? .white : .black)
                    .contentTransition(.symbolEffect(.replace))
            }
            .frame(width: 40, height: 40)
            .glassEffect(.clear.interactive(), in: Circle())
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
