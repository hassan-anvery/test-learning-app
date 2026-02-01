//
//  MatchStore.swift
//  TennisChartingApp
//

import Foundation
import SwiftUI

@MainActor
@Observable
class MatchStore {
    static let shared = MatchStore()

    private(set) var matches: [Match] = []

    private var activeUserIdentifier: String?

    private init() {
        // Matches will be loaded via setActiveUser from AuthManager
    }

    private func matchesKey(for identifier: String?) -> String? {
        guard let identifier = identifier else { return nil }
        let sanitized = identifier.replacingOccurrences(of: "[^a-zA-Z0-9]", with: "_", options: .regularExpression)
        return "tennis_charting_matches_\(sanitized)"
    }

    private func loadMatches() {
        guard let key = matchesKey(for: activeUserIdentifier),
              let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Match].self, from: data) else {
            matches = []
            return
        }
        matches = decoded.sorted { $0.date > $1.date }
    }

    private func saveMatches() {
        guard let key = matchesKey(for: activeUserIdentifier) else { return }
        if let data = try? JSONEncoder().encode(matches) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func addMatch(_ match: Match) {
        matches.insert(match, at: 0)
        saveMatches()
    }

    func updateMatch(_ match: Match) {
        if let index = matches.firstIndex(where: { $0.id == match.id }) {
            matches[index] = match
            saveMatches()
        }
    }

    func deleteMatch(_ match: Match) {
        matches.removeAll { $0.id == match.id }
        saveMatches()
    }

    func getMatch(by id: UUID) -> Match? {
        matches.first { $0.id == id }
    }

    func setActiveUser(_ user: User?) {
        if let user = user {
            activeUserIdentifier = user.id.uuidString
        } else {
            activeUserIdentifier = nil
        }
        loadMatches()
    }
}
