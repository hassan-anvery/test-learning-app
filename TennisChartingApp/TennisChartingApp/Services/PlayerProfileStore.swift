//
//  PlayerProfileStore.swift
//  TennisChartingApp
//

import Foundation

@MainActor
@Observable
class PlayerProfileStore {
    static let shared = PlayerProfileStore()

    private(set) var profiles: [PlayerProfile] = []
    private var activeUserIdentifier: String?

    private init() { }

    func setActiveUser(_ user: User?) {
        if let user = user {
            let sanitized = user.id.uuidString.replacingOccurrences(
                of: "[^a-zA-Z0-9]",
                with: "_",
                options: .regularExpression
            )
            activeUserIdentifier = sanitized
        } else {
            activeUserIdentifier = nil
        }
        loadProfiles()
    }

    func addProfile(_ profile: PlayerProfile) {
        profiles.append(profile)
        profiles.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        saveProfiles()
    }

    func updateProfile(_ profile: PlayerProfile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
            saveProfiles()
        }
    }

    func deleteProfile(_ profile: PlayerProfile) {
        profiles.removeAll { $0.id == profile.id }
        saveProfiles()
    }

    func getProfile(by id: UUID) -> PlayerProfile? {
        profiles.first { $0.id == id }
    }

    private func storageKey() -> String? {
        guard let identifier = activeUserIdentifier else { return nil }
        return "tennis_charting_players_\(identifier)"
    }

    private func loadProfiles() {
        guard let key = storageKey(),
              let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([PlayerProfile].self, from: data) else {
            profiles = []
            return
        }
        profiles = decoded.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func saveProfiles() {
        guard let key = storageKey(),
              let data = try? JSONEncoder().encode(profiles) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
