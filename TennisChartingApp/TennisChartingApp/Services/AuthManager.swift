//
//  AuthManager.swift
//  TennisChartingApp
//

import Foundation
import SwiftUI

@MainActor
@Observable
class AuthManager {
    static let shared = AuthManager()

    private(set) var currentUser: User?
    private(set) var isAuthenticated: Bool = false

    private let userDefaultsKey = "tennis_charting_users"
    private let currentUserKey = "tennis_charting_current_user"

    private init() {
        loadCurrentUser()
    }

    private func loadCurrentUser() {
        if let data = UserDefaults.standard.data(forKey: currentUserKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
            isAuthenticated = true
        }
    }

    private func loadAllUsers() -> [User] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return users
    }

    private func saveAllUsers(_ users: [User]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    private func saveCurrentUser(_ user: User?) {
        if let user = user,
           let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: currentUserKey)
        } else {
            UserDefaults.standard.removeObject(forKey: currentUserKey)
        }
    }

    private func hashPassword(_ password: String) -> String {
        // Simple hash for mock purposes - in production use proper hashing
        return password.data(using: .utf8)?.base64EncodedString() ?? password
    }

    func signUp(email: String, password: String) -> Result<User, AuthError> {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !trimmedEmail.isEmpty else {
            return .failure(.invalidEmail)
        }

        guard password.count >= 4 else {
            return .failure(.weakPassword)
        }

        var users = loadAllUsers()

        if users.contains(where: { $0.email == trimmedEmail }) {
            return .failure(.emailAlreadyExists)
        }

        let newUser = User(
            email: trimmedEmail,
            passwordHash: hashPassword(password)
        )

        users.append(newUser)
        saveAllUsers(users)
        saveCurrentUser(newUser)

        currentUser = newUser
        isAuthenticated = true

        return .success(newUser)
    }

    func login(email: String, password: String) -> Result<User, AuthError> {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let users = loadAllUsers()

        guard let user = users.first(where: { $0.email == trimmedEmail }) else {
            return .failure(.userNotFound)
        }

        guard user.passwordHash == hashPassword(password) else {
            return .failure(.wrongPassword)
        }

        saveCurrentUser(user)
        currentUser = user
        isAuthenticated = true

        return .success(user)
    }

    func logout() {
        saveCurrentUser(nil)
        currentUser = nil
        isAuthenticated = false
    }
}

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyExists
    case userNotFound
    case wrongPassword

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 4 characters"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .userNotFound:
            return "No account found with this email"
        case .wrongPassword:
            return "Incorrect password"
        }
    }
}
