import SwiftUI

struct HomeView: View {
    @State private var isMenuOpen = false
    @State private var showCreateModal = false
    @State private var scrollToTop: (() -> Void)?
    @State private var hasAppeared = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 40) {
                            ZStack(alignment: .bottom) {
                                HeroSection()
                                    .id("top")
                                
                                Button {
                                    showCreateModal = true
                                } label: {
                                    Text("Create anything")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 40)
                                        .padding(.vertical, 16)
                                }
                                .buttonStyle(.glass(.regular.tint(.blue).interactive()))
                                .offset(y: 28)
                            }
                            .padding(.bottom, 40)

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
                                    NavigationLink {
                                        LightingView()
                                    } label: {
                                        ToolCardView(
                                            title: "Lighting Studio",
                                            subtitle: "Pick a time of day and let the sun be your lighting director",
                                            backgroundImage: "lightingtool"
                                        )
                                    }
                                    .buttonStyle(.plain)

                                    NavigationLink {
                                        ImageEditorView()
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
                    .blur(radius: isMenuOpen ? 10 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isMenuOpen)
                    .onAppear {
                        scrollToTop = {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                                scrollProxy.scrollTo("top", anchor: .top)
                            }
                        }
                        // Delay setting hasAppeared to avoid animating initial load
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            hasAppeared = true
                        }
                    }
                }

                GlassNavBar(isMenuOpen: $isMenuOpen) {
                    scrollToTop?()
                }
                
                if isMenuOpen {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isMenuOpen = false
                            }
                        }
                    
                    FloatingMenuView(isShowing: $isMenuOpen)
                }
            }
            .background {
                Color(.systemBackground)
                    .ignoresSafeArea()
                    .animation(hasAppeared ? .easeInOut(duration: 0.4) : nil, value: colorScheme)
            }
            .sheet(isPresented: $showCreateModal) {
                CreateIdeaModalView()
                    .presentationBackground(.ultraThinMaterial)
                    .presentationCornerRadius(24)
            }
        }
    }
}

struct CreateIdeaModalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ideaText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.glass(.clear))
            }
            
            Spacer()
            
            // Title
            Text("Type an idea.\nSee what it can become.")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
            
            // Input field
            TextField("Describe your vision...", text: $ideaText, axis: .vertical)
                .font(.system(size: 17))
                .lineLimit(3...6)
                .padding(16)
                .glassEffect(.clear, in: .rect(cornerRadius: 16))
                .focused($isInputFocused)
            
            // Create button
            Button {
                // Handle create action
                dismiss()
            } label: {
                Text("Create")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.glassProminent)
            .tint(.blue)
            .disabled(ideaText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            Spacer()
        }
        .padding(24)
        .onAppear {
            isInputFocused = true
        }
    }
}

#Preview {
    HomeView()
}
