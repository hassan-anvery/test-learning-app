//
//  StatsView.swift
//  TennisChartingApp
//

import SwiftUI
import Charts

struct StatsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedMatch: Match? = nil

    private var filteredMatches: [Match] {
        let completedMatches = MatchStore.shared.matches.filter { $0.isCompleted }
        if searchText.isEmpty {
            return completedMatches
        }
        return completedMatches.filter { match in
            match.playerAName.localizedCaseInsensitiveContains(searchText) ||
            match.playerBName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.96, blue: 0.96)
                    .ignoresSafeArea()

                if MatchStore.shared.matches.isEmpty {
                    VStack {
                        Text("No matches yet")
                            .foregroundColor(.secondary)
                            .font(.title2)
                        Text("Start charting matches to see stats here")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Search bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("Search matches", text: $searchText)
                                    .foregroundColor(.primary)
                                if !searchText.isEmpty {
                                    Button {
                                        searchText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)

                            if filteredMatches.isEmpty && !searchText.isEmpty {
                                Text("No matches found")
                                    .foregroundColor(.gray)
                                    .padding(.top, 40)
                            } else {
                                ForEach(filteredMatches) { match in
                                    MatchStatsCard(match: match) { selectedMatch = match }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedMatch != nil },
                set: { if !$0 { selectedMatch = nil } }
            )) {
                if let match = selectedMatch {
                    MatchStatsDetailView(match: match)
                }
            }
            .navigationTitle("Match Stats")
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
        }
    }
}

struct MatchStatsCard: View {
    let match: Match
    let onSelect: () -> Void

    private var momentumData: [MomentumPoint] {
        // Get fresh match data from store to ensure notes are included
        guard let freshMatch = MatchStore.shared.getMatch(by: match.id) else {
            return []
        }

        var data: [MomentumPoint] = []
        var momentum: Int = 0
        var pointIndex = 0

        for set in freshMatch.sets {
            for game in set.games {
                for point in game.points {
                    if point.winner == .playerA {
                        momentum += 1
                    } else {
                        momentum -= 1
                    }
                    data.append(MomentumPoint(index: pointIndex, momentum: momentum, point: point))
                    pointIndex += 1
                }
            }

            // Add tiebreak points (no individual Point data available)
            if let tiebreak = set.tiebreakScore {
                let totalTiebreakPoints = tiebreak.playerAPoints + tiebreak.playerBPoints
                for i in 0..<totalTiebreakPoints {
                    // Approximate distribution
                    if i < tiebreak.playerAPoints {
                        momentum += 1
                    } else {
                        momentum -= 1
                    }
                    data.append(MomentumPoint(index: pointIndex, momentum: momentum, point: nil))
                    pointIndex += 1
                }
            }
        }

        return data
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Match header
            HStack {
                VStack(alignment: .leading) {
                    Text("\(match.playerAName) vs \(match.playerBName)")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(match.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Final score
                VStack(alignment: .trailing) {
                    HStack(spacing: 8) {
                        ForEach(Array(match.sets.enumerated()), id: \.offset) { _, set in
                            Text("\(set.playerAGames)-\(set.playerBGames)")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }

                    if let winner = match.winner {
                        Text(winner == .playerA ? "WIN" : "LOSS")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(winner == .playerA ? Color.green : Color.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                (winner == .playerA ? Color.green : Color.red).opacity(0.15)
                            )
                            .cornerRadius(4)
                    }
                }
            }

            // Momentum chart
            if !momentumData.isEmpty {
                Chart {
                    ForEach(momentumData) { point in
                        LineMark(
                            x: .value("Point", point.index),
                            y: .value("Momentum", point.momentum)
                        )
                        .foregroundStyle(Color.green)
                    }

                    RuleMark(y: .value("Zero", 0))
                        .foregroundStyle(Color.gray.opacity(0.2))
                }
                .frame(height: 90)
                .chartYAxis(.hidden)
                .chartXAxis(.hidden)

                HStack {
                    Text(match.playerAName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Tap for details")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(match.playerBName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

struct MomentumPoint: Identifiable {
    let id = UUID()
    let index: Int
    let momentum: Int
    let point: Point?
}

struct NotePopoverView: View {
    let point: MomentumPoint
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Text("Point \(point.index + 1)")
                .font(.headline)
                .foregroundColor(.white)

            if let gamePoint = point.point, let note = gamePoint.note {
                // Who won
                HStack {
                    Text("Won by:")
                        .foregroundColor(.gray)
                    Text(gamePoint.winner == .playerA ? match.playerAName : match.playerBName)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }

                // Note about which player
                if let subject = note.playerSubject {
                    HStack {
                        Text("Note about:")
                            .foregroundColor(.gray)
                        Text(subject == .playerA ? match.playerAName : match.playerBName)
                            .foregroundColor(.blue)
                    }
                }

                // How won
                if let howWon = note.howWon {
                    HStack {
                        Text("How:")
                            .foregroundColor(.gray)
                        Text(howWon.rawValue)
                            .foregroundColor(.green)
                    }
                }

                // Attitude
                if let attitude = note.attitude {
                    HStack {
                        Text("Attitude:")
                            .foregroundColor(.gray)
                        Text(attitude.rawValue)
                            .foregroundColor(.orange)
                    }
                }

                // Additional notes
                if let additionalNotes = note.additionalNotes, !additionalNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes:")
                            .foregroundColor(.gray)
                        Text(additionalNotes)
                            .foregroundColor(.white)
                    }
                }
            } else if let gamePoint = point.point {
                // Point exists but no notes
                HStack {
                    Text("Won by:")
                        .foregroundColor(.gray)
                    Text(gamePoint.winner == .playerA ? match.playerAName : match.playerBName)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
                Text("No notes recorded")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                // Tiebreak point (no detailed data)
                Text("Tiebreak point")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
        .padding()
        .frame(minWidth: 200)
        .background(Color.black.opacity(0.9))
    }
}

#Preview {
    StatsView()
}
