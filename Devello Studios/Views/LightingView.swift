import SwiftUI
import PhotosUI

struct LightingView: View {
    @ObservedObject var viewModel: LightingViewModel
    @State private var selectedItem: PhotosPickerItem?
    @Environment(\.colorScheme) private var colorScheme

    private var toolPrimary: Color {
        colorScheme == .dark ? .white : .black
    }

    private var toolSecondary: Color {
        toolPrimary.opacity(0.7)
    }

    private var toolTertiary: Color {
        toolPrimary.opacity(0.55)
    }

    private var hasInputImage: Bool {
        viewModel.inputImage != nil
    }

    var body: some View {
        GlassEffectContainer(spacing: 24) {
            if hasInputImage {
                // Image loaded state - show editing interface
                imageLoadedContent
            } else {
                // No image state - centered glass upload button
                centeredUploadView
            }
        }
        .padding(.top, 70) // Space for sticky nav bar
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.inputImage = image
                    viewModel.reset()
                }
            }
        }
    }
    
    // MARK: - Centered Upload View
    private var centeredUploadView: some View {
        VStack {
            Spacer()
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                VStack(spacing: DevelloStyle.Spacing.md) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(toolSecondary)
                    
                    Text("Upload Photo")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(toolPrimary)
                    
                    Text("Click to select an image")
                        .font(DevelloStyle.Fonts.body)
                        .foregroundStyle(toolSecondary)
                    
                    Text("All images standardized for optimal AI processing")
                        .font(DevelloStyle.Fonts.caption)
                        .foregroundStyle(toolTertiary)
                }
                .padding(40)
                .glassEffect(.regular.tint(.secondary).interactive(), in: .rect(cornerRadius: 24))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Image Loaded Content
    private var imageLoadedContent: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        imageViewport(size: geometry.size, safeAreaInsets: geometry.safeAreaInsets)
                            .id("imageViewport")
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, DevelloStyle.Spacing.lg)
                            .padding(.top, DevelloStyle.Spacing.lg)
                            .padding(.bottom, DevelloStyle.Spacing.lg)
                    }
                }
                .scrollContentBackground(.hidden)
                .onChange(of: viewModel.inputImage) { _, newValue in
                    guard newValue != nil else { return }
                    withAnimation(.easeInOut(duration: 0.35)) {
                        proxy.scrollTo("imageViewport", anchor: .top)
                    }
                }
            }
        }
    }

    private func imageViewport(size: CGSize, safeAreaInsets: EdgeInsets) -> some View {
        let padding = DevelloStyle.Spacing.md
        let reservedHeight = CGFloat(140) + safeAreaInsets.top + safeAreaInsets.bottom
        let viewportHeight = max(320, size.height - reservedHeight)
        let imageMaxSize = CGSize(
            width: max(0, size.width - padding * 2),
            height: max(0, viewportHeight - padding * 2)
        )

        return ZStack(alignment: .bottom) {
            imageStack(maxSize: imageMaxSize)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            glassControlsOverlay
                .padding(padding)
        }
        .frame(height: viewportHeight)
        .clipShape(RoundedRectangle(cornerRadius: DevelloStyle.CornerRadius.xl))
        .glassEffect(.clear, in: .rect(cornerRadius: DevelloStyle.CornerRadius.xl))
    }

    private func imageStack(maxSize: CGSize) -> some View {
        ZStack(alignment: .topTrailing) {
            if let input = viewModel.inputImage {
                Image(uiImage: input)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: maxSize.width, maxHeight: maxSize.height)

                if let output = viewModel.outputImage {
                    Image(uiImage: output)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: maxSize.width, maxHeight: maxSize.height)
                        .opacity(viewModel.showingAfterImage ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.showingAfterImage)

                    beforeAfterBadge
                        .padding(12)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.outputImage != nil {
                viewModel.toggleBeforeAfter()
            }
        }
    }

    private var beforeAfterBadge: some View {
        Text(viewModel.showingAfterImage ? "After" : "Before")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(toolPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .glassEffect(.regular, in: .capsule)
    }

    private var glassControlsOverlay: some View {
        VStack(spacing: DevelloStyle.Spacing.md) {
            lightingStyleButtons
            primaryActionRow
            secondaryActionRow

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(DevelloStyle.Fonts.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if viewModel.isLoading {
                ProgressView("Processing...")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(DevelloStyle.Spacing.md)
        .glassEffect(.regular.tint(.secondary).interactive(), in: .rect(cornerRadius: DevelloStyle.CornerRadius.lg))
    }

    private var lightingStyleButtons: some View {
        HStack(spacing: DevelloStyle.Spacing.sm) {
            ForEach(LightingStyle.allCases) { style in
                Button {
                    viewModel.selectedStyle = style
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: style.icon)
                            .font(.system(size: 20, weight: .semibold))
                        Text(style.displayName)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.glass(
                    viewModel.selectedStyle == style
                        ? .regular.tint(.blue).interactive()
                        : .clear.interactive()
                ))
            }
        }
    }

    private var primaryActionRow: some View {
        HStack(spacing: DevelloStyle.Spacing.sm) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                HStack(spacing: 6) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Change")
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
            .buttonStyle(.glass(.clear.interactive()))

            Button {
                Task {
                    await viewModel.processLighting()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "wand.and.stars")
                    Text("Process Image")
                }
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.glassProminent)
            .tint(.blue)
            .disabled(viewModel.inputImage == nil || viewModel.isLoading)
        }
    }

    private var secondaryActionRow: some View {
        HStack(spacing: DevelloStyle.Spacing.sm) {
            Button {
                viewModel.reset()
            } label: {
                Text("Reset")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.glass(.clear.interactive()))
            .disabled(viewModel.inputImage == nil)

            if let output = viewModel.outputImage {
                Button {
                    Task {
                        try? await ImageEngine.saveToPhotos(output)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.glass(.regular.tint(.green).interactive()))
            }

            Spacer(minLength: 0)
        }
    }
}

#Preview {
    LightingView(viewModel: LightingViewModel())
}
