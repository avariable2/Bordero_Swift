//
//  GridTotalStatsView.swift
//  Bordero
//
//  Created by Grande Variable on 18/09/2026.
//

import SwiftUI
import CoreData

struct GridTotalStatsView: View {
    @Environment(\.tendancesVisualTheme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Document.dateEmission_, ascending: true)]
    ) private var documents: FetchedResults<Document>

    var selectedPeriod: StatisticsPeriod

    private var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 10), count: count)
    }

    var body: some View {
        let palette = theme?.palette
        let statistics = GridTotalStatistics(
            documents: Array(documents),
            period: selectedPeriod
        )

        LazyVGrid(columns: columns, spacing: 10) {
            TotalStatsView(
                title: "Reste à encaisser",
                totalNumber: statistics.totalPending.count,
                amount: statistics.totalPending.amount,
                progress: statistics.totalPending.progress,
                color: palette?.primaryMetric ?? .purple
            )

            TotalStatsView(
                title: "Encaissé",
                totalNumber: statistics.collected.count,
                amount: statistics.collected.amount,
                progress: statistics.collected.progress,
                color: palette?.collected ?? .green
            )

            TotalStatsView(
                title: "À échéance",
                totalNumber: statistics.pending.count,
                amount: statistics.pending.amount,
                progress: statistics.pending.progress,
                color: palette?.due ?? .orange
            )

            TotalStatsView(
                title: "En retard",
                totalNumber: statistics.overdue.count,
                amount: statistics.overdue.amount,
                progress: statistics.overdue.progress,
                color: palette?.overdue ?? .red
            )
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
