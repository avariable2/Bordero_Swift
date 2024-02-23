//
//  StatistiquePaticientView.swift
//  Bordero
//
//  Created by Grande Variable on 23/02/2024.
//

import SwiftUI
import Charts

struct BarData: Identifiable {
    let payer: Bool
    let facture: Bool
    var id = UUID()
}

struct StatistiquePaticientView: View {
    private var data: [BarData] = [
        BarData(payer: true, facture: true),
        BarData(payer: false, facture: true),
        BarData(payer: false, facture: true),
    ]
    var body: some View {
        GroupBox(
            label: Label("Factures impayées", systemImage: "bag.badge.minus")
                .foregroundColor(.red)
        ) {
            HStack(alignment: .bottom) {
                Text("Montant perdu : ") + Text("0,00 $")
            }
            .frame(alignment: .leading)
        }
    }
}

#Preview {
    StatistiquePaticientView()
}
