//
//  NoteEntryView.swift
//  TennisChartingApp
//

import SwiftUI

struct NoteEntryView: View {
    let playerName: String
    let onSave: (PointNote) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedHowWon: HowPointWon?
    @State private var selectedAttitude: Attitude?
    @State private var additionalNotes: String = ""

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        Text("\(playerName) Notes")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.top)

                    // How was the point won?
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How was the point won?")
                            .foregroundColor(.white)
                            .font(.headline)

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

                    // Attitude
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Attitude")
                            .foregroundColor(.white)
                            .font(.headline)

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

                    // Notes text box
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes:")
                            .foregroundColor(.white)
                            .font(.headline)

                        TextEditor(text: $additionalNotes)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                    }

                    // Save button
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
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal)
            }
        }
    }
}

struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.white : Color.white.opacity(0.2))
                .cornerRadius(20)
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
