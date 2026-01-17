//
//  StatsView.swift
//  TennisChartingApp
//

import SwiftUI
import Charts

struct StatsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                if MatchStore.shared.matches.isEmpty {
                    VStack {
                        Text("No matches yet")
                            .foregroundColor(.gray)
                            .font(.title2)
                        Text("Start charting matches to see stats here")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(MatchStore.shared.matches.filter { $0.isCompleted }) { match in
                                MatchStatsCard(match: match)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Match Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct MatchStatsCard: View {
    let match: Match
    @State private var selectedPoint: MomentumPoint?

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
                        .foregroundColor(.white)

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
                                .foregroundColor(.white)
                        }
                    }

                    if let winner = match.winner {
                        Text(winner == .playerA ? "\(match.playerAName) won" : "\(match.playerBName) won")
                            .font(.caption)
                            .foregroundColor(.green)
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
                        .foregroundStyle(Color.gray.opacity(0.5))
                        .lineStyle(StrokeStyle(dash: [5, 5]))
                }
                .frame(height: 150)
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.gray.opacity(0.3))
                        AxisValueLabel()
                            .foregroundStyle(Color.gray)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.gray.opacity(0.3))
                    }
                }
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture { location in
                                guard let plotFrame = proxy.plotFrame else { return }
                                let xPosition = location.x - geometry[plotFrame].origin.x
                                guard let index: Int = proxy.value(atX: xPosition) else { return }

                                // Find the nearest point
                                if let nearest = momentumData.min(by: { abs($0.index - index) < abs($1.index - index) }) {
                                    selectedPoint = nearest
                                }
                            }
                    }
                }
                .popover(item: $selectedPoint) { point in
                    NotePopoverView(point: point, match: MatchStore.shared.getMatch(by: match.id) ?? match)
                }

                HStack {
                    Text(match.playerAName)
                        .font(.caption)
                        .foregroundColor(.green)
                    Spacer()
                    Text("Match Charting")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(match.playerBName)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
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
