//
//  PerformanceClientsGraphView.swift
//  Bordero
//
//  Created by Grande Variable on 15/05/2024.
//

import SwiftUI
import Charts
import CoreData

struct PerformanceClientsGraphView: View {
    private static let barWidth = 18.0

    @Environment(\.locale) private var locale

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Paiement.date_, ascending: true)
        ]
    )
    private var payments: FetchedResults<Paiement>

    var selectedPeriod: StatisticsPeriod = .week

    private var currencyCode: String {
        locale.currency?.identifier ?? "EUR"
    }

    var body: some View {
        let statistics = ClientRevenueStatistics(
            payments: Array(payments),
            period: selectedPeriod
        )

        GroupBox {
            if statistics.values.isEmpty {
                ContentUnavailableView(
                    "Aucun paiement",
                    systemImage: "chart.bar.xaxis",
                    description: Text("Les paiements de cette période apparaîtront ici.")
                )
                .frame(minHeight: 120)
            } else {
                Chart(statistics.values) { client in
                    BarMark(
                        x: .value("Client", client.clientName),
                        y: .value("Revenu", client.revenue),
                        width: .fixed(Self.barWidth)
                    )
                    .foregroundStyle(.tint)
                    .accessibilityLabel(client.clientName)
                    .accessibilityValue(
                        Text(
                            client.revenue,
                            format: .currency(code: currencyCode)
                        ))
                }
                .chartYScale(domain: statistics.revenueDomain)
                .dashboardChartAxes()
                .frame(minHeight: 220)
                .padding()
            }
        } label: {
            Text("Paiements par client")
        }
        .groupBoxStyle(PlainGroupBoxStyle())
    }
}

#Preview {
    PerformanceClientsGraphView(selectedPeriod: .month)
}
