//
//  MatchSetupView.swift
//  TennisChartingApp
//

import SwiftUI

enum FocusedField {
    case playerA
    case playerB
}

struct MatchSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: FocusedField?
    @State private var playerAName = ""
    @State private var playerBName = ""
    @State private var firstServer: PlayerSide?
    @State private var matchFormat: MatchFormat = .bestOf3
    @State private var noAd: Bool = false
    @State private var sessionType: SessionType = .practice
    @State private var selectedSurface: SurfaceType? = nil
    @State private var navigateToMatch = false
    @State private var createdMatch: Match?

    private var canStartMatch: Bool {
        !playerAName.isEmpty && !playerBName.isEmpty && firstServer != nil
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Heading
                        headingSection

                        // Quick presets
                        presetSection

                        // Player name cards
                        playerNameCards

                        // Serving first
                        servingFirstSection

                        // Match format
                        matchFormatSection

                        // Surface type
                        surfaceTypeSection

                        // Session type
                        sessionTypeSection
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }

                // Bottom CTA
                startMatchButton
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
            }
        }
        .fullScreenCover(item: $createdMatch) { match in
            MatchChartingView(match: match)
        }
        .onChange(of: createdMatch?.id) { oldValue, newValue in
            // When MatchChartingView dismisses (createdMatch becomes nil)
            if oldValue != nil && newValue == nil {
                // Check if the match was completed - if so, dismiss back to Home
                if let matchId = oldValue,
                   let storedMatch = MatchStore.shared.getMatch(by: matchId),
                   storedMatch.isCompleted {
                    dismiss()
                }
            }
        }
    }

    private var headerView: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
            }

            Spacer()

            Text("New Match")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)

            Spacer()

            Button { dismiss() } label: {
                Text("Cancel")
                    .font(.system(size: 17))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var headingSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Enter player names")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            Text("Assign the sides for today's match")
                .font(.system(size: 15))
                .foregroundColor(.gray)
        }
    }

    private var playerNameCards: some View {
        VStack(spacing: 16) {
            // Player 1 card
            VStack(alignment: .leading, spacing: 8) {
                Text("PLAYER 1 NAME")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                TextField("e.g. Roger Federer", text: $playerAName)
                    .focused($focusedField, equals: .playerA)
                    .font(.system(size: 17))
                    .foregroundColor(.black)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)

            // Player 2 card
            VStack(alignment: .leading, spacing: 8) {
                Text("PLAYER 2 NAME")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                TextField("e.g. Rafael Nadal", text: $playerBName)
                    .focused($focusedField, equals: .playerB)
                    .font(.system(size: 17))
                    .foregroundColor(.black)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
    }

    private var servingFirstSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Who's serving first?")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)

            HStack(spacing: 16) {
                serverButton(side: .playerA, label: "A", name: playerAName)
                serverButton(side: .playerB, label: "B", name: playerBName)
            }
        }
    }

    private func serverButton(side: PlayerSide, label: String, name: String) -> some View {
        Button {
            firstServer = side
        } label: {
            HStack(spacing: 8) {
                Text(label)
                    .font(.system(size: 17, weight: .bold))
                if !name.isEmpty {
                    Text(name)
                        .font(.system(size: 15))
                        .lineLimit(1)
                }
            }
            .foregroundColor(firstServer == side ? .white : .black)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(firstServer == side ? Color(red: 0.18, green: 0.55, blue: 0.45) : Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
    }

    private var presetSection: some View {
        let presets: [(label: String, format: MatchFormat, noAd: Bool)] = [
            ("Best of 3 · Standard", .bestOf3, false),
            ("Best of 3 · No-Ad",    .bestOf3, true),
            ("Best of 1 · Standard", .bestOf1, false),
            ("Best of 1 · No-Ad",    .bestOf1, true)
        ]
        return VStack(alignment: .leading, spacing: 12) {
            Text("Quick Presets")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)

            VStack(spacing: 10) {
                ForEach(0..<2) { row in
                    HStack(spacing: 10) {
                        ForEach(0..<2) { col in
                            let preset = presets[row * 2 + col]
                            let isActive = matchFormat == preset.format && noAd == preset.noAd
                            Button {
                                matchFormat = preset.format
                                noAd = preset.noAd
                            } label: {
                                Text(preset.label)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(isActive ? .white : .black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isActive ? Color(red: 0.18, green: 0.55, blue: 0.45) : Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                }
            }
        }
    }

    private var matchFormatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Match Format")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)

            HStack(spacing: 12) {
                ForEach(MatchFormat.allCases, id: \.self) { format in
                    Button {
                        matchFormat = format
                    } label: {
                        Text(format.displayName)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(matchFormat == format ? .white : .black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(matchFormat == format ? Color(red: 0.18, green: 0.55, blue: 0.45) : Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    }
                }
            }

            HStack {
                Text("No-Ad Scoring")
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                Spacer()
                Toggle("", isOn: $noAd)
                    .labelsHidden()
                    .tint(Color(red: 0.18, green: 0.55, blue: 0.45))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
    }

    private var surfaceTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Surface")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)

            HStack(spacing: 8) {
                ForEach(SurfaceType.allCases, id: \.self) { surface in
                    Button {
                        selectedSurface = selectedSurface == surface ? nil : surface
                    } label: {
                        Text(surface.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedSurface == surface ? .white : .black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(selectedSurface == surface ? Color(red: 0.18, green: 0.55, blue: 0.45) : Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    }
                }
            }
        }
    }

    private var sessionTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Type")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    ForEach([SessionType.practice, .matchPlay, .tournament], id: \.self) { type in
                        chipButton(type)
                    }
                }
                HStack(spacing: 8) {
                    ForEach([SessionType.lesson, .friendly], id: \.self) { type in
                        chipButton(type)
                    }
                }
            }
        }
    }

    private func chipButton(_ type: SessionType) -> some View {
        Button {
            sessionType = type
        } label: {
            Text(type.rawValue)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(sessionType == type ? .white : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(sessionType == type ? Color(red: 0.18, green: 0.55, blue: 0.45) : Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
    }

    private var startMatchButton: some View {
        Button {
            startMatch()
        } label: {
            Text("Start Match")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(canStartMatch ? Color(red: 0.18, green: 0.55, blue: 0.45) : Color.gray)
                .cornerRadius(28)
        }
        .disabled(!canStartMatch)
    }

    private func startMatch() {
        guard let firstServer = firstServer else { return }

        let match = Match(
            playerAName: playerAName,
            playerBName: playerBName,
            matchFormat: matchFormat,
            startingPlayer: firstServer,
            firstServer: firstServer,
            noAd: noAd,
            sessionType: sessionType,
            surface: selectedSurface
        )

        MatchStore.shared.addMatch(match)
        createdMatch = match
    }
}

#Preview {
    MatchSetupView()
}
