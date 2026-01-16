//
//  MatchDetailView.swift
//  TennisChartingApp
//

import SwiftUI

struct MatchDetailView: View {
    let match: Match
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Match header
                        VStack(spacing: 8) {
                            Text("\(match.playerAName) vs \(match.playerBName)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text(match.date.formatted(date: .long, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            if let winner = match.winner {
                                Text(winner == .playerA ? "\(match.playerAName) Won" : "\(match.playerBName) Won")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .padding(.top, 4)
                            } else if !match.isCompleted {
                                Text("Match In Progress")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.top)

                        // Score summary
                        VStack(spacing: 0) {
                            // Header
                            HStack(spacing: 0) {
                                Text("")
                                    .frame(width: 100, alignment: .leading)

                                ForEach(0..<match.sets.count, id: \.self) { index in
                                    Text("Set \(index + 1)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .frame(width: 50)
                                }
                            }
                            .padding(.vertical, 8)

                            Divider()
                                .background(Color.gray)

                            // Player A
                            HStack(spacing: 0) {
                                Text(match.playerAName)
                                    .foregroundColor(.white)
                                    .frame(width: 100, alignment: .leading)

                                ForEach(0..<match.sets.count, id: \.self) { index in
                                    Text("\(match.sets[index].playerAGames)")
                                        .foregroundColor(.white)
                                        .fontWeight(match.sets[index].winner == .playerA ? .bold : .regular)
                                        .frame(width: 50)
                                }
                            }
                            .padding(.vertical, 12)

                            Divider()
                                .background(Color.gray)

                            // Player B
                            HStack(spacing: 0) {
                                Text(match.playerBName)
                                    .foregroundColor(.white)
                                    .frame(width: 100, alignment: .leading)

                                ForEach(0..<match.sets.count, id: \.self) { index in
                                    Text("\(match.sets[index].playerBGames)")
                                        .foregroundColor(.white)
                                        .fontWeight(match.sets[index].winner == .playerB ? .bold : .regular)
                                        .frame(width: 50)
                                }
                            }
                            .padding(.vertical, 12)
                        }
                        .padding(.horizontal)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)

                        // Match info
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Match Info")
                                .font(.headline)
                                .foregroundColor(.white)

                            HStack {
                                Text("Format")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(match.matchFormat.displayName)
                                    .foregroundColor(.white)
                            }

                            HStack {
                                Text("First Server")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(match.firstServer == .playerA ? match.playerAName : match.playerBName)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)

                        Spacer()
                    }
                }
            }
            .navigationTitle("Match Details")
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

#Preview {
    MatchDetailView(match: Match(
        playerAName: "Hassan",
        playerBName: "Yash",
        matchFormat: .bestOf3,
        startingPlayer: .playerA,
        firstServer: .playerA
    ))
}
