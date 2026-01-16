//
//  MatchScoreSheetView.swift
//  TennisChartingApp
//

import SwiftUI

struct MatchScoreSheetView: View {
    let match: Match
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HStack {
                    Spacer()
                    Text("Match Score")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top)

                // Score table
                VStack(spacing: 0) {
                    // Header row
                    HStack(spacing: 0) {
                        Text("")
                            .frame(width: 120, alignment: .leading)

                        ForEach(0..<match.sets.count, id: \.self) { setIndex in
                            Text("Set \(setIndex + 1)")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(width: 50)
                        }

                        Text("Game")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(width: 50)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)

                    Divider()
                        .background(Color.gray)

                    // Player A row
                    HStack(spacing: 0) {
                        Text(match.playerAName)
                            .foregroundColor(.white)
                            .fontWeight(match.winner == .playerA ? .bold : .regular)
                            .frame(width: 120, alignment: .leading)

                        ForEach(0..<match.sets.count, id: \.self) { setIndex in
                            Text("\(match.sets[setIndex].playerAGames)")
                                .foregroundColor(.white)
                                .frame(width: 50)
                        }

                        Text(currentGameScore(for: .playerA))
                            .foregroundColor(.green)
                            .frame(width: 50)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)

                    Divider()
                        .background(Color.gray)

                    // Player B row
                    HStack(spacing: 0) {
                        Text(match.playerBName)
                            .foregroundColor(.white)
                            .fontWeight(match.winner == .playerB ? .bold : .regular)
                            .frame(width: 120, alignment: .leading)

                        ForEach(0..<match.sets.count, id: \.self) { setIndex in
                            Text("\(match.sets[setIndex].playerBGames)")
                                .foregroundColor(.white)
                                .frame(width: 50)
                        }

                        Text(currentGameScore(for: .playerB))
                            .foregroundColor(.green)
                            .frame(width: 50)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                }
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()

                Text("Swipe down to return")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)
            }
        }
    }

    private func currentGameScore(for player: PlayerSide) -> String {
        guard let currentSet = match.sets.last,
              let currentGame = currentSet.games.last,
              currentGame.winner == nil else {
            return "0"
        }

        if currentSet.isTiebreak, let tiebreak = currentSet.tiebreakScore {
            return player == .playerA ? "\(tiebreak.playerAPoints)" : "\(tiebreak.playerBPoints)"
        }

        return player == .playerA ? currentGame.playerAGameScore.rawValue : currentGame.playerBGameScore.rawValue
    }
}

#Preview {
    MatchScoreSheetView(match: Match(
        playerAName: "Hassan",
        playerBName: "Yash",
        matchFormat: .bestOf3,
        startingPlayer: .playerA,
        firstServer: .playerA
    ))
}
