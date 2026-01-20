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
            Color(UIColor.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header with Done button
                HStack {
                    Text("Match Score")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()

                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Score card
                VStack(spacing: 0) {
                    // Column headers
                    HStack(spacing: 0) {
                        Text("")
                            .frame(width: 140, alignment: .leading)

                        ForEach(0..<match.sets.count, id: \.self) { setIndex in
                            Text("Set \(setIndex + 1)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.gray)
                                .frame(width: 50)
                        }

                        Text("Game")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(width: 50)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)

                    Divider()

                    // Player A row
                    HStack(spacing: 0) {
                        HStack(spacing: 10) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))

                            Text(match.playerAName)
                                .font(.system(size: 16, weight: match.winner == .playerA ? .bold : .medium))
                                .foregroundColor(.black)
                        }
                        .frame(width: 140, alignment: .leading)

                        ForEach(0..<match.sets.count, id: \.self) { setIndex in
                            Text("\(match.sets[setIndex].playerAGames)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 50)
                        }

                        Text(currentGameScore(for: .playerA))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                            .frame(width: 50)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)

                    Divider()

                    // Player B row
                    HStack(spacing: 0) {
                        HStack(spacing: 10) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))

                            Text(match.playerBName)
                                .font(.system(size: 16, weight: match.winner == .playerB ? .bold : .medium))
                                .foregroundColor(.black)
                        }
                        .frame(width: 140, alignment: .leading)

                        ForEach(0..<match.sets.count, id: \.self) { setIndex in
                            Text("\(match.sets[setIndex].playerBGames)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 50)
                        }

                        Text(currentGameScore(for: .playerB))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                            .frame(width: 50)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                .padding(.horizontal, 20)

                Spacer()
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
