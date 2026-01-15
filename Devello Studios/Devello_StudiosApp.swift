//
//  Devello_StudiosApp.swift
//  Devello Studios
//
//  Created by Gurjeet Singh on 11/19/25.
//

import SwiftUI

@main
struct Devello_StudiosApp: App {
    @StateObject private var supabaseManager = SupabaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(supabaseManager)
                .onOpenURL { url in
                    Task {
                        await supabaseManager.handleAuthCallback(url: url)
                    }
                }
        }
    }
}
