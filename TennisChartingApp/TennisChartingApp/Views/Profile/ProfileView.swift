//
//  ProfileView.swift
//  TennisChartingApp
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    // Profile icon
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                        .padding(.top, 40)

                    // Email
                    if let user = AuthManager.shared.currentUser {
                        Text(user.email)
                            .foregroundColor(.white)
                            .font(.headline)
                    }

                    Spacer()

                    // Stats summary
                    VStack(spacing: 16) {
                        HStack {
                            Text("Total Matches")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(MatchStore.shared.matches.count)")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }

                        HStack {
                            Text("Completed Matches")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(MatchStore.shared.matches.filter { $0.isCompleted }.count)")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    Spacer()

                    // Logout button
                    Button {
                        showLogoutConfirmation = true
                    } label: {
                        Text("Log Out")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Log Out", isPresented: $showLogoutConfirmation) {
                Button("Yes", role: .destructive) {
                    AuthManager.shared.logout()
                    dismiss()
                }
                Button("No", role: .cancel) { }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

#Preview {
    ProfileView()
}
