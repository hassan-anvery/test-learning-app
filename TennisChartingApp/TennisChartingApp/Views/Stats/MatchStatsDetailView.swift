//
//  MatchStatsDetailView.swift
//  TennisChartingApp
//

import SwiftUI
import Charts

struct MatchStatsDetailView: View {
    let match: Match
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPointIndex: Int? = nil
    @State private var editingContext: EditingContext? = nil

    // Helper struct to track point location for editing
    struct TimelinePoint: Identifiable {
        let id: Int  // pointIndex (0-based, used for display as "Point N+1")
        let point: Point?  // nil for tiebreak points
        let setIndex: Int
        let gameIndex: Int
        let pointInGameIndex: Int
    }

    // Combined editing state to avoid race conditions with fullScreenCover
    struct EditingContext: Identifiable {
        let id = UUID()
        let timelinePoint: TimelinePoint
        let player: PlayerSide
        let point: Point
    }

    private var currentMatch: Match {
        MatchStore.shared.getMatch(by: match.id) ?? match
    }

    private var momentumData: [MomentumPoint] {
        var data: [MomentumPoint] = []
        var momentum: Int = 0
        var pointIndex = 0

        for set in currentMatch.sets {
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

    private var timelinePoints: [TimelinePoint] {
        var points: [TimelinePoint] = []
        var pointIndex = 0

        for (setIdx, set) in currentMatch.sets.enumerated() {
            for (gameIdx, game) in set.games.enumerated() {
                for (pointIdx, point) in game.points.enumerated() {
                    points.append(TimelinePoint(
                        id: pointIndex,
                        point: point,
                        setIndex: setIdx,
                        gameIndex: gameIdx,
                        pointInGameIndex: pointIdx
                    ))
                    pointIndex += 1
                }
            }

            // Add tiebreak points (no editable Point data)
            if let tiebreak = set.tiebreakScore {
                let totalTiebreakPoints = tiebreak.playerAPoints + tiebreak.playerBPoints
                for _ in 0..<totalTiebreakPoints {
                    points.append(TimelinePoint(
                        id: pointIndex,
                        point: nil,
                        setIndex: setIdx,
                        gameIndex: -1,
                        pointInGameIndex: -1
                    ))
                    pointIndex += 1
                }
            }
        }

        return points
    }

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.96, blue: 0.96)
                .ignoresSafeArea()

            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(currentMatch.playerAName) vs \(currentMatch.playerBName)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Text(currentMatch.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            // Score summary
                            HStack(spacing: 12) {
                                ForEach(Array(currentMatch.sets.enumerated()), id: \.offset) { _, set in
                                    Text("\(set.playerAGames)-\(set.playerBGames)")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }

                                if let winner = currentMatch.winner {
                                    Spacer()
                                    Text(winner == .playerA ? "\(currentMatch.playerAName) won" : "\(currentMatch.playerBName) won")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Large Momentum Graph
                        if !momentumData.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Match Momentum")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)

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

                                    // Selected point indicator
                                    if let selected = selectedPointIndex {
                                        RuleMark(x: .value("Selected", selected))
                                            .foregroundStyle(Color.green.opacity(0.6))
                                            .lineStyle(StrokeStyle(lineWidth: 2))
                                    }
                                }
                                .frame(height: 250)
                                .chartYAxis(.hidden)
                                .chartXAxis(.hidden)
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
                                                    selectedPointIndex = nearest.index
                                                    // Auto-scroll to selected point
                                                    withAnimation {
                                                        scrollProxy.scrollTo(nearest.index, anchor: .center)
                                                    }
                                                }
                                            }
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                                .padding(.horizontal)

                                // Player labels
                                HStack {
                                    Text(currentMatch.playerAName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("Tap graph to select point")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(currentMatch.playerBName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal)
                            }
                        }

                        MatchInsightsCard(match: currentMatch)

                        // Notes Timeline
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Point-by-Point Notes")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal)

                            LazyVStack(spacing: 8) {
                                ForEach(timelinePoints) { timelinePoint in
                                    TimelinePointRow(
                                        timelinePoint: timelinePoint,
                                        match: currentMatch,
                                        isSelected: selectedPointIndex == timelinePoint.id,
                                        onTap: {
                                            selectedPointIndex = timelinePoint.id
                                        },
                                        onEditNoteA: {
                                            if let point = timelinePoint.point {
                                                editingContext = EditingContext(
                                                    timelinePoint: timelinePoint,
                                                    player: .playerA,
                                                    point: point
                                                )
                                            }
                                        },
                                        onEditNoteB: {
                                            if let point = timelinePoint.point {
                                                editingContext = EditingContext(
                                                    timelinePoint: timelinePoint,
                                                    player: .playerB,
                                                    point: point
                                                )
                                            }
                                        }
                                    )
                                    .id(timelinePoint.id)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Match Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 0.96, green: 0.96, blue: 0.96), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .fullScreenCover(item: $editingContext) { context in
            ZStack {
                Color.black.ignoresSafeArea()

                NoteEntryView(
                    playerName: context.player == .playerA ? currentMatch.playerAName : currentMatch.playerBName,
                    existingNote: context.player == .playerA ? context.point.note : context.point.playerBNote
                ) { note in
                    saveNote(note, for: context.timelinePoint, player: context.player)
                    editingContext = nil
                }
            }
            .interactiveDismissDisabled(true)
        }
    }

    private func saveNote(_ note: PointNote, for timelinePoint: TimelinePoint, player: PlayerSide) {
        var updatedMatch = currentMatch
        guard timelinePoint.setIndex >= 0,
              timelinePoint.gameIndex >= 0,
              timelinePoint.pointInGameIndex >= 0 else { return }

        var noteWithSubject = note
        noteWithSubject.playerSubject = player

        if player == .playerA {
            updatedMatch.sets[timelinePoint.setIndex]
                .games[timelinePoint.gameIndex]
                .points[timelinePoint.pointInGameIndex].note = noteWithSubject
        } else {
            updatedMatch.sets[timelinePoint.setIndex]
                .games[timelinePoint.gameIndex]
                .points[timelinePoint.pointInGameIndex].playerBNote = noteWithSubject
        }

        MatchStore.shared.updateMatch(updatedMatch)
    }
}

private struct MatchInsightsCard: View {
    let match: Match

    private var allPlayerANotes: [PointNote] {
        match.sets.flatMap(\.games).flatMap(\.points).compactMap(\.note)
    }

    private var topWinningShot: (howWon: HowPointWon, count: Int)? {
        let shots = match.sets.flatMap(\.games).flatMap(\.points).compactMap { point -> HowPointWon? in
            guard point.winner == .playerA, let howWon = point.note?.howWon else { return nil }
            return howWon
        }
        guard shots.count >= 2 else { return nil }
        let freq = shots.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        return freq.max(by: { $0.value < $1.value }).map { ($0.key, $0.value) }
    }

    private var dominantAttitude: (attitude: Attitude, count: Int)? {
        let attitudes = allPlayerANotes.compactMap(\.attitude)
        guard attitudes.count >= 2 else { return nil }
        let freq = attitudes.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        return freq.max(by: { $0.value < $1.value }).map { ($0.key, $0.value) }
    }

    private var recurringNegative: (attitude: Attitude, count: Int)? {
        let negatives = allPlayerANotes.compactMap(\.attitude).filter { [.rushed, .angry, .dejected].contains($0) }
        guard negatives.count >= 2 else { return nil }
        let freq = negatives.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        return freq.max(by: { $0.value < $1.value }).map { ($0.key, $0.value) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Match Insights")
                .font(.headline)
                .foregroundColor(.primary)

            VStack(spacing: 8) {
                insightRow(
                    label: "Top winning shot",
                    value: topWinningShot.map { "\($0.howWon.rawValue) (\($0.count)×)" } ?? "Not enough tagged points",
                    valueColor: topWinningShot != nil ? .primary : .secondary
                )
                insightRow(
                    label: "Dominant attitude",
                    value: dominantAttitude.map { "\($0.attitude.rawValue) (\($0.count)×)" } ?? "Not enough attitude tags",
                    valueColor: dominantAttitude != nil ? .primary : .secondary
                )
                insightRow(
                    label: "Watch out for",
                    value: recurringNegative.map { "\($0.attitude.rawValue) (\($0.count)×)" } ?? "No recurring negative patterns",
                    valueColor: recurringNegative != nil ? .orange : .secondary
                )
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }

    private func insightRow(label: String, value: String, valueColor: Color) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(valueColor)
        }
    }
}

struct TimelinePointRow: View {
    let timelinePoint: MatchStatsDetailView.TimelinePoint
    let match: Match
    let isSelected: Bool
    let onTap: () -> Void
    let onEditNoteA: () -> Void
    let onEditNoteB: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Leading accent bar — visible when selected
            RoundedRectangle(cornerRadius: 2)
                .fill(isSelected ? Color.green : Color.clear)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 6) {
                if let point = timelinePoint.point {
                    // Header: point number · winner name · edit affordance
                    HStack(spacing: 4) {
                        Text("Point \(timelinePoint.id + 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("·")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(point.winner == .playerA ? match.playerAName : match.playerBName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(point.winner == .playerA ? .green : .red)

                        Spacer()

                        Button(action: onEditNoteA) {
                            Image(systemName: point.note != nil ? "pencil" : "plus")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }

                    // A: preview line
                    notePreviewLine(label: "A", note: point.note, color: .green, onTap: onEditNoteA)

                    // B: preview line
                    notePreviewLine(label: "B", note: point.playerBNote, color: .red, onTap: onEditNoteB)

                } else {
                    // Tiebreak — no editable data
                    HStack(spacing: 4) {
                        Text("Point \(timelinePoint.id + 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("·")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Tiebreak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()

                        Spacer()
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
        }
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: isSelected ? Color.green.opacity(0.2) : Color.black.opacity(0.05), radius: isSelected ? 4 : 2, x: 0, y: 1)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }

    @ViewBuilder
    private func notePreviewLine(label: String, note: PointNote?, color: Color, onTap: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text("\(label):")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(color)
                .frame(width: 14, alignment: .leading)

            if let note = note {
                let parts: [String] = [
                    note.howWon.map(\.rawValue),
                    note.attitude.map(\.rawValue),
                    note.additionalNotes.flatMap { $0.isEmpty ? nil : $0 }
                ].compactMap { $0 }

                Text(parts.joined(separator: " · "))
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Button(action: onTap) {
                    Text("Add note")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    NavigationStack {
        MatchStatsDetailView(match: Match(
            playerAName: "Hassan",
            playerBName: "Akshay",
            matchFormat: .bestOf3,
            startingPlayer: .playerA,
            firstServer: .playerA
        ))
    }
}
