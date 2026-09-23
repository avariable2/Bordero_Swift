//
//  HomeView.swift
//  Bordero
//
//  Created by Grande Variable on 17/09/2026.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("home.selectedStatisticsPeriod")
    private var selectedStatisticsPeriod = StatisticsPeriod.week

    @State private var isPresentingInvoiceForm = false

    private var theme: HomeVisualTheme { .facturierOriginal }

    var body: some View {
        HomeClarteView(
            selectedPeriod: $selectedStatisticsPeriod
        )
        .environment(\.homeVisualTheme, theme)
        .tint(theme.palette.accent)
        .navigationTitle("Accueil")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    "Créer une facture",
                    systemImage: "doc.badge.plus",
                    action: createInvoice
                )
                .labelStyle(.iconOnly)
                .accessibilityHint("Ouvre le formulaire d’une nouvelle facture")
            }
        }
        .sheet(isPresented: $isPresentingInvoiceForm) {
            DocumentFormView()
        }
    }

    private func createInvoice() {
        isPresentingInvoiceForm = true
    }
}
