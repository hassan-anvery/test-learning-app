//
//  NoteEntryView.swift
//  TennisChartingApp
//

import SwiftUI

struct NoteEntryView: View {
    let playerName: String
    let existingNote: PointNote?
    let onSave: (PointNote) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedHowWon: HowPointWon?
    @State private var selectedAttitude: Attitude?
    @State private var additionalNotes: String = ""

    init(playerName: String, existingNote: PointNote? = nil, onSave: @escaping (PointNote) -> Void) {
        self.playerName = playerName
        self.existingNote = existingNote
        self.onSave = onSave
        // Prefill from existing note
        _selectedHowWon = State(initialValue: existingNote?.howWon)
        _selectedAttitude = State(initialValue: existingNote?.attitude)
        _additionalNotes = State(initialValue: existingNote?.additionalNotes ?? "")
    }

    private let accentGreen = Color(red: 0.18, green: 0.55, blue: 0.45)

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with Done button
                HStack {
                    Text("\(playerName) Notes")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()

                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(accentGreen)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 16) {
                        // How was the point won? card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How was the point won?")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)

                            FlowLayout(spacing: 8) {
                                ForEach(HowPointWon.allCases, id: \.self) { option in
                                    SelectableChip(
                                        title: option.rawValue,
                                        isSelected: selectedHowWon == option
                                    ) {
                                        selectedHowWon = option
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)

                        // Attitude card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Attitude")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)

                            FlowLayout(spacing: 8) {
                                ForEach(Attitude.allCases, id: \.self) { option in
                                    SelectableChip(
                                        title: option.rawValue,
                                        isSelected: selectedAttitude == option
                                    ) {
                                        selectedAttitude = option
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)

                        // Notes card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)

                            ZStack(alignment: .topLeading) {
                                if additionalNotes.isEmpty {
                                    Text("Type note...")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                }
                                TextEditor(text: $additionalNotes)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                    .frame(minHeight: 100)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                            }
                            .padding(12)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }

                // Save button (outside ScrollView, fixed at bottom)
                Button {
                    let note = PointNote(
                        howWon: selectedHowWon,
                        attitude: selectedAttitude,
                        additionalNotes: additionalNotes.isEmpty ? nil : additionalNotes
                    )
                    onSave(note)
                    dismiss()
                } label: {
                    Text("Save Note")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(accentGreen)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }
}

struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    private let accentGreen = Color(red: 0.18, green: 0.55, blue: 0.45)

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? accentGreen : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? accentGreen.opacity(0.15) : Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? accentGreen : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// Simple flow layout for chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)

        for (index, subview) in subviews.enumerated() {
            let point = result.positions[index]
            subview.place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var positions: [CGPoint] = []
        var height: CGFloat = 0

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            height = y + rowHeight
        }
    }
}

#Preview {
    NoteEntryView(playerName: "Hassan") { note in
        print(note)
    }
}
