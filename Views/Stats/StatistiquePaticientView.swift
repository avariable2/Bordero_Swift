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
    @Environment(\.colorScheme) var colorScheme
    
    private var data: [BarData] = [
        BarData(payer: true, facture: true),
        BarData(payer: false, facture: true),
        BarData(payer: false, facture: true),
    ]
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text("Montant perdu : ") + Text("0,00 $")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var backgroundColor : Color {
        colorScheme == .dark ? .black : .white
    }
}

#Preview {
    StatistiquePaticientView()
}
