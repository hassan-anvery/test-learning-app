//
//  FilterSheetView.swift
//  TennisChartingApp
//

import SwiftUI

enum ResultFilter: String, CaseIterable {
    case win        = "Win"
    case loss       = "Loss"
    case inProgress = "In Progress"
}

struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var sessionType: SessionType?
    @Binding var result: ResultFilter?
    @Binding var reflection: Bool?

    private var hasActiveFilters: Bool {
        sessionType != nil || result != nil || reflection != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    filterSection(title: "Session Type") {
                        chipScrollRow(allSelected: sessionType == nil, onAll: { sessionType = nil }) {
                            ForEach(SessionType.allCases, id: \.self) { type in
                                FilterChip(type.rawValue, isSelected: sessionType == type) {
                                    sessionType = sessionType == type ? nil : type
                                }
                            }
                        }
                    }

                    filterSection(title: "Result") {
                        chipScrollRow(allSelected: result == nil, onAll: { result = nil }) {
                            ForEach(ResultFilter.allCases, id: \.self) { r in
                                FilterChip(r.rawValue, isSelected: result == r) {
                                    result = result == r ? nil : r
                                }
                            }
                        }
                    }

                    filterSection(title: "Reflection") {
                        chipScrollRow(allSelected: reflection == nil, onAll: { reflection = nil }) {
                            FilterChip("Has Reflection", isSelected: reflection == true) {
                                reflection = reflection == true ? nil : true
                            }
                            FilterChip("No Reflection", isSelected: reflection == false) {
                                reflection = reflection == false ? nil : false
                            }
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(UIColor.systemGray6).ignoresSafeArea())
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if hasActiveFilters {
                        Button("Clear All") {
                            sessionType = nil
                            result = nil
                            reflection = nil
                        }
                        .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.45))
                }
            }
        }
    }

    @ViewBuilder
    private func filterSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal, 20)
            content()
        }
    }

    @ViewBuilder
    private func chipScrollRow(
        allSelected: Bool,
        onAll: @escaping () -> Void,
        @ViewBuilder chips: () -> some View
    ) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip("All", isSelected: allSelected, action: onAll)
                chips()
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    init(_ label: String, isSelected: Bool, action: @escaping () -> Void) {
        self.label = label
        self.isSelected = isSelected
        self.action = action
    }

    private let green = Color(red: 0.18, green: 0.55, blue: 0.45)

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? green : Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color(UIColor.systemGray4), lineWidth: 1)
                )
        }
    }
}
