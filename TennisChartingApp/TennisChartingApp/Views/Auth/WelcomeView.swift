//
//  WelcomeView.swift
//  TennisChartingApp
//

import SwiftUI

struct WelcomeView: View {
    let onGetStarted: () -> Void

    // Teal green color matching mockup
    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.45)

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo + Title + Subtitle
                VStack(spacing: 16) {
                    Image(systemName: "tennisball")
                        .font(.system(size: 70, weight: .thin))
                        .foregroundColor(brandGreen)

                    Text("MatchChart")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.black)

                    Text("PRO CHARTING TOOL")
                        .font(.system(size: 12, weight: .medium))
                        .tracking(2)
                        .foregroundColor(brandGreen)
                }

                Spacer()
                Spacer()

                // Get Started button
                Button(action: onGetStarted) {
                    Text("Get Started")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(brandGreen)
                        .cornerRadius(28)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    WelcomeView {
        print("Get Started tapped")
    }
}
