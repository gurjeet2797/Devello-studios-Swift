import SwiftUI

struct HeroSection: View {
    @Environment(\.colorScheme) var colorScheme
    
    private let imageHeight: CGFloat = 400
    private let transitionDuration: Double = 0.4
    
    var body: some View {
        GeometryReader { geometry in
            let minY = geometry.frame(in: .global).minY
            let isOverscrolling = minY > 0
            let stretchHeight = isOverscrolling ? imageHeight + minY : imageHeight
            
            ZStack {
                // Light mode image
                Image("coverimage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: stretchHeight)
                    .clipped()
                    .opacity(colorScheme == .dark ? 0 : 1)
                
                // Dark mode image
                Image("dark_cover")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: stretchHeight)
                    .clipped()
                    .opacity(colorScheme == .dark ? 1 : 0)
                
                // Single adaptive gradient that changes with color scheme
                VStack {
                    Spacer()
                    LinearGradient(
                        stops: [
                            .init(color: Color(.systemBackground), location: 0.0),
                            .init(color: Color(.systemBackground).opacity(0.85), location: 0.25),
                            .init(color: Color(.systemBackground).opacity(0.5), location: 0.5),
                            .init(color: Color(.systemBackground).opacity(0.2), location: 0.75),
                            .init(color: Color.clear, location: 1.0)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 220)
                }
            }
            .animation(.easeInOut(duration: transitionDuration), value: colorScheme)
            .offset(y: isOverscrolling ? -minY : 0)
        }
        .frame(height: imageHeight)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HeroSection()
}
