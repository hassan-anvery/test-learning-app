    //
//  ContentView.swift
//  TennisChartingApp
//
//  Created by Syed Hassan Ali Anvery on 1/15/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var authManager = AuthManager.shared
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                HomeView()
            } else if hasSeenWelcome {
                OpeningView()
            } else {
                WelcomeView {
                    hasSeenWelcome = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
