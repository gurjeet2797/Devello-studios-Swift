import SwiftUI
import PhotosUI

struct ImageEditorView: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @StateObject private var viewModel = ImageEditorViewModel()

    @State private var selectedItem: PhotosPickerItem?
    @State private var imageFrame: CGRect = .zero
    @State private var promptDraft = ""
    @State private var showingPromptEditor = false

    private var hasInputImage: Bool {
        viewModel.inputImage != nil
    }

    var body: some View {
        VStack(spacing: DevelloStyle.Spacing.lg) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                VStack(spacing: DevelloStyle.Spacing.sm) {
                    Image(systemName: "photo")
                        .font(.system(size: 32))
                    Text(hasInputImage ? "Change Image" : "Select Image")
                        .font(DevelloStyle.Fonts.body)
                }
                .frame(maxWidth: .infinity, minHeight: 140)
                .background(DevelloStyle.Colors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: DevelloStyle.CornerRadius.lg))
            }

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
            }

            if let marker = viewModel.markers.first {
                VStack(alignment: .leading, spacing: DevelloStyle.Spacing.sm) {
                    Text("Hotspot Prompt")
                        .font(DevelloStyle.Fonts.subtitle)

                    Text(marker.prompt.isEmpty ? "Tap hotspot to add a prompt." : marker.prompt)
                        .font(DevelloStyle.Fonts.body)
                        .foregroundStyle(marker.prompt.isEmpty ? DevelloStyle.Colors.textSecondary : DevelloStyle.Colors.textPrimary)

                    Button("Edit Prompt") {
                        beginEditing(marker: marker)
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let output = viewModel.outputImage {
                VStack(alignment: .leading, spacing: DevelloStyle.Spacing.sm) {
                    Text("Processed")
                        .font(DevelloStyle.Fonts.subtitle)
                    Image(uiImage: output)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: DevelloStyle.CornerRadius.lg))
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(DevelloStyle.Fonts.caption)
                    .foregroundStyle(.red)
            }

            HStack(spacing: DevelloStyle.Spacing.md) {
                Button("Apply Edit") {
                    Task {
                        await viewModel.processSingleEdit()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.inputImage == nil || viewModel.isLoading)

                Button("Reset") {
                    viewModel.resetEdits()
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.inputImage == nil)
            }

            if let output = viewModel.outputImage {
                Button("Save to Photos") {
                    Task {
                        try? await ImageEngine.saveToPhotos(output)
                    }
                }
                .buttonStyle(.bordered)
            }

            if viewModel.isLoading {
                ProgressView("Processing...")
            }

            Spacer()
        }
        .padding(DevelloStyle.Spacing.lg)
        .navigationTitle("Image Editor")
        .onAppear {
            viewModel.configure(supabaseManager: supabaseManager)
        }
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

private struct PromptEditorView: View {
    @Binding var prompt: String
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: DevelloStyle.Spacing.md) {
                TextField("Describe the edit", text: $prompt, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                    .textFieldStyle(.roundedBorder)

                Text("\(prompt.count)/400")
                    .font(DevelloStyle.Fonts.caption)
                    .foregroundStyle(prompt.count > 400 ? .red : DevelloStyle.Colors.textSecondary)

                Spacer()
            }
            .padding(DevelloStyle.Spacing.lg)
            .navigationTitle("Edit Prompt")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave() }
                        .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || prompt.count > 400)
                }
            }
        }
    }
}

#Preview {
    ImageEditorView()
        .environmentObject(SupabaseManager())
}
