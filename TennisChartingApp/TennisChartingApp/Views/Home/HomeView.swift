//
//  HomeView.swift
//  TennisChartingApp
//

import SwiftUI

struct HomeView: View {
    @State private var showMatchSetup = false
    @State private var showStats = false
    @State private var showProfile = false
    @State private var selectedMatch: Match?
    @State private var inProgressMatch: Match?
    @State private var showResumeDialog = false
    @State private var matchToResume: Match?
    @State private var matchToDelete: Match?
    @State private var showDeleteConfirmation = false

    private var groupedMatches: [(month: String, matches: [Match])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        var groups: [(month: String, matches: [Match])] = []
        var currentKey: String?
        var currentGroup: [Match] = []
        for match in MatchStore.shared.matches {
            let key = formatter.string(from: match.date)
            if key == currentKey {
                currentGroup.append(match)
            } else {
                if let prev = currentKey { groups.append((prev, currentGroup)) }
                currentKey = key
                currentGroup = [match]
            }
        }
        if let last = currentKey { groups.append((last, currentGroup)) }
        return groups
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with stats and profile
                HStack {
                    Button {
                        showStats = true
                    } label: {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title2)
                            .foregroundColor(.black)
                    }

                    Spacer()

                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Match History")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Match list
                List {
                    ForEach(groupedMatches, id: \.month) { group in
                        Section(header:
                            Text(group.month)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.gray)
                                .textCase(nil)
                        ) {
                            ForEach(group.matches) { match in
                                MatchRowView(match: match)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                    .onTapGesture {
                                        if !match.isCompleted {
                                            inProgressMatch = match
                                            showResumeDialog = true
                                        } else {
                                            selectedMatch = match
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            matchToDelete = match
                                            showDeleteConfirmation = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                Spacer()

                // Bottom tab bar
                BottomTabBar(
                    onPlusPressed: { showMatchSetup = true }
                )
            }
        }
        .fullScreenCover(isPresented: $showMatchSetup) {
            MatchSetupView()
        }
        .sheet(isPresented: $showStats) {
            StatsView()
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .sheet(item: $selectedMatch) { match in
            MatchDetailView(match: match)
        }
        .fullScreenCover(item: $matchToResume) { match in
            MatchChartingView(match: match)
        }
        .confirmationDialog("", isPresented: $showResumeDialog, titleVisibility: .hidden) {
            Button("Resume Match") {
                matchToResume = inProgressMatch
                inProgressMatch = nil
            }
            Button("View Match Details") {
                selectedMatch = inProgressMatch
                inProgressMatch = nil
            }
            Button("Cancel", role: .cancel) {
                inProgressMatch = nil
            }
        }
        .alert("Delete Match", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let match = matchToDelete {
                    MatchStore.shared.deleteMatch(match)
                }
                matchToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                matchToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this match? This cannot be undone.")
        }
    }
}

struct MatchRowView: View {
    let match: Match

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: match.date).uppercased()
    }

    private var badgeText: String {
        if match.winner == PlayerSide.playerA { return "WIN" }
        if match.winner == PlayerSide.playerB { return "LOSS" }
        if match.isCompleted { return "ENDED" }
        return "IN PROGRESS"
    }

    private var badgeColor: Color {
        if match.winner == PlayerSide.playerA { return Color(red: 0.18, green: 0.55, blue: 0.45) }
        if match.winner == PlayerSide.playerB { return Color(red: 0.8, green: 0.3, blue: 0.3) }
        if match.isCompleted { return Color(uiColor: .systemGray3) }
        return Color.gray
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top row: date + badge
            HStack {
                Text(dateString)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
                Text(badgeText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(badgeColor)
                    .cornerRadius(10)
            }

            // Match title
            Text("\(match.playerAName) vs. \(match.playerBName)")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)

            // Scores - two row layout
            if !match.sets.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    // Player A scores (larger)
                    HStack(spacing: 16) {
                        ForEach(match.sets) { set in
                            Text("\(set.playerAGames)")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 24)
                        }
                    }
                    // Player B scores (smaller, gray)
                    HStack(spacing: 16) {
                        ForEach(match.sets) { set in
                            Text("\(set.playerBGames)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                                .frame(width: 24)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

struct BottomTabBar: View {
    let onPlusPressed: () -> Void

    var body: some View {
        Button(action: onPlusPressed) {
            Image(systemName: "plus")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color(red: 0.18, green: 0.55, blue: 0.45))
                .clipShape(Circle())
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    HomeView()
}
