//
//  GridTotalStatsView.swift
//  Bordero
//
//  Created by Grande Variable on 18/09/2026.
//

import SwiftUI
import CoreData

struct GridTotalStatsView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Document.dateEmission_, ascending: true)]
    ) private var documents: FetchedResults<Document>

    let selectedPeriod: PeriodStats
    
    private var statistics : GridTotalStatistics {
        GridTotalStatistics(
            documents: Array(documents),
            period: selectedPeriod
        )
    }

    var body: some View {
        Grid(horizontalSpacing: 10, verticalSpacing: 10) {
            GridRow {
                TotalStatsView(
                    title: "Total en attente",
                    totalNumber: statistics.totalPending.count,
                    amount: statistics.totalPending.amount,
                    progress: statistics.totalPending.progress
                )

                TotalStatsView(
                    title: "Encaissé",
                    totalNumber: statistics.collected.count,
                    amount: statistics.collected.amount,
                    progress: statistics.collected.progress,
                    color: .green
                )
            }

            GridRow {
                TotalStatsView(
                    title: "En attente",
                    totalNumber: statistics.pending.count,
                    amount: statistics.pending.amount,
                    progress: statistics.pending.progress,
                    color: .orange
                )

                TotalStatsView(
                    title: "Impayé",
                    totalNumber: statistics.overdue.count,
                    amount: statistics.overdue.amount,
                    progress: statistics.overdue.progress,
                    color: .red
                )
            }
        }
        .groupBoxStyle(PlainGroupBoxStyle())
        
    }
}

#if DEBUG
#Preview("Statistiques fictives") {
    List {
        GridTotalStatsView(selectedPeriod: .month)
    }
        .environment(\.managedObjectContext, PreviewDataController.invoices.context)
}

#Preview("Sans données") {
    List {
        GridTotalStatsView(selectedPeriod: .month)
    }
        .environment(\.managedObjectContext, PreviewDataController.empty.context)
}
#endif
