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
    @State private var editingTimelinePoint: TimelinePoint? = nil

    // Helper struct to track point location for editing
    struct TimelinePoint: Identifiable {
        let id: Int  // pointIndex (0-based, used for display as "Point N+1")
        let point: Point?  // nil for tiebreak points
        let setIndex: Int
        let gameIndex: Int
        let pointInGameIndex: Int
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
            Color.black
                .ignoresSafeArea()

            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(currentMatch.playerAName) vs \(currentMatch.playerBName)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text(currentMatch.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            // Score summary
                            HStack(spacing: 12) {
                                ForEach(Array(currentMatch.sets.enumerated()), id: \.offset) { _, set in
                                    Text("\(set.playerAGames)-\(set.playerBGames)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }

                                if let winner = currentMatch.winner {
                                    Spacer()
                                    Text(winner == .playerA ? "\(currentMatch.playerAName) won" : "\(currentMatch.playerBName) won")
                                        .font(.subheadline)
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
                                    .foregroundColor(.white)
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
                                        .foregroundStyle(Color.gray.opacity(0.5))
                                        .lineStyle(StrokeStyle(dash: [5, 5]))

                                    // Selected point indicator
                                    if let selected = selectedPointIndex {
                                        RuleMark(x: .value("Selected", selected))
                                            .foregroundStyle(Color.white.opacity(0.8))
                                            .lineStyle(StrokeStyle(lineWidth: 2))
                                    }
                                }
                                .frame(height: 250)
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
                                                    selectedPointIndex = nearest.index
                                                    // Auto-scroll to selected point
                                                    withAnimation {
                                                        scrollProxy.scrollTo(nearest.index, anchor: .center)
                                                    }
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal)

                                // Player labels
                                HStack {
                                    Text(currentMatch.playerAName)
                                        .font(.caption)
                                        .foregroundColor(.green)
                                    Spacer()
                                    Text("Tap graph to select point")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(currentMatch.playerBName)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Notes Timeline
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Point-by-Point Notes")
                                .font(.headline)
                                .foregroundColor(.white)
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
                                        onEditNote: {
                                            if timelinePoint.point != nil {
                                                editingTimelinePoint = timelinePoint
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
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(item: $editingTimelinePoint) { timelinePoint in
            if let point = timelinePoint.point {
                let playerName = point.winner == .playerA ? currentMatch.playerAName : currentMatch.playerBName
                NoteEntryView(playerName: playerName) { note in
                    saveNote(note, for: timelinePoint)
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private func saveNote(_ note: PointNote, for timelinePoint: TimelinePoint) {
        var updatedMatch = currentMatch
        guard timelinePoint.setIndex >= 0,
              timelinePoint.gameIndex >= 0,
              timelinePoint.pointInGameIndex >= 0 else { return }

        // Set the player subject based on who won the point
        var noteWithSubject = note
        if let point = timelinePoint.point {
            noteWithSubject.playerSubject = point.winner
        }

        updatedMatch.sets[timelinePoint.setIndex]
            .games[timelinePoint.gameIndex]
            .points[timelinePoint.pointInGameIndex].note = noteWithSubject

        MatchStore.shared.updateMatch(updatedMatch)
    }
}

struct TimelinePointRow: View {
    let timelinePoint: MatchStatsDetailView.TimelinePoint
    let match: Match
    let isSelected: Bool
    let onTap: () -> Void
    let onEditNote: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Point number
            Text("Point \(timelinePoint.id + 1)")
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .gray)
                .frame(width: 70, alignment: .leading)

            if let point = timelinePoint.point {
                // Winner indicator
                Text(point.winner == .playerA ? match.playerAName : match.playerBName)
                    .font(.caption)
                    .foregroundColor(point.winner == .playerA ? .green : .red)
                    .frame(width: 80, alignment: .leading)

                // Note preview or add button
                if let note = point.note {
                    VStack(alignment: .leading, spacing: 2) {
                        if let howWon = note.howWon {
                            Text(howWon.rawValue)
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        if let attitude = note.attitude {
                            Text(attitude.rawValue)
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                        if let additionalNotes = note.additionalNotes, !additionalNotes.isEmpty {
                            Text(additionalNotes)
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Button(action: onEditNote) {
                        Text("Add note")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Edit button if note exists
                if timelinePoint.point?.note != nil {
                    Button(action: onEditNote) {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            } else {
                // Tiebreak point
                Text("Tiebreak")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .italic()
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
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
