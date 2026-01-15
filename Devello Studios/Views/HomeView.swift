import SwiftUI

struct HomeView: View {
    @State private var isMenuOpen = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(alignment: .leading, spacing: DevelloStyle.Spacing.xl) {
                        HeroSection()
                            .padding(.top, 8)

                        Button {
                            // Hook up later
                        } label: {
                            Text("Create")
                                .font(DevelloStyle.Fonts.subtitle)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                        .glassEffect(.regular.tint(.blue), in: Capsule())
                        .frame(maxWidth: .infinity, alignment: .center)

                        VStack(alignment: .leading, spacing: DevelloStyle.Spacing.md) {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("Apps.")
                                    .font(.system(size: 34, weight: .bold))

                                Text("Try our in-house tools")
                                    .font(DevelloStyle.Fonts.body)
                                    .foregroundStyle(.secondary)
                            }

                            Text("Advanced lighting simulation and AI-powered image editing tools for designers.")
                                .font(DevelloStyle.Fonts.body)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, DevelloStyle.Spacing.lg)

                        VStack(spacing: DevelloStyle.Spacing.lg) {
                            NavigationLink {
                                LightingView()
                            } label: {
                                ToolCardView(
                                    title: "Lighting Studio",
                                    subtitle: "Pick a time of day and let the sun be your lighting director",
                                    backgroundImage: "lightingtool"
                                )
                            }

                            NavigationLink {
                                ImageEditorView()
                            } label: {
                                ToolCardView(
                                    title: "Image Editor",
                                    subtitle: "Edit a single hotspot with AI guidance",
                                    backgroundImage: "editortool"
                                )
                            }
                        }
                        .padding(.horizontal, DevelloStyle.Spacing.lg)

                        Spacer(minLength: 80)
                    }
                }

                if isMenuOpen {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isMenuOpen = false
                            }
                        }
                }

                FloatingMenuView(isShowing: $isMenuOpen)
                    .allowsHitTesting(isMenuOpen)

                GlassNavBar(isMenuOpen: $isMenuOpen)
            }
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    HomeView()
}
