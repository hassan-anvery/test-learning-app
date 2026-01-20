//
//  OpeningView.swift
//  TennisChartingApp
//

import SwiftUI

struct OpeningView: View {
    @State private var showSignUp = false
    @State private var showLogin = false

    // Teal green matching WelcomeView
    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.45)

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 80)

                    // Small app icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(brandGreen.opacity(0.1))
                            .frame(width: 64, height: 64)
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 28))
                            .foregroundColor(brandGreen)
                    }

                    Spacer()
                        .frame(height: 32)

                    // Title
                    Text("Welcome")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()
                        .frame(height: 12)

                    // Subtitle (two lines)
                    VStack(spacing: 4) {
                        Text("Track matches live.")
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                        Text("Review trends later.")
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // Buttons
                    VStack(spacing: 12) {
                        // Primary: Sign up (green filled pill)
                        Button {
                            showSignUp = true
                        } label: {
                            Text("Sign up")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(brandGreen)
                                .cornerRadius(28)
                                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                        }

                        // Secondary: Log in (outlined pill)
                        Button {
                            showLogin = true
                        } label: {
                            Text("Log in")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(brandGreen)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white)
                                .cornerRadius(28)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(brandGreen, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 60)
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
        }
    }
}

#Preview {
    OpeningView()
}
