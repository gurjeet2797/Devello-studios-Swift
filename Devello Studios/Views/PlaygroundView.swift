import SwiftUI
import UIKit

struct PlaygroundView: View {
    @ObservedObject var lightingViewModel: LightingViewModel
    @ObservedObject var editorViewModel: ImageEditorViewModel

    var onOpenLighting: () -> Void
    var onOpenEditor: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var toolPrimary: Color {
        colorScheme == .dark ? .white : .black
    }

    private var toolSecondary: Color {
        toolPrimary.opacity(0.7)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DevelloStyle.Spacing.lg) {
                header
                demoSection
                prototypeSection
                Spacer(minLength: 40)
            }
            .padding(DevelloStyle.Spacing.lg)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Playground")
                .font(DevelloStyle.Fonts.title)
                .foregroundStyle(toolPrimary)

            Text("Experiment with previews of Devello tools and prototypes. Nothing here affects your real data.")
                .font(DevelloStyle.Fonts.body)
                .foregroundStyle(toolSecondary)
        }
    }

    private var demoSection: some View {
        VStack(alignment: .leading, spacing: DevelloStyle.Spacing.md) {
            Text("Instant Demos")
                .font(DevelloStyle.Fonts.subtitle)
                .foregroundStyle(toolPrimary)

            Button {
                preloadLightingDemo()
                onOpenLighting()
            } label: {
                ToolCardView(
                    title: "Lighting Studio (Demo)",
                    subtitle: "Loads a sample photo so you can test lighting styles quickly",
                    backgroundImage: "lightingtool"
                )
            }
            .buttonStyle(.plain)

            Button {
                preloadEditorDemo()
                onOpenEditor()
            } label: {
                ToolCardView(
                    title: "Image Editor (Demo)",
                    subtitle: "Starts with a sample image and a suggested hotspot",
                    backgroundImage: "editortool"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var prototypeSection: some View {
        VStack(alignment: .leading, spacing: DevelloStyle.Spacing.md) {
            Text("Prototype Experiments")
                .font(DevelloStyle.Fonts.subtitle)
                .foregroundStyle(toolPrimary)

            GlassEffectContainer(spacing: 16) {
                IdeaSparkCard()
            }
        }
    }

    private func preloadLightingDemo() {
        if let demoImage = UIImage(named: "lightingtool") {
            lightingViewModel.inputImage = demoImage
            lightingViewModel.reset()
        }
    }

    private func preloadEditorDemo() {
        if let demoImage = UIImage(named: "editortool") {
            editorViewModel.inputImage = demoImage
            editorViewModel.resetEdits()
            editorViewModel.addMarker(at: CGPoint(x: 0.5, y: 0.5))
            if let markerId = editorViewModel.markers.first?.id {
                editorViewModel.updatePrompt(for: markerId, prompt: "Make this area brighter")
            }
        }
    }
}

private struct IdeaSparkCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var ideaText = ""
    @State private var draftText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let backendService = IOSBackendService()

    private var toolPrimary: Color {
        colorScheme == .dark ? .white : .black
    }

    private var toolSecondary: Color {
        toolPrimary.opacity(0.7)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Idea Spark")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(toolPrimary)

            Text("Drop a one-line concept and generate a draft product flow.")
                .font(DevelloStyle.Fonts.body)
                .foregroundStyle(toolSecondary)

            TextField("Example: A camera app that rewrites your memories into a photo journal", text: $ideaText, axis: .vertical)
                .lineLimit(2...4)
                .padding(12)
                .glassEffect(.clear, in: .rect(cornerRadius: 12))

            Button {
                Task {
                    await generateDraft()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text(isLoading ? "Generating..." : "Generate Draft")
                }
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.glassProminent)
            .tint(.blue)
            .disabled(isLoading || ideaText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            if let errorMessage {
                Text(errorMessage)
                    .font(DevelloStyle.Fonts.caption)
                    .foregroundStyle(.red)
            }

            if !draftText.isEmpty {
                Text(draftText)
                    .font(DevelloStyle.Fonts.body)
                    .foregroundStyle(toolPrimary)
                    .padding(12)
                    .glassEffect(.clear, in: .rect(cornerRadius: 12))
            }
        }
        .padding(DevelloStyle.Spacing.md)
        .glassEffect(.regular.tint(.secondary).interactive(), in: .rect(cornerRadius: 16))
    }

    private func generateDraft() async {
        let trimmed = ideaText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        draftText = ""

        do {
            let response = try await backendService.generateIdeaSpark(idea: trimmed)
            guard response.ok, let draft = response.draft else {
                throw NSError(domain: "IdeaSpark", code: 0, userInfo: [NSLocalizedDescriptionKey: response.error ?? "No draft returned"])
            }
            draftText = draft
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    PlaygroundView(
        lightingViewModel: LightingViewModel(),
        editorViewModel: ImageEditorViewModel(),
        onOpenLighting: {},
        onOpenEditor: {}
    )
}
