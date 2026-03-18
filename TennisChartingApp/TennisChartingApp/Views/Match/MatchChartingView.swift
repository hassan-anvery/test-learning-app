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
    @State private var undoStack: [Match] = []

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

    private var canUndo: Bool {
        !undoStack.isEmpty && !match.isCompleted
    }

    private var hasRecordedPoints: Bool {
        match.sets.contains { $0.games.contains { !$0.points.isEmpty } }
    }

    private var lastPointNotes: (playerA: PointNote?, playerB: PointNote?) {
        for set in match.sets.reversed() {
            for game in set.games.reversed() {
                if let point = game.points.last {
                    return (point.note, point.playerBNote)
                }
            }
        }
        return (nil, nil)
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                Spacer()

                playerABlock

                Spacer()

                scoreCard

                Spacer()

                playerBBlock

                Spacer()

                notesBar
            }
            .padding(.bottom, 16)
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
        .fullScreenCover(isPresented: $showNoteForPlayerA) {
            NoteEntryView(
                playerName: match.playerAName,
                existingNote: lastPointNotes.playerA
            ) { note in
                addNoteToLastPoint(for: .playerA, note: note)
            }
            .interactiveDismissDisabled(true)
        }
        .fullScreenCover(isPresented: $showNoteForPlayerB) {
            NoteEntryView(
                playerName: match.playerBName,
                existingNote: lastPointNotes.playerB
            ) { note in
                addNoteToLastPoint(for: .playerB, note: note)
            }
            .interactiveDismissDisabled(true)
        }
        .onChange(of: match.isCompleted) { _, isCompleted in
            if isCompleted {
                MatchStore.shared.updateMatch(match)
                dismiss()
            }
        }
    }

    // MARK: - UI Components

    private var topBar: some View {
        HStack {
            // End Match button
            Button {
                showEndMatchConfirmation = true
            } label: {
                Text("End Match")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }

            Spacer()

            // Undo button
            Button {
                undoLastPoint()
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(canUndo ? .black : .gray)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            .disabled(!canUndo)

            // Set indicator
            VStack(spacing: 2) {
                Text("SET \(match.sets.count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
                Text("\(currentSet.playerAGames)-\(currentSet.playerBGames)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
            }

            Spacer()

            // Match Score button
            Button {
                showMatchScore = true
            } label: {
                Text("Stats")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var playerABlock: some View {
        Button {
            scorePoint(for: .playerA)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                Text(match.playerAName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                Text("Tap to award point")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }

    private var scoreCard: some View {
        VStack(spacing: 8) {
            Text("GAME SCORE")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)

            HStack(spacing: 24) {
                Text(playerAGameScore)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.black)
                    .frame(minWidth: 60)

                Text("-")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.gray)

                Text(playerBGameScore)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.black)
                    .frame(minWidth: 60)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 40)
    }

    private var playerBBlock: some View {
        Button {
            scorePoint(for: .playerB)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                Text(match.playerBName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                Text("Tap to award point")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }

    private var notesBar: some View {
        HStack(spacing: 16) {
            // Note for Player A
            Button {
                showNoteForPlayerA = true
            } label: {
                Text("Note - \(match.playerAName)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(hasRecordedPoints ? .black : .gray)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            .disabled(!hasRecordedPoints)

            // Note for Player B
            Button {
                showNoteForPlayerB = true
            } label: {
                Text("Note - \(match.playerBName)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(hasRecordedPoints ? .black : .gray)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            .disabled(!hasRecordedPoints)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Scoring Logic

    private func scorePoint(for player: PlayerSide) {
        undoStack.append(match)
        if undoStack.count > 20 {
            undoStack.removeFirst()
        }

        // Ensure we have a current set and game
        if match.sets.isEmpty {
            var newSet = MatchSet()
            let newGame = Game(server: match.firstServer, noAdScoring: match.noAdScoring)
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
            let newGame = Game(server: server, noAdScoring: match.noAdScoring)
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
                    let newGame = Game(server: server, noAdScoring: match.noAdScoring)
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
                let newGame = Game(server: server, noAdScoring: match.noAdScoring)
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
                let newGame = Game(server: server, noAdScoring: match.noAdScoring)
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

    private func undoLastPoint() {
        guard let previous = undoStack.popLast() else { return }
        match = previous
        MatchStore.shared.updateMatch(match)
    }

    private func endMatch() {
        match.isCompleted = true
        MatchStore.shared.updateMatch(match)
        dismiss()
    }

    private func addNoteToLastPoint(for player: PlayerSide, note: PointNote) {
        // Find the most recent point overall and add note with player subject
        for setIndex in match.sets.indices.reversed() {
            for gameIndex in match.sets[setIndex].games.indices.reversed() {
                if let pointIndex = match.sets[setIndex].games[gameIndex].points.indices.last {
                    var noteWithSubject = note
                    noteWithSubject.playerSubject = player
                    if player == .playerA {
                        match.sets[setIndex].games[gameIndex].points[pointIndex].note = noteWithSubject
                    } else {
                        match.sets[setIndex].games[gameIndex].points[pointIndex].playerBNote = noteWithSubject
                    }
                    MatchStore.shared.updateMatch(match)
                    return
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
