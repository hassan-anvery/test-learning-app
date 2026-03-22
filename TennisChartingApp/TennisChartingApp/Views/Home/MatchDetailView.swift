//
//  MatchDetailView.swift
//  TennisChartingApp
//

import SwiftUI
import UIKit

struct MatchDetailView: View {
    @State private var match: Match
    @Environment(\.dismiss) private var dismiss
    @State private var showReflection = false

    init(match: Match) {
        self._match = State(initialValue: match)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGray6)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Match header
                        VStack(spacing: 6) {
                            Text("\(match.playerAName) vs \(match.playerBName)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)

                            Text(match.date.formatted(date: .long, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            if let winner = match.winner {
                                Text(winner == PlayerSide.playerA ? "\(match.playerAName) Won" : "\(match.playerBName) Won")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 5)
                                    .background(Color(red: 0.18, green: 0.55, blue: 0.45).opacity(0.12))
                                    .cornerRadius(8)
                                    .padding(.top, 2)
                            } else if !match.isCompleted {
                                Text("Match In Progress")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.orange)
                                    .padding(.top, 2)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                        .padding(.top, 8)
                        .padding(.horizontal, 20)

                        // Score summary
                        VStack(spacing: 0) {
                            // Header
                            HStack(spacing: 0) {
                                Text("Player")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(width: 100, alignment: .leading)

                                ForEach(0..<match.sets.count, id: \.self) { index in
                                    Text(match.sets[index].isTiebreak ? "Set \(index + 1)\n(TB)" : "Set \(index + 1)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
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
                        .padding(.horizontal, 20)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 20)

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
                                Text(match.firstServer == PlayerSide.playerA ? match.playerAName : match.playerBName)
                                    .foregroundColor(.black)
                            }

                            HStack {
                                Text("Scoring")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(match.noAd ? "No-Ad" : "Standard")
                                    .foregroundColor(.black)
                            }

                            HStack {
                                Text("Session")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(match.sessionType.rawValue)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                        .padding(.horizontal)

                        // Reflection
                        if let reflection = match.reflection {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Reflection")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    Spacer()
                                    Button("Edit") { showReflection = true }
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                                }

                                reflectionRow(label: "What went well", value: reflection.wentWell)
                                reflectionRow(label: "What needs work", value: reflection.needsWork)
                                reflectionRow(label: "One focus for next time", value: reflection.nextFocus)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                            .padding(.horizontal)
                        } else {
                            Button { showReflection = true } label: {
                                HStack {
                                    Text("Add Reflection")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                                .padding(.horizontal)
                            }
                        }

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
            .sheet(isPresented: $showReflection) {
                ReflectionEntryView(match: $match, onDismiss: {
                    showReflection = false
                })
            }
        }
    }

    private func reflectionRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 15))
                .foregroundColor(.black)
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
