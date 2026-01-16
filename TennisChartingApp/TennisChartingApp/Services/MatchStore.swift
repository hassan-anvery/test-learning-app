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

    private let matchesKey = "tennis_charting_matches"

    private init() {
        loadMatches()
    }

    private func loadMatches() {
        guard let data = UserDefaults.standard.data(forKey: matchesKey),
              let decoded = try? JSONDecoder().decode([Match].self, from: data) else {
            return
        }
        matches = decoded.sorted { $0.date > $1.date }
    }

    private func saveMatches() {
        if let data = try? JSONEncoder().encode(matches) {
            UserDefaults.standard.set(data, forKey: matchesKey)
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
}
