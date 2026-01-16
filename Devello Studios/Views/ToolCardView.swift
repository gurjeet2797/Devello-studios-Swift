import SwiftUI

struct ToolCardView: View {
    let title: String
    let subtitle: String
    let backgroundImage: String?
    let systemImage: String?
    
    private let cardHeight: CGFloat = 480
    
    init(
        title: String,
        subtitle: String,
        backgroundImage: String? = nil,
        systemImage: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.backgroundImage = backgroundImage
        self.systemImage = systemImage
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image
            if let backgroundImage {
                Image(backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: cardHeight)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color(.tertiarySystemFill))
                    .frame(height: cardHeight)
            }
            
            // Glass text overlay at bottom
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.white.opacity(0.25))
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            }
        }
        .frame(height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 40))
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ToolCardView(
                title: "Lighting Studio",
                subtitle: "Pick a time of day and let the sun be your lighting director",
                backgroundImage: "lightingtool"
            )
            
            ToolCardView(
                title: "Image Editor",
                subtitle: "Edit a single hotspot with AI guidance",
                backgroundImage: "editortool"
            )
        }
        .padding(.horizontal, 20)
    }
}
