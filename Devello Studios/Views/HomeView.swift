import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var isCreateModalExpanded = false
    @Namespace private var createModalNamespace

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    ZStack(alignment: .bottom) {
                        HeroSection()
                            .id("top")
                        
                        // Create button with glass effect morphing
                        GlassEffectContainer(spacing: 40) {
                            if !isCreateModalExpanded {
                                Button {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0)) {
                                        isCreateModalExpanded = true
                                    }
                                } label: {
                                    Text("Create anything")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 40)
                                        .padding(.vertical, 16)
                                }
                                .buttonStyle(.glass(.regular.tint(.blue).interactive()))
                                .glassEffectID("create-modal", in: createModalNamespace)
                                .glassEffectTransition(.matchedGeometry)
                            }
                        }
                        .offset(y: 50)
                    }
                    .padding(.bottom, 60)

                    VStack(alignment: .leading, spacing: DevelloStyle.Spacing.md) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Apps.")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.primary)

                            Spacer()
                            
                            Text("Try our in-house tools")
                                .font(DevelloStyle.Fonts.body)
                                .foregroundStyle(.secondary)
                        }

                        Text("Adjust the time of day and edit images quickly.")
                            .font(DevelloStyle.Fonts.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, DevelloStyle.Spacing.lg)

                    GlassEffectContainer(spacing: 32) {
                        VStack(spacing: 32) {
                            Button {
                                router.navigate(to: .lighting)
                            } label: {
                                ToolCardView(
                                    title: "Lighting Studio",
                                    subtitle: "Pick a time of day and let the sun be your lighting director",
                                    backgroundImage: "lightingtool"
                                )
                            }
                            .buttonStyle(.plain)

                            Button {
                                router.navigate(to: .editor)
                            } label: {
                                ToolCardView(
                                    title: "Image Editor",
                                    subtitle: "Edit a single hotspot with AI guidance",
                                    backgroundImage: "editortool"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 80)
                }
            }
            .scrollContentBackground(.hidden)
            .ignoresSafeArea(edges: .top)
            .blur(radius: isCreateModalExpanded ? 10 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isCreateModalExpanded)
            
            // Expanded create modal overlay
            if isCreateModalExpanded {
                ExpandedCreateModalView(
                    isExpanded: $isCreateModalExpanded,
                    namespace: createModalNamespace
                )
            }
        }
    }
}

// MARK: - Expanded Create Modal View
struct ExpandedCreateModalView: View {
    @Binding var isExpanded: Bool
    var namespace: Namespace.ID
    
    @State private var ideaText = ""
    @FocusState private var isInputFocused: Bool
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Dimming background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }
            
            // Expanded modal container
            GlassEffectContainer(spacing: 40) {
                VStack(spacing: 24) {
                    // Header with close button
                    HStack {
                        // Devello Creative Engine label
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12, weight: .medium))
                            Text("DEVELLO CREATIVE ENGINE")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(0.5)
                        }
                        .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Button {
                            dismissModal()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.primary)
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.glass(.clear.interactive()))
                    }
                    
                    // Title
                    Text("Type an idea. See what it becomes.")
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                        .padding(.top, 8)
                    
                    // Input field with glass effect
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Describe something you wish your device could do", text: $ideaText, axis: .vertical)
                            .font(.system(size: 16))
                            .lineLimit(3...6)
                            .foregroundStyle(.primary)
                        
                        Divider()
                            .background(Color.primary.opacity(0.2))
                        
                        // Action buttons row
                        HStack {
                            Button {
                                // Generate action
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 14))
                                    Text("Generate")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                            .disabled(ideaText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            
                            Spacer()
                            
                            Button {
                                dismissModal()
                            } label: {
                                Text("Cancel")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                    .glassEffect(.clear, in: .rect(cornerRadius: 16))
                }
                .padding(24)
                .frame(maxWidth: 400)
                .glassEffect(.regular.tint(.blue), in: .rect(cornerRadius: 32))
                .glassEffectID("create-modal", in: namespace)
                .glassEffectTransition(.matchedGeometry)
            }
            .opacity(contentOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3).delay(0.15)) {
                contentOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isInputFocused = true
            }
        }
    }
    
    private func dismissModal() {
        isInputFocused = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0)) {
            contentOpacity = 0
            isExpanded = false
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppRouter())
}
