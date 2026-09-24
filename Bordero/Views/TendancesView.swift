//
//  HomeView.swift
//  Bordero
//
//  Created by Grande Variable on 17/09/2026.
//

import SwiftUI

struct TendancesView: View {
    @AppStorage("home.selectedStatisticsPeriod")
    private var selectedStatisticsPeriod = StatisticsPeriod.week
    @State private var editMode: EditMode = .inactive

    private var theme: TendancesVisualTheme { .facturierOriginal }

    var body: some View {
        TendancesClarteView(
            selectedPeriod: $selectedStatisticsPeriod
        )
        .environment(\.tendancesVisualTheme, theme)
        .environment(\.editMode, $editMode)
        .tint(theme.palette.accent)
        .navigationTitle("Tendances")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    editMode.isEditing ? "Terminer" : "Réorganiser",
                    systemImage: editMode.isEditing ? "checkmark" : "arrow.up.arrow.down"
                ) {
                    withAnimation(.snappy) {
                        editMode = editMode.isEditing ? .inactive : .active
                    }
                }
            }
        }
    }
}
