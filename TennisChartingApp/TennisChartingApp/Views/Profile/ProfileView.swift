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
                Color(red: 0.96, green: 0.96, blue: 0.96)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    // Profile icon
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 100, height: 100)
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)

                    // Email
                    if let user = AuthManager.shared.currentUser {
                        Text(user.email)
                            .foregroundColor(.primary)
                            .font(.headline)
                    }

                    Spacer()

                    // Stats summary
                    VStack(spacing: 16) {
                        HStack {
                            Text("Total Matches")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(MatchStore.shared.matches.count)")
                                .foregroundColor(.primary)
                                .fontWeight(.bold)
                        }

                        HStack {
                            Text("Completed Matches")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(MatchStore.shared.matches.filter { $0.isCompleted }.count)")
                                .foregroundColor(.primary)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
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
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(25)
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
                    .foregroundColor(.green)
                }
            }
            .toolbarBackground(Color(red: 0.96, green: 0.96, blue: 0.96), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .alert("Log Out", isPresented: $showLogoutConfirmation) {
                Button("Yes", role: .destructive) {
                    UserDefaults.standard.set(false, forKey: "hasSeenWelcome")
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
