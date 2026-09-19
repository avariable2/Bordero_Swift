//
//  GridTotalStatsView.swift
//  Bordero
//
//  Created by Grande Variable on 18/09/2026.
//

import SwiftUI

struct GridTotalStatsView: View {
    var body: some View {
        Grid {
            GridRow {
                TotalStatsView(
                    title: "Total en attentes",
                    totalNumber: 0,
                    amount: 1000000000,
                    progress: 0.5
                )
                
                TotalStatsView(
                    title: "Payer ce mois",
                    totalNumber: 0,
                    amount: 0,
                    progress: 0.5,
                    color: .green
                )
            }
            
            GridRow {
                TotalStatsView(
                    title: "En attente",
                    totalNumber: 0,
                    amount: 0,
                    progress: 0.5,
                    color: .orange
                )
                
                TotalStatsView(
                    title: "Impayé",
                    totalNumber: 0,
                    amount: 0,
                    progress: 0.5,
                    color: .red
                )
            }
        }
    }
}

#Preview {
    GridTotalStatsView()
}
