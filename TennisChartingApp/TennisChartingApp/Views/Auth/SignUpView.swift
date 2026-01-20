//
//  SignUpView.swift
//  TennisChartingApp
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var isPasswordVisible = false
    @State private var showLogin = false

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.45)

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        password.count >= 8
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Top nav row
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Text("Create Account")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                    Spacer()
                    // Invisible spacer for centering
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()
                    .frame(height: 40)

                // Main heading
                Text("Get Started")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)

                Spacer()
                    .frame(height: 8)

                // Subtitle
                Text("Analyze matches with professional precision.")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 24)

                Spacer()
                    .frame(height: 32)

                // Form fields
                VStack(alignment: .leading, spacing: 20) {
                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.black)

                        TextField("coach@example.com", text: $email)
                            .font(.system(size: 17))
                            .padding(.horizontal, 20)
                            .frame(height: 52)
                            .background(Color(.systemGray6))
                            .cornerRadius(26)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                    }

                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.black)

                        HStack {
                            if isPasswordVisible {
                                TextField("", text: $password)
                                    .font(.system(size: 17))
                                    .textContentType(.newPassword)
                            } else {
                                SecureField("", text: $password)
                                    .font(.system(size: 17))
                                    .textContentType(.newPassword)
                            }
                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(height: 52)
                        .background(Color(.systemGray6))
                        .cornerRadius(26)

                        // Password hints
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Text("At least 8 characters")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Text("Include a symbol or number")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 24)

                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                }

                Spacer()

                // Begin button
                VStack(spacing: 16) {
                    Button {
                        signUp()
                    } label: {
                        Text("Begin")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(isFormValid ? .white : .gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(isFormValid ? brandGreen : Color(.systemGray5))
                            .cornerRadius(28)
                    }
                    .disabled(!isFormValid || isLoading)

                    // Footer
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        Button {
                            showLogin = true
                        } label: {
                            Text("Log in")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(brandGreen)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showLogin) {
            LoginView()
        }
    }

    private func signUp() {
        isLoading = true
        errorMessage = nil

        let result = AuthManager.shared.signUp(email: email, password: password)

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
        SignUpView()
    }
}
