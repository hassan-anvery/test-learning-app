//
//  PlayerDetailView.swift
//  TennisChartingApp
//

import SwiftUI

struct PlayerDetailView: View {
    let profile: PlayerProfile
    @State private var selectedMatch: Match?

    private var matches: [Match] {
        MatchStore.shared.matches.filter { $0.opponentProfileId == profile.id }
    }

    private var wins: Int {
        matches.filter { $0.winner == .playerA }.count
    }

    private var losses: Int {
        matches.filter { $0.winner == .playerB }.count
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Stats card
                    HStack(spacing: 0) {
                        statCell(value: "\(matches.count)", label: "Total")
                        Divider().frame(height: 40)
                        statCell(value: "\(wins)", label: "Wins")
                        Divider().frame(height: 40)
                        statCell(value: "\(losses)", label: "Losses")
                    }
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 20)

                    // Notes card
                    if let notes = profile.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("NOTES")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                            Text(notes)
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 20)
                    }

                    // Matches
                    if matches.isEmpty {
                        VStack(spacing: 8) {
                            Text("No matches yet")
                                .font(.headline)
                                .foregroundColor(.black)
                            Text("Start a match and link it to \(profile.name)\nto track your head-to-head record.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MATCHES")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)

                            ForEach(matches) { match in
                                MatchRowView(match: match)
                                    .padding(.horizontal, 20)
                                    .onTapGesture { selectedMatch = match }
                            }
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle(profile.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedMatch) { match in
            MatchDetailView(match: match)
        }
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
