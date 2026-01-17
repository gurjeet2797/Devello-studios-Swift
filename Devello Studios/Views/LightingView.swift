import SwiftUI
import PhotosUI

struct LightingView: View {
    @StateObject private var viewModel = LightingViewModel()

    @State private var selectedItem: PhotosPickerItem?

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
                Image(uiImage: input)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: DevelloStyle.CornerRadius.lg))
            }

            Picker("Lighting Style", selection: $viewModel.selectedStyle) {
                ForEach(LightingStyle.allCases) { style in
                    Text(style.rawValue).tag(style)
                }
            }
            .pickerStyle(.segmented)

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
                Button("Process") {
                    Task {
                        await viewModel.processLighting()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.inputImage == nil || viewModel.isLoading)

                Button("Reset") {
                    viewModel.reset()
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
        .navigationTitle("Lighting Studio")
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
}

#Preview {
    LightingView()
}
