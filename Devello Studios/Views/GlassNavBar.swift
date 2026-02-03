import SwiftUI

/// iOS 26 Liquid Glass Navigation Bar using Apple's standard patterns
/// Consistent across all views with round buttons - now sticky at root level
struct GlassNavBar: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @EnvironmentObject private var router: AppRouter
    @AppStorage("isDarkMode") private var isDarkMode = false

    var onLogoTapped: (() -> Void)?
    var onNavigateToLighting: (() -> Void)?
    var onNavigateToEditor: (() -> Void)?
    var onNavigateToPlayground: (() -> Void)?
    var onSignInRequested: (() -> Void)?
    
    init(
        onLogoTapped: (() -> Void)? = nil,
        onNavigateToLighting: (() -> Void)? = nil,
        onNavigateToEditor: (() -> Void)? = nil,
        onNavigateToPlayground: (() -> Void)? = nil,
        onSignInRequested: (() -> Void)? = nil
    ) {
        self.onLogoTapped = onLogoTapped
        self.onNavigateToLighting = onNavigateToLighting
        self.onNavigateToEditor = onNavigateToEditor
        self.onNavigateToPlayground = onNavigateToPlayground
        self.onSignInRequested = onSignInRequested
    }
    
    /// Icon color based on current color scheme
    private var iconColor: Color {
        isDarkMode ? .white : .black
    }
    
    /// Whether a tool overlay is currently active
    private var isToolActive: Bool {
        !router.path.isEmpty
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Logo button or close button when tool is active
            if isToolActive {
                // Close button when tool is active
                Button {
                    router.popToRoot()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(iconColor)
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                        .glassEffect(.clear, in: .circle)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            } else {
                // Logo button - round with clear glass effect, bigger logo
                Button {
                    if let onLogoTapped {
                        onLogoTapped()
                    } else {
                        router.popToRoot()
                    }
                } label: {
                    Image("devellologo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34, height: 34)
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                        .glassEffect(.clear, in: .circle)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }

            Spacer()

            // Theme toggle button - round with clear glass effect
            Button {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isDarkMode.toggle()
                }
            } label: {
                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
                    .glassEffect(.clear, in: .circle)
            }
            .buttonStyle(.plain)

            // Menu - round button with glass effect on label only
            Menu {
                // Navigation options (only show when no tool is active)
                if !isToolActive {
                    Button {
                        if let onNavigateToLighting {
                            onNavigateToLighting()
                        } else {
                            router.navigate(to: .lighting)
                        }
                    } label: {
                        Label("Lighting Studio", systemImage: "sun.max.fill")
                    }
                    
                    Button {
                        if let onNavigateToEditor {
                            onNavigateToEditor()
                        } else {
                            router.navigate(to: .editor)
                        }
                    } label: {
                        Label("Image Editor", systemImage: "photo.fill")
                    }

                    Button {
                        if let onNavigateToPlayground {
                            onNavigateToPlayground()
                        } else {
                            router.navigate(to: .playground)
                        }
                    } label: {
                        Label("Playground", systemImage: "sparkles")
                    }
                    
                    Divider()
                } else {
                    // When tool is active, show option to switch tools
                    if router.path.last != AppRouter.Route.lighting {
                        Button {
                            router.popToRoot()
                            router.navigate(to: .lighting)
                        } label: {
                            Label("Switch to Lighting Studio", systemImage: "sun.max.fill")
                        }
                    }
                    
                    if router.path.last != AppRouter.Route.editor {
                        Button {
                            router.popToRoot()
                            router.navigate(to: .editor)
                        } label: {
                            Label("Switch to Image Editor", systemImage: "photo.fill")
                        }
                    }

                    if router.path.last != AppRouter.Route.playground {
                        Button {
                            router.popToRoot()
                            router.navigate(to: .playground)
                        } label: {
                            Label("Switch to Playground", systemImage: "sparkles")
                        }
                    }
                    
                    Button {
                        router.popToRoot()
                    } label: {
                        Label("Back to Home", systemImage: "house.fill")
                    }
                    
                    Divider()
                }
                
                // Sign in/out option
                Button {
                    if supabaseManager.session == nil {
                        onSignInRequested?()
                    } else {
                        Task { await supabaseManager.signOut() }
                    }
                } label: {
                    Label(
                        supabaseManager.session == nil ? "Sign In" : "Sign Out",
                        systemImage: supabaseManager.session == nil ? "person.fill" : "rectangle.portrait.and.arrow.right"
                    )
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 44, height: 44)
                    .glassEffect(.clear, in: .circle)
            }
        }
        .contentShape(Rectangle())
        .padding(.horizontal, DevelloStyle.Spacing.lg)
        .padding(.top, DevelloStyle.Spacing.md)
        .padding(.bottom, DevelloStyle.Spacing.sm)
    }
}

#Preview {
    GlassNavBar()
        .environmentObject(SupabaseManager())
        .environmentObject(AppRouter())
}
