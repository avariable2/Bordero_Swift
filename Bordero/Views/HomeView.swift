//
//  HomeView.swift
//  Bordero
//
//  Created by Grande Variable on 17/09/2026.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var columns: [GridItem] {
        let count = horizontalSizeClass == .compact ? 1 : 2

        return Array(
            repeating: GridItem(
                .flexible(),
                spacing: 20,
                alignment: .center
            ),
            count: count
        )
    }

    @AppStorage("home.selectedStatisticsPeriod")
    private var selectedStatisticsPeriod = StatisticsPeriod.week

    private var selectedPeriodTitle: String {
        let now = Date.now
        let calendar = Calendar.current
        let interval = selectedStatisticsPeriod.interval(
            containing: now,
            calendar: calendar
        )

        let endDate = interval.end.addingTimeInterval(-1)
        return (interval.start..<endDate).formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        List {
            Section(selectedPeriodTitle) {
                VStack(spacing: 20) {
                    FacturesStatutView(
                        selectedPeriod: selectedStatisticsPeriod
                    )

                    GridTotalStatsView(
                        selectedPeriod: selectedStatisticsPeriod
                    )

                    LazyVGrid(columns: columns, spacing: 20) {
                        PerformanceClientsGraphView(
                            selectedPeriod: selectedStatisticsPeriod
                        )

                        ClientPaymentEstimateGraphView(
                            selectedPeriod: selectedStatisticsPeriod
                        )
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section("Paiements récents") {
                ListHistoriquesPaiements()
            }
        }
        .headerProminence(.increased)
        .navigationTitle("Accueil")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Picker("Période", selection: $selectedStatisticsPeriod) {
                    ForEach(StatisticsPeriod.allCases) { period in
                        Text(period.displayName)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Période des statistiques")
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(\.managedObjectContext, PreviewDataController.invoices.context)
}
#endif
