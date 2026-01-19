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
                
                // Input image display
                if let input = viewModel.inputImage {
                    Image(uiImage: input)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: DevelloStyle.CornerRadius.lg))
                        .glassEffect(.clear, in: .rect(cornerRadius: DevelloStyle.CornerRadius.lg))
                }
                
                // Lighting style picker
                Picker("Lighting Style", selection: $viewModel.selectedStyle) {
                    ForEach(LightingStyle.allCases) { style in
                        Text(style.rawValue)
                            .foregroundStyle(toolPrimary)
                            .tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, DevelloStyle.Spacing.md)
                
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
                            await viewModel.processLighting()
                        }
                    } label: {
                        Text("Process")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.blue)
                    .disabled(viewModel.inputImage == nil || viewModel.isLoading)
                    
                    Button {
                        viewModel.reset()
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
}

#Preview {
    LightingView(viewModel: LightingViewModel())
}
