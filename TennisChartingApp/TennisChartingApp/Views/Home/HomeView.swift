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
    @State private var matchToDelete: Match?
    @State private var showDeleteConfirmation = false
    @State private var searchText = ""

    private var filteredMatches: [Match] {
        if searchText.isEmpty {
            return MatchStore.shared.matches
        }
        return MatchStore.shared.matches.filter { match in
            match.playerBName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with logo and profile
                HStack {
                    TennisBallLogo(size: 32)

                    Spacer()

                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search opponent name", text: $searchText)
                        .foregroundColor(.white)
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top, 16)

                // Match list
                List {
                    ForEach(filteredMatches) { match in
                        MatchRowView(match: match)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .onTapGesture {
                                selectedMatch = match
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if match.isCompleted {
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
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                Spacer()

                // Bottom tab bar
                BottomTabBar(
                    onPlusPressed: { showMatchSetup = true },
                    onStatsPressed: { showStats = true }
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

    var body: some View {
        VStack(spacing: 8) {
            // Player A row
            HStack {
                Text(match.playerAName)
                    .foregroundColor(.white)
                    .fontWeight(match.winner == .playerA ? .bold : .regular)
                Spacer()
                HStack(spacing: 12) {
                    ForEach(Array(match.sets.enumerated()), id: \.offset) { _, set in
                        Text("\(set.playerAGames)")
                            .foregroundColor(.white)
                            .frame(width: 20)
                    }
                }
            }

            // Player B row
            HStack {
                Text(match.playerBName)
                    .foregroundColor(.gray)
                    .fontWeight(match.winner == .playerB ? .bold : .regular)
                Spacer()
                HStack(spacing: 12) {
                    ForEach(Array(match.sets.enumerated()), id: \.offset) { _, set in
                        Text("\(set.playerBGames)")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct BottomTabBar: View {
    let onPlusPressed: () -> Void
    let onStatsPressed: () -> Void

    var body: some View {
        ZStack {
            // Plus button - centered
            Button(action: onPlusPressed) {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundColor(.black)
                    .frame(width: 50, height: 50)
                    .background(Color.white)
                    .clipShape(Circle())
            }

            // Stats button - right aligned
            HStack {
                Spacer()
                Button(action: onStatsPressed) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 16)
        .background(Color.black)
    }
}

#Preview {
    HomeView()
}
