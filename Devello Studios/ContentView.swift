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

    var body: some View {
        HomeView()
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .task {
                await supabaseManager.restoreSession()
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(SupabaseManager())
}
