//
//  MatchDetailView.swift
//  TennisChartingApp
//

import SwiftUI
import UIKit

struct MatchDetailView: View {
    let match: Match
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGray6)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Match header
                        VStack(spacing: 8) {
                            Text("\(match.playerAName) vs \(match.playerBName)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)

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
                                    .foregroundColor(.black)
                                    .frame(width: 100, alignment: .leading)

                                ForEach(0..<match.sets.count, id: \.self) { index in
                                    Text("\(match.sets[index].playerAGames)")
                                        .foregroundColor(.black)
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
                                    .foregroundColor(.black)
                                    .frame(width: 100, alignment: .leading)

                                ForEach(0..<match.sets.count, id: \.self) { index in
                                    Text("\(match.sets[index].playerBGames)")
                                        .foregroundColor(.black)
                                        .fontWeight(match.sets[index].winner == .playerB ? .bold : .regular)
                                        .frame(width: 50)
                                }
                            }
                            .padding(.vertical, 12)
                        }
                        .padding(.horizontal)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                        .padding(.horizontal)

                        // Match info
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Match Info")
                                .font(.headline)
                                .foregroundColor(.black)

                            HStack {
                                Text("Format")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(match.matchFormat.displayName)
                                    .foregroundColor(.black)
                            }

                            HStack {
                                Text("First Server")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(match.firstServer == .playerA ? match.playerAName : match.playerBName)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
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
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                }
            }
            .toolbarBackground(Color(UIColor.systemGray6), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
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
