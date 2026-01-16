//
//  MatchChartingView.swift
//  TennisChartingApp
//

import SwiftUI

struct MatchChartingView: View {
    @Environment(\.dismiss) private var dismiss
    @State var match: Match
    @State private var showEndMatchConfirmation = false
    @State private var showMatchScore = false
    @State private var showNoteForPlayerA = false
    @State private var showNoteForPlayerB = false
    @State private var pendingPointWinner: PlayerSide?

    // Current game state
    private var currentSet: MatchSet {
        match.sets.last ?? MatchSet()
    }

    private var currentGame: Game? {
        currentSet.games.last
    }

    private var playerAGameScore: String {
        guard let game = currentGame, game.winner == nil else { return "0" }

        if currentSet.isTiebreak, let tiebreak = currentSet.tiebreakScore {
            return "\(tiebreak.playerAPoints)"
        }

        return game.playerAGameScore.rawValue
    }

    private var playerBGameScore: String {
        guard let game = currentGame, game.winner == nil else { return "0" }

        if currentSet.isTiebreak, let tiebreak = currentSet.tiebreakScore {
            return "\(tiebreak.playerBPoints)"
        }

        return game.playerBGameScore.rawValue
    }

    private var isDeuce: Bool {
        guard let game = currentGame else { return false }
        return game.playerAPoints >= 3 && game.playerBPoints >= 3 && game.playerAPoints == game.playerBPoints
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        showEndMatchConfirmation = true
                    } label: {
                        Text("End Match")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                    }

                    Spacer()

                    Text(match.playerAName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        showMatchScore = true
                    } label: {
                        Text("Match Score")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                    }
                }
                .padding()

                // Player A scoring area (top half)
                Button {
                    scorePoint(for: .playerA)
                } label: {
                    VStack {
                        Spacer()
                        Text(playerAGameScore)
                            .font(.system(size: 120, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Middle divider with VS and note buttons
                HStack {
                    Button {
                        showNoteForPlayerA = true
                    } label: {
                        Text("Note")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                    }

                    Spacer()

                    // VS circle
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 50, height: 50)
                        Text("VS")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    Text(match.playerBName)
                        .font(.title3)
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        showNoteForPlayerB = true
                    } label: {
                        Text("Note")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)

                // Player B scoring area (bottom half)
                Button {
                    scorePoint(for: .playerB)
                } label: {
                    VStack {
                        Spacer()
                        Text(playerBGameScore)
                            .font(.system(size: 120, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Bottom note button for Player B
                HStack {
                    Button {
                        showNoteForPlayerB = true
                    } label: {
                        Text("Note")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .alert("End Match", isPresented: $showEndMatchConfirmation) {
            Button("Yes", role: .destructive) {
                endMatch()
            }
            Button("No", role: .cancel) { }
        } message: {
            Text("Are you sure you want to end match?")
        }
        .sheet(isPresented: $showMatchScore) {
            MatchScoreSheetView(match: match)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showNoteForPlayerA) {
            NoteEntryView(playerName: match.playerAName) { note in
                addNoteToLastPoint(for: .playerA, note: note)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showNoteForPlayerB) {
            NoteEntryView(playerName: match.playerBName) { note in
                addNoteToLastPoint(for: .playerB, note: note)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: match.isCompleted) { _, isCompleted in
            if isCompleted {
                MatchStore.shared.updateMatch(match)
                dismiss()
            }
        }
    }

    private func scorePoint(for player: PlayerSide) {
        // Ensure we have a current set and game
        if match.sets.isEmpty {
            var newSet = MatchSet()
            let newGame = Game(server: match.firstServer)
            newSet.games.append(newGame)
            match.sets.append(newSet)
        }

        guard var currentSet = match.sets.last else { return }
        let setIndex = match.sets.count - 1

        // Handle tiebreak scoring
        if currentSet.isAtTiebreak && !currentSet.isTiebreak {
            currentSet.isTiebreak = true
            currentSet.tiebreakScore = TiebreakScore(playerAPoints: 0, playerBPoints: 0)
            match.sets[setIndex] = currentSet
        }

        if currentSet.isTiebreak {
            scoreTiebreakPoint(for: player, setIndex: setIndex)
        } else {
            scoreRegularPoint(for: player, setIndex: setIndex)
        }

        // Check for match completion
        checkMatchCompletion()

        // Save the updated match
        MatchStore.shared.updateMatch(match)
    }

    private func scoreRegularPoint(for player: PlayerSide, setIndex: Int) {
        var currentSet = match.sets[setIndex]

        // Get or create current game
        if currentSet.games.isEmpty || currentSet.games.last?.winner != nil {
            let server = determineServer(for: currentSet)
            let newGame = Game(server: server)
            currentSet.games.append(newGame)
            match.sets[setIndex] = currentSet
        }

        guard let gameIndex = currentSet.games.indices.last else { return }

        // Add point
        let point = Point(winner: player)
        match.sets[setIndex].games[gameIndex].points.append(point)

        // Check if game is won
        if let winner = match.sets[setIndex].games[gameIndex].winner {
            // Check if set is won
            if let setWinner = match.sets[setIndex].winner {
                // Start new set if match isn't over
                if match.winner == nil {
                    var newSet = MatchSet()
                    let server = determineServer(for: newSet)
                    let newGame = Game(server: server)
                    newSet.games.append(newGame)
                    match.sets.append(newSet)
                }
            } else if match.sets[setIndex].isAtTiebreak {
                // Start tiebreak
                match.sets[setIndex].isTiebreak = true
                match.sets[setIndex].tiebreakScore = TiebreakScore(playerAPoints: 0, playerBPoints: 0)
            } else {
                // Start new game
                let server = determineServer(for: match.sets[setIndex])
                let newGame = Game(server: server)
                match.sets[setIndex].games.append(newGame)
            }
        }
    }

    private func scoreTiebreakPoint(for player: PlayerSide, setIndex: Int) {
        guard var tiebreakScore = match.sets[setIndex].tiebreakScore else { return }

        if player == .playerA {
            tiebreakScore.playerAPoints += 1
        } else {
            tiebreakScore.playerBPoints += 1
        }

        match.sets[setIndex].tiebreakScore = tiebreakScore

        // Check if tiebreak is won
        if let winner = tiebreakScore.winner {
            // Start new set if match isn't over
            if match.winner == nil {
                var newSet = MatchSet()
                let server = determineServer(for: newSet)
                let newGame = Game(server: server)
                newSet.games.append(newGame)
                match.sets.append(newSet)
            }
        }
    }

    private func determineServer(for set: MatchSet) -> PlayerSide {
        // Alternate server each game
        let totalGames = set.games.count
        let isEvenGame = totalGames % 2 == 0

        if match.firstServer == .playerA {
            return isEvenGame ? .playerA : .playerB
        } else {
            return isEvenGame ? .playerB : .playerA
        }
    }

    private func checkMatchCompletion() {
        if match.winner != nil {
            match.isCompleted = true
        }
    }

    private func endMatch() {
        match.isCompleted = true
        MatchStore.shared.updateMatch(match)
        dismiss()
    }

    private func addNoteToLastPoint(for player: PlayerSide, note: PointNote) {
        // Find the last point for this player and add note
        for setIndex in match.sets.indices.reversed() {
            for gameIndex in match.sets[setIndex].games.indices.reversed() {
                for pointIndex in match.sets[setIndex].games[gameIndex].points.indices.reversed() {
                    if match.sets[setIndex].games[gameIndex].points[pointIndex].winner == player {
                        match.sets[setIndex].games[gameIndex].points[pointIndex].note = note
                        MatchStore.shared.updateMatch(match)
                        return
                    }
                }
            }
        }
    }
}

#Preview {
    MatchChartingView(match: Match(
        playerAName: "Hassan",
        playerBName: "Yash",
        matchFormat: .bestOf3,
        startingPlayer: .playerA,
        firstServer: .playerA
    ))
}
