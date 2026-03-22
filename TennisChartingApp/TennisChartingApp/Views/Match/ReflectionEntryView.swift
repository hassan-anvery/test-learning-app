//
//  ReflectionEntryView.swift
//  TennisChartingApp
//

import SwiftUI

struct ReflectionEntryView: View {
    @Binding var match: Match
    let onDismiss: () -> Void

    @State private var wentWell: String
    @State private var needsWork: String
    @State private var nextFocus: String

    init(match: Binding<Match>, onDismiss: @escaping () -> Void) {
        self._match = match
        self.onDismiss = onDismiss
        let existing = match.wrappedValue.reflection
        self._wentWell  = State(initialValue: existing?.wentWell  ?? "")
        self._needsWork = State(initialValue: existing?.needsWork ?? "")
        self._nextFocus = State(initialValue: existing?.nextFocus ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGray6)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("How did it go?")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)

                        promptCard(label: "WHAT WENT WELL?", text: $wentWell)
                        promptCard(label: "WHAT NEEDS WORK?", text: $needsWork)
                        promptCard(label: "ONE FOCUS FOR NEXT TIME", text: $nextFocus)

                        Button {
                            match.reflection = MatchReflection(
                                wentWell: wentWell,
                                needsWork: needsWork,
                                nextFocus: nextFocus
                            )
                            MatchStore.shared.updateMatch(match)
                            onDismiss()
                        } label: {
                            Text("Save")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(red: 0.18, green: 0.55, blue: 0.45))
                                .cornerRadius(28)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        onDismiss()
                    }
                    .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                }
            }
        }
    }

    private func promptCard(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
            TextEditor(text: text)
                .font(.system(size: 15))
                .foregroundColor(.black)
                .frame(minHeight: 80)
                .scrollContentBackground(.hidden)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}
