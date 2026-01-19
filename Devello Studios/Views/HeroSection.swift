import SwiftUI

struct HeroSection: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    
    private let imageHeight: CGFloat = 400
    private let transitionDuration: Double = 0.4
    
    var body: some View {
        GeometryReader { geometry in
            let minY = geometry.frame(in: .global).minY
            let isOverscrolling = minY > 0
            let stretchHeight = isOverscrolling ? imageHeight + minY : imageHeight
            
            ZStack {
                // Single cover image for all themes
                Image("coverimage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: stretchHeight)
                    .clipped()
                
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
            .offset(y: isOverscrolling ? -minY : 0)
            .animation(scenePhase == .active ? .easeInOut(duration: transitionDuration) : nil, value: colorScheme)
        }
        .frame(height: imageHeight)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HeroSection()
}
