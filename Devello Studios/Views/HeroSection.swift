import SwiftUI

struct HeroSection: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("coverimage")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 320)
                .clipped()
                .ignoresSafeArea(edges: .top)

            // Vignetting effect
            RadialGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.3)
                ],
                center: .center,
                startRadius: 100,
                endRadius: 400
            )

            // Adaptive bottom gradient based on color scheme
            LinearGradient(
                colors: colorScheme == .dark ? [
                    Color.black.opacity(0.8),
                    Color.black.opacity(0.0)
                ] : [
                    Color.white.opacity(0.8),
                    Color.white.opacity(0.0)
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 160)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HeroSection()
}
