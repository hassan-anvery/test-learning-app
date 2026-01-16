//
//  ContentView.swift
//  TennisChartingApp
//
//  Created by Syed Hassan Ali Anvery on 1/15/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var authManager = AuthManager.shared

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                HomeView()
            } else {
                OpeningView()
            }
        }
    }
}

#Preview {
    ContentView()
}
