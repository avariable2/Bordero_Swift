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
    
    var body: some View {
        NavigationLink {
            PraticienDataView()
        } label: {
            TitleWithIconColorComponentView(titre : "Voir les statistiques") {
                Image(systemName: "chart.dots.scatter")
                    .foregroundStyle(.green, .gray)
            }
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    var backgroundColor : Color {
        if colorScheme == .dark {
            Color(UIColor.systemGray6)
        } else {
            .white
        }
    }
}

#Preview {
    StatistiquePaticientView()
}
