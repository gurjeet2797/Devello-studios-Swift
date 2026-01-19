//
//  ContentView.swift
//  Devello Studios
//
//  Created by Gurjeet Singh on 11/19/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var supabaseManager: SupabaseManager
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showSignIn = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var router = AppRouter()
    @StateObject private var lightingViewModel = LightingViewModel()
    @StateObject private var editorViewModel = ImageEditorViewModel()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: AppRouter.Route.self) { route in
                    switch route {
                    case .lighting:
                        LightingView(viewModel: lightingViewModel)
                            .toolbar(.hidden, for: .navigationBar)
                    case .editor:
                        ImageEditorView(viewModel: editorViewModel)
                            .toolbar(.hidden, for: .navigationBar)
                    }
                }
                .toolbar(.hidden, for: .navigationBar)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .overlay(alignment: .top) {
            GlassNavBar(
                onLogoTapped: {
                    router.popToRoot()
                },
                onSignInRequested: {
                    showSignIn = true
                }
            )
            .environmentObject(router)
            .zIndex(1)
        }
        .sheet(isPresented: $showSignIn) {
            SignInView()
        }
        .environmentObject(router)
        .task {
            await supabaseManager.restoreSession()
        }
        .animation(scenePhase == .active ? .easeInOut(duration: 0.3) : nil, value: colorScheme)
    }
}

#Preview {
    ContentView()
        .environmentObject(SupabaseManager())
}
