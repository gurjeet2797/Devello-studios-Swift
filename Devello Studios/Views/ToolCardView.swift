import SwiftUI

struct ToolCardView: View {
    let title: String
    let subtitle: String
    let backgroundImage: String?
    let systemImage: String?

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
        ZStack(alignment: .bottom) {
            if let backgroundImage {
                Image(backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .overlay(Color.black.opacity(0.2))
            } else {
                RoundedRectangle(cornerRadius: DevelloStyle.CornerRadius.lg)
                    .fill(Color(.secondarySystemBackground))
            }

            VStack(alignment: .leading, spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .semibold))
                }

                Text(title)
                    .font(DevelloStyle.Fonts.subtitle)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(DevelloStyle.Fonts.body)
                    .fontWeight(.regular)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DevelloStyle.Spacing.lg)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DevelloStyle.CornerRadius.lg, style: .continuous))
        }
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: DevelloStyle.CornerRadius.lg))
    }
}

#Preview {
    ToolCardView(title: "Lighting Studio", subtitle: "Relight your image", backgroundImage: "lightingtool", systemImage: "lightbulb")
        .padding()
}
