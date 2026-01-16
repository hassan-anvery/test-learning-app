//
//  MatchSetupView.swift
//  TennisChartingApp
//

import SwiftUI

enum MatchSetupStep: Int, CaseIterable {
    case playerNames = 0
    case whoIsStarting = 1
    case whoIsServing = 2
    case matchFormat = 3
}

struct MatchSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: MatchSetupStep = .playerNames
    @State private var playerAName = ""
    @State private var playerBName = ""
    @State private var startingPlayer: PlayerSide?
    @State private var firstServer: PlayerSide?
    @State private var matchFormat: MatchFormat = .bestOf3
    @State private var navigateToMatch = false
    @State private var createdMatch: Match?

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Header with back button
                HStack {
                    Button {
                        if currentStep == .playerNames {
                            dismiss()
                        } else {
                            withAnimation {
                                goToPreviousStep()
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text("ur player")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .opacity(currentStep == .playerNames ? 1 : 0)
                }
                .padding(.horizontal)

                Spacer()

                // Content based on step
                VStack(spacing: 24) {
                    if currentStep.rawValue >= MatchSetupStep.playerNames.rawValue {
                        playerNamesSection
                    }

                    if currentStep.rawValue >= MatchSetupStep.whoIsStarting.rawValue {
                        whoIsStartingSection
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    if currentStep.rawValue >= MatchSetupStep.whoIsServing.rawValue {
                        whoIsServingSection
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    if currentStep.rawValue >= MatchSetupStep.matchFormat.rawValue {
                        matchFormatSection
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .fullScreenCover(item: $createdMatch) { match in
            MatchChartingView(match: match)
        }
    }

    private var playerNamesSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Player A name:")
                    .foregroundColor(.white)

                TextField("Your player", text: $playerAName)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Player B name:")
                    .foregroundColor(.white)

                TextField("Opponent", text: $playerBName)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }

            if currentStep == .playerNames {
                nextButton(enabled: !playerAName.isEmpty && !playerBName.isEmpty) {
                    withAnimation {
                        currentStep = .whoIsStarting
                    }
                }
            }
        }
    }

    private var whoIsStartingSection: some View {
        VStack(spacing: 16) {
            Text("Who's starting?")
                .foregroundColor(.white)
                .font(.headline)

            HStack(spacing: 24) {
                playerSelectionButton(
                    label: "A",
                    sublabel: playerAName,
                    isSelected: startingPlayer == .playerA
                ) {
                    startingPlayer = .playerA
                }

                playerSelectionButton(
                    label: "B",
                    sublabel: playerBName,
                    isSelected: startingPlayer == .playerB
                ) {
                    startingPlayer = .playerB
                }
            }

            if currentStep == .whoIsStarting {
                nextButton(enabled: startingPlayer != nil) {
                    withAnimation {
                        currentStep = .whoIsServing
                    }
                }
            }
        }
    }

    private var whoIsServingSection: some View {
        VStack(spacing: 16) {
            Text("Who's serving?")
                .foregroundColor(.white)
                .font(.headline)

            HStack(spacing: 24) {
                playerSelectionButton(
                    label: "A",
                    sublabel: playerAName,
                    isSelected: firstServer == .playerA
                ) {
                    firstServer = .playerA
                }

                playerSelectionButton(
                    label: "B",
                    sublabel: playerBName,
                    isSelected: firstServer == .playerB
                ) {
                    firstServer = .playerB
                }
            }

            if currentStep == .whoIsServing {
                nextButton(enabled: firstServer != nil) {
                    withAnimation {
                        currentStep = .matchFormat
                    }
                }
            }
        }
    }

    private var matchFormatSection: some View {
        VStack(spacing: 16) {
            Text("Match Format")
                .foregroundColor(.white)
                .font(.headline)

            HStack(spacing: 16) {
                ForEach(MatchFormat.allCases, id: \.self) { format in
                    Button {
                        matchFormat = format
                    } label: {
                        Text(format.displayName)
                            .font(.subheadline)
                            .foregroundColor(matchFormat == format ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(matchFormat == format ? Color.white : Color.white.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }

            Button {
                startMatch()
            } label: {
                Text("Start Match")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .padding(.top, 20)
        }
    }

    private func playerSelectionButton(
        label: String,
        sublabel: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(sublabel)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .black : .white)
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.white : Color.white.opacity(0.2))
            .clipShape(Circle())
        }
    }

    private func nextButton(enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("Next")
                .font(.headline)
                .foregroundColor(enabled ? .black : .gray)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(enabled ? Color.white : Color.white.opacity(0.3))
                .cornerRadius(8)
        }
        .disabled(!enabled)
    }

    private func goToPreviousStep() {
        switch currentStep {
        case .playerNames:
            break
        case .whoIsStarting:
            currentStep = .playerNames
        case .whoIsServing:
            currentStep = .whoIsStarting
        case .matchFormat:
            currentStep = .whoIsServing
        }
    }

    private func startMatch() {
        guard let startingPlayer = startingPlayer,
              let firstServer = firstServer else { return }

        let match = Match(
            playerAName: playerAName,
            playerBName: playerBName,
            matchFormat: matchFormat,
            startingPlayer: startingPlayer,
            firstServer: firstServer
        )

        MatchStore.shared.addMatch(match)
        createdMatch = match
    }
}

#Preview {
    MatchSetupView()
}
