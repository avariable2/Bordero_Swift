//
//  ClientPaymentEstimateGraphView.swift
//  Bordero
//
//  Created by Grande Variable on 17/05/2024.
//

import SwiftUI
import Charts
import CoreData

struct ClientPaymentEstimateGraphView: View {
    private static let barWidth = 18.0

    @Environment(\.homeVisualTheme) private var theme

    @FetchRequest(sortDescriptors: [])
    private var clients: FetchedResults<Client>

    var selectedPeriod: StatisticsPeriod = .week

    var body: some View {
        let statistics = ClientPaymentDelayStatistics(
            clients: Array(clients),
            period: selectedPeriod
        )

        GroupBox {
            if statistics.values.isEmpty {
                ContentUnavailableView(
                    "Aucun délai calculé",
                    systemImage: "clock.badge.questionmark",
                    description: Text("Les délais apparaîtront après les premiers paiements.")
                )
                .frame(minHeight: 120)
            } else {
                chart(for: statistics)
            }
        } label: {
            Text("Délai moyen de paiement")
        }
        .groupBoxStyle(PlainGroupBoxStyle())
    }

    private func chart(
        for statistics: ClientPaymentDelayStatistics
    ) -> some View {
        let palette = theme?.palette

        return Chart {
            ForEach(statistics.values) { client in
                BarMark(
                    x: .value("Client", client.clientName),
                    y: .value("Délai moyen en jours", client.averageDelayInDays),
                    width: .fixed(Self.barWidth)
                )
                .foregroundStyle(palette?.accent ?? .blue)
                .accessibilityLabel(client.clientName)
                .accessibilityValue(
                    "\(client.averageDelayInDays.formatted(.number.precision(.fractionLength(1)))) jours"
                )
            }

            if let average = statistics.averageDelayInDays {
                RuleMark(y: .value("Moyenne", average))
                    .foregroundStyle(palette?.collected ?? .green)
                    .annotation(position: .top, alignment: .leading) {
                        Text(
                            "Moyenne: \(average.formatted(.number.precision(.fractionLength(1)))) jours"
                        )
                        .font(.caption)
                        .foregroundStyle(palette?.collected ?? .green)
                    }
            }
        }
        .chartYScale(domain: statistics.delayDomain)
        .dashboardChartAxes()
        .frame(minHeight: 220)
        .padding()
    }
}

#Preview {
    ClientPaymentEstimateGraphView(selectedPeriod: .month)
}
