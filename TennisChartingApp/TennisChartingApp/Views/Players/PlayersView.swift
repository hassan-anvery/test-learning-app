//
//  PlayersView.swift
//  TennisChartingApp
//

import SwiftUI

struct PlayersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCreateSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGray6).ignoresSafeArea()

                if PlayerProfileStore.shared.profiles.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(PlayerProfileStore.shared.profiles) { profile in
                            NavigationLink(destination: PlayerDetailView(profile: profile)) {
                                PlayerRowView(profile: profile)
                            }
                            .listRowBackground(Color.white)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    PlayerProfileStore.shared.deleteProfile(profile)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                    }
                }
            }
            .toolbarBackground(Color(UIColor.systemGray6), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showCreateSheet) {
                PlayerCreateSheet()
                    .presentationDetents([.medium])
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2")
                .font(.system(size: 40))
                .foregroundColor(Color(UIColor.systemGray3))
            Text("No players yet")
                .font(.headline)
                .foregroundColor(.black)
            Text("Add players you regularly face\nto track your head-to-head record.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Button {
                showCreateSheet = true
            } label: {
                Text("Add Player")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.18, green: 0.55, blue: 0.45))
                    .cornerRadius(20)
            }
            .padding(.top, 4)
        }
        .padding()
    }
}

// MARK: - Player Row

struct PlayerRowView: View {
    let profile: PlayerProfile

    private var matchCount: Int {
        MatchStore.shared.matches.filter { $0.opponentProfileId == profile.id }.count
    }

    private var lastPlayedString: String? {
        guard let latest = MatchStore.shared.matches.first(where: { $0.opponentProfileId == profile.id }) else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: latest.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(profile.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
            if matchCount > 0, let lastPlayed = lastPlayedString {
                Text("\(matchCount) match\(matchCount == 1 ? "" : "es") · Last: \(lastPlayed)")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            } else {
                Text("No matches yet")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Create Sheet

struct PlayerCreateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var notes = ""
    @FocusState private var nameFocused: Bool

    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedNotes: String { notes.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGray6).ignoresSafeArea()

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NAME")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        TextField("e.g. Rafael Nadal", text: $name)
                            .focused($nameFocused)
                            .font(.system(size: 17))
                            .foregroundColor(.black)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOTES (OPTIONAL)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        TextField("Playing style, strengths, weaknesses...", text: $notes, axis: .vertical)
                            .font(.system(size: 17))
                            .foregroundColor(.black)
                            .lineLimit(3...5)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("New Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let profile = PlayerProfile(
                            name: trimmedName,
                            notes: trimmedNotes.isEmpty ? nil : trimmedNotes
                        )
                        PlayerProfileStore.shared.addProfile(profile)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(trimmedName.isEmpty
                        ? .gray
                        : Color(red: 0.18, green: 0.55, blue: 0.45))
                    .disabled(trimmedName.isEmpty)
                }
            }
            .toolbarBackground(Color(UIColor.systemGray6), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear { nameFocused = true }
        }
    }
}
