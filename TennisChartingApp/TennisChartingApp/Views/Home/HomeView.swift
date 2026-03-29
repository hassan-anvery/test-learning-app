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
    @State private var showReflections = false
    @State private var showFilters = false
    @State private var filterSessionType: SessionType? = nil
    @State private var filterResult: ResultFilter? = nil
    @State private var filterReflection: Bool? = nil
    @State private var searchText = ""

    private var hasActiveFilters: Bool {
        filterSessionType != nil || filterResult != nil || filterReflection != nil
    }

    private var filteredMatches: [Match] {
        let filtered = MatchStore.shared.matches.filter { match in
            if let st = filterSessionType, match.sessionType != st { return false }
            if let rf = filterResult {
                switch rf {
                case .win:        if match.winner != .playerA { return false }
                case .loss:       if match.winner != .playerB { return false }
                case .inProgress: if match.isCompleted { return false }
                }
            }
            if let hasRef = filterReflection {
                if hasRef && match.reflection == nil { return false }
                if !hasRef && match.reflection != nil { return false }
            }
            return true
        }
        guard !searchText.isEmpty else { return filtered }
        return filtered.filter {
            $0.playerAName.localizedCaseInsensitiveContains(searchText) ||
            $0.playerBName.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedMatches: [(month: String, matches: [Match])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        var groups: [(month: String, matches: [Match])] = []
        var currentKey: String?
        var currentGroup: [Match] = []
        for match in filteredMatches {
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

                // Search bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by player name", text: $searchText)
                        .foregroundColor(.black)
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(UIColor.systemGray3))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 20)
                .padding(.top, 8)

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
                    filtersActive: hasActiveFilters,
                    onFiltersPressed: { showFilters = true },
                    onNewMatchPressed: { showMatchSetup = true },
                    onReflectPressed: { showReflections = true }
                )
            }
        }
        .fullScreenCover(isPresented: $showMatchSetup) {
            MatchSetupView()
        }
        .sheet(isPresented: $showFilters) {
            FilterSheetView(
                sessionType: $filterSessionType,
                result: $filterResult,
                reflection: $filterReflection
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showReflections) {
            ReflectionsView()
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

            Text(match.sessionType.rawValue)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(uiColor: .systemGray2))

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
    let filtersActive: Bool
    let onFiltersPressed: () -> Void
    let onNewMatchPressed: () -> Void
    let onReflectPressed: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onFiltersPressed) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                    if filtersActive {
                        Circle()
                            .fill(Color(red: 0.18, green: 0.55, blue: 0.45))
                            .frame(width: 8, height: 8)
                            .offset(x: 4, y: 4)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            Button(action: onNewMatchPressed) {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color(red: 0.18, green: 0.55, blue: 0.45))
                    .clipShape(Circle())
            }

            Button(action: onReflectPressed) {
                Image(systemName: "lightbulb")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct ReflectionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMatch: Match?

    private var matchesWithReflections: [Match] {
        MatchStore.shared.matches.filter { $0.reflection != nil }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGray6).ignoresSafeArea()

                if matchesWithReflections.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "lightbulb")
                            .font(.system(size: 40))
                            .foregroundColor(Color(UIColor.systemGray3))
                        Text("No reflections yet")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text("After completing a match, add a reflection\nto track what you're learning.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List(matchesWithReflections) { match in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(match.playerAName) vs \(match.playerBName)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                            Text(match.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.gray)
                            if let focus = match.reflection?.nextFocus, !focus.isEmpty {
                                Text("Focus: \(focus)")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.white)
                        .onTapGesture { selectedMatch = match }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .sheet(item: $selectedMatch) { match in
                ReflectionSheetWrapper(match: match, onDismiss: { selectedMatch = nil })
            }
            .navigationTitle("Reflections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                }
            }
        }
    }
}

private struct ReflectionSheetWrapper: View {
    @State var match: Match
    let onDismiss: () -> Void

    var body: some View {
        ReflectionEntryView(match: $match, onDismiss: onDismiss)
    }
}

#Preview {
    HomeView()
}
