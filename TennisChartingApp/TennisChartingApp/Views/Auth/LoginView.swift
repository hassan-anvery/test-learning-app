//
//  LoginView.swift
//  TennisChartingApp
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.96, blue: 0.96)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Header
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                // Form fields
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email:")
                            .foregroundColor(.secondary)
                            .font(.headline)

                        TextField("", text: $email, prompt: Text("Enter your email").foregroundColor(.gray.opacity(0.6)))
                            .textFieldStyle(.plain)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password:")
                            .foregroundColor(.secondary)
                            .font(.headline)

                        SecureField("", text: $password, prompt: Text("Enter your password").foregroundColor(.gray.opacity(0.6)))
                            .textFieldStyle(.plain)
                            .textContentType(.password)
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 40)

                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.horizontal)
                }

                Spacer()

                // Login button
                Button {
                    login()
                } label: {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(isFormValid ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid ? Color.green : Color.gray.opacity(0.2))
                        .cornerRadius(25)
                }
                .disabled(!isFormValid || isLoading)
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }
            }
        }
    }

    private func login() {
        isLoading = true
        errorMessage = nil

        let result = AuthManager.shared.login(email: email, password: password)

        switch result {
        case .success:
            // Auth state will automatically update and show HomeView
            break
        case .failure(let error):
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
