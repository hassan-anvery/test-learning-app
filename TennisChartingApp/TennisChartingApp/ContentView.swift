//
//  ContentView.swift
//  TennisChartingApp
//
//  Created by Syed Hassan Ali Anvery on 1/15/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 40) {
            Text("Tennis Charting")
                .font(.largeTitle)
                .fontWeight(.bold)

            Button("Start Match") {
                // TODO: Navigate to match screen
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
