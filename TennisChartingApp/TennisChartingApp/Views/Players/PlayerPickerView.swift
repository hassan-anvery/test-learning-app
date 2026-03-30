//
//  PlayerPickerView.swift
//  TennisChartingApp
//

import SwiftUI

struct PlayerPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    let onSelect: (PlayerProfile) -> Void

    private var filtered: [PlayerProfile] {
        guard !searchText.isEmpty else { return PlayerProfileStore.shared.profiles }
        return PlayerProfileStore.shared.profiles.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGray6).ignoresSafeArea()

                if PlayerProfileStore.shared.profiles.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.2")
                            .font(.system(size: 40))
                            .foregroundColor(Color(UIColor.systemGray3))
                        Text("No saved players")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text("Create player profiles in your Profile area\nto reuse them during match setup.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    VStack(spacing: 0) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search players", text: $searchText)
                                .foregroundColor(.black)
                            if !searchText.isEmpty {
                                Button { searchText = "" } label: {
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
                        .padding(.vertical, 12)

                        List {
                            ForEach(filtered) { profile in
                                Button {
                                    onSelect(profile)
                                    dismiss()
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(profile.name)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.black)
                                            if let lastPlayed = profile.lastPlayedAt {
                                                Text("Last played \(lastPlayed.formatted(date: .abbreviated, time: .omitted))")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color(UIColor.systemGray3))
                                    }
                                }
                                .listRowBackground(Color.white)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Choose Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.black)
                }
            }
            .toolbarBackground(Color(UIColor.systemGray6), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
