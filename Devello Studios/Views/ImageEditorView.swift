import SwiftUI
import PhotosUI

struct ImageEditorView: View {
    @ObservedObject var viewModel: ImageEditorViewModel
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageFrame: CGRect = .zero
    @State private var promptDraft = ""
    @State private var showingPromptEditor = false
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
                    viewModel.resetEdits()
                }
            }
        }
        .sheet(isPresented: $showingPromptEditor) {
            PromptEditorView(
                prompt: $promptDraft,
                onSave: savePrompt
            )
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
        ScrollView {
            VStack(spacing: DevelloStyle.Spacing.lg) {
                // Change image button
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 14))
                        Text("Change Image")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(toolPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .glassEffect(.clear.interactive(), in: .capsule)
                }
                
                // Input image with hotspot markers
                if let input = viewModel.inputImage {
                    GeometryReader { proxy in
                        ZStack(alignment: .topLeading) {
                            let fittedFrame = aspectFitFrame(for: input.size, in: proxy.size)
                            Image(uiImage: input)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: fittedFrame.width, height: fittedFrame.height)
                                .position(x: fittedFrame.midX, y: fittedFrame.midY)

                            ForEach(viewModel.markers) { marker in
                                let point = HotspotNormalization.denormalize(point: marker.normalizedPoint, in: fittedFrame)
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 14, height: 14)
                                    .position(point)
                                    .onTapGesture {
                                        beginEditing(marker: marker)
                                    }
                            }
                        }
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    let fittedFrame = aspectFitFrame(for: input.size, in: proxy.size)
                                    if let normalized = HotspotNormalization.normalize(point: value.location, in: fittedFrame) {
                                        viewModel.addMarker(at: normalized)
                                        if let marker = viewModel.markers.first {
                                            beginEditing(marker: marker)
                                        }
                                    }
                                }
                        )
                        .onAppear {
                            imageFrame = aspectFitFrame(for: input.size, in: proxy.size)
                        }
                        .onChange(of: proxy.size) { _, newSize in
                            imageFrame = aspectFitFrame(for: input.size, in: newSize)
                        }
                    }
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: DevelloStyle.CornerRadius.lg))
                    .glassEffect(.clear, in: .rect(cornerRadius: DevelloStyle.CornerRadius.lg))
                }
                
                // Hotspot prompt section
                if let marker = viewModel.markers.first {
                    VStack(alignment: .leading, spacing: DevelloStyle.Spacing.sm) {
                        Text("Hotspot Prompt")
                            .font(DevelloStyle.Fonts.subtitle)
                            .foregroundStyle(toolPrimary)

                        Text(marker.prompt.isEmpty ? "Tap hotspot to add a prompt." : marker.prompt)
                            .font(DevelloStyle.Fonts.body)
                            .foregroundStyle(marker.prompt.isEmpty ? toolSecondary : toolPrimary)

                        Button {
                            beginEditing(marker: marker)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 12))
                                Text("Edit Prompt")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.glass(.regular.interactive()))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .glassEffect(.clear, in: .rect(cornerRadius: 16))
                }
                
                // Output image
                if let output = viewModel.outputImage {
                    VStack(alignment: .leading, spacing: DevelloStyle.Spacing.sm) {
                        Text("Processed")
                            .font(DevelloStyle.Fonts.subtitle)
                            .foregroundStyle(toolPrimary)
                        Image(uiImage: output)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: DevelloStyle.CornerRadius.lg))
                    }
                }
                
                // Error message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(DevelloStyle.Fonts.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
                
                // Action buttons
                HStack(spacing: DevelloStyle.Spacing.md) {
                    Button {
                        Task {
                            await viewModel.processSingleEdit()
                        }
                    } label: {
                        Text("Apply Edit")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.blue)
                    .disabled(viewModel.inputImage == nil || viewModel.isLoading)
                    
                    Button {
                        viewModel.resetEdits()
                    } label: {
                        Text("Reset")
                            .font(.system(size: 16, weight: .medium))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.glass(.regular.interactive()))
                    .disabled(viewModel.inputImage == nil)
                }
                
                // Save button
                if let output = viewModel.outputImage {
                    Button {
                        Task {
                            try? await ImageEngine.saveToPhotos(output)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save to Photos")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.glass(.regular.tint(.green).interactive()))
                }
                
                // Loading indicator
                if viewModel.isLoading {
                    ProgressView("Processing...")
                        .padding()
                }
                
                Spacer(minLength: 40)
            }
            .padding(DevelloStyle.Spacing.lg)
        }
    }

    private func aspectFitFrame(for imageSize: CGSize, in container: CGSize) -> CGRect {
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = container.width / container.height
        var size: CGSize

        if imageAspect > containerAspect {
            size = CGSize(width: container.width, height: container.width / imageAspect)
        } else {
            size = CGSize(width: container.height * imageAspect, height: container.height)
        }

        let origin = CGPoint(
            x: (container.width - size.width) / 2,
            y: (container.height - size.height) / 2
        )

        return CGRect(origin: origin, size: size)
    }

    private func beginEditing(marker: EditMarker) {
        promptDraft = marker.prompt
        viewModel.selectedMarkerId = marker.id
        showingPromptEditor = true
    }

    private func savePrompt() {
        guard let markerId = viewModel.selectedMarkerId else { return }
        viewModel.updatePrompt(for: markerId, prompt: promptDraft)
        showingPromptEditor = false
    }
}

// MARK: - Prompt Editor View
private struct PromptEditorView: View {
    @Binding var prompt: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: DevelloStyle.Spacing.md) {
                TextField("Describe the edit", text: $prompt, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                    .padding(16)
                    .glassEffect(.clear, in: .rect(cornerRadius: 12))

                Text("\(prompt.count)/400")
                    .font(DevelloStyle.Fonts.caption)
                    .foregroundStyle(prompt.count > 400 ? .red : .secondary)

                Spacer()
                
                // Save button with glass style
                Button {
                    onSave()
                } label: {
                    Text("Save")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.glassProminent)
                .tint(.blue)
                .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || prompt.count > 400)
            }
            .padding(DevelloStyle.Spacing.lg)
            .navigationTitle("Edit Prompt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .buttonStyle(.glass(.clear.interactive()))
                }
            }
        }
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(24)
    }
}

#Preview {
    ImageEditorView(viewModel: ImageEditorViewModel())
}
