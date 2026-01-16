//
//  OpeningView.swift
//  TennisChartingApp
//

import SwiftUI

struct OpeningView: View {
    @State private var showSignUp = false
    @State private var showLogin = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // Logo area
                    VStack(spacing: 8) {
                        Image(systemName: "tennisball.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)

                        Text("Tennis Charting")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    // Buttons
                    VStack(spacing: 16) {
                        Button {
                            showSignUp = true
                        } label: {
                            Text("Sign Up")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white)
                                .cornerRadius(8)
                        }

                        Button {
                            showLogin = true
                        } label: {
                            Text("Login")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 40)
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
