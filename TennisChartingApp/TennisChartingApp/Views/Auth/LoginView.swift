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
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Header
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // Form fields
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email:")
                            .foregroundColor(.white)
                            .font(.headline)

                        TextField("", text: $email)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password:")
                            .foregroundColor(.white)
                            .font(.headline)

                        SecureField("", text: $password)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .textContentType(.password)
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
                        .foregroundColor(isFormValid ? .black : .gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid ? Color.white : Color.white.opacity(0.3))
                        .cornerRadius(8)
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
                        .foregroundColor(.white)
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
