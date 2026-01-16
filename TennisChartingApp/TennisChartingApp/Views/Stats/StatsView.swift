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

    private var momentumData: [MomentumPoint] {
        var data: [MomentumPoint] = []
        var momentum: Int = 0
        var pointIndex = 0

        for set in match.sets {
            for game in set.games {
                for point in game.points {
                    if point.winner == .playerA {
                        momentum += 1
                    } else {
                        momentum -= 1
                    }
                    data.append(MomentumPoint(index: pointIndex, momentum: momentum))
                    pointIndex += 1
                }
            }

            // Add tiebreak points
            if let tiebreak = set.tiebreakScore {
                let totalTiebreakPoints = tiebreak.playerAPoints + tiebreak.playerBPoints
                for i in 0..<totalTiebreakPoints {
                    // Approximate distribution
                    if i < tiebreak.playerAPoints {
                        momentum += 1
                    } else {
                        momentum -= 1
                    }
                    data.append(MomentumPoint(index: pointIndex, momentum: momentum))
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
}

#Preview {
    StatsView()
}
