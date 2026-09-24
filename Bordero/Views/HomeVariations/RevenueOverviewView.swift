import CoreData
import SwiftUI

struct RevenueOverviewView: View {
    @Environment(\.tendancesVisualTheme) private var theme
    @Environment(\.locale) private var locale

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Document.dateEmission_, ascending: true)
        ]
    )
    private var documents: FetchedResults<Document>

    var selectedPeriod: StatisticsPeriod

    var body: some View {
        let statistics = RevenueTimelineStatistics(
            documents: Array(documents),
            period: selectedPeriod
        )

        GroupBox {
            if statistics.hasDocuments {
                RevenueOverviewChart(
                    statistics: statistics,
                    selectedPeriod: selectedPeriod
                )
            } else {
                ContentUnavailableView(
                    "Aucun chiffre d’affaires",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("Les factures de cette période apparaîtront ici.")
                )
                .frame(minHeight: 180)
            }
        } label: {
            header(for: statistics)
        }
        .groupBoxStyle(PlainGroupBoxStyle())
    }

    private var currencyCode: String {
        locale.currency?.identifier ?? "EUR"
    }

    private func header(for statistics: RevenueTimelineStatistics) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline) {
                Text("Chiffre d’affaires")
                Spacer(minLength: 8)
                Text(selectedPeriod.displayName)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Text(statistics.total, format: .currency(code: currencyCode))
                .font(.title2)
                .bold()
                .contentTransition(.numericText(value: statistics.total))

            comparison(for: statistics)
        }
    }

    @ViewBuilder
    private func comparison(for statistics: RevenueTimelineStatistics) -> some View {
        if let change = statistics.change {
            Label {
                HStack(spacing: 3) {
                    Text(abs(change), format: .percent.precision(.fractionLength(1)))
                        .foregroundStyle(trendColor(for: change))
                    Text("vs")
                    Text(selectedPeriod.previousPeriodDescription)
                }
            } icon: {
                Image(systemName: trendSymbol(for: change))
                    .foregroundStyle(trendColor(for: change))
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        } else if statistics.total > 0 {
            Label("Nouvelle activité sur la période", systemImage: "sparkles")
                .font(.footnote)
                .foregroundStyle(theme?.palette.collected ?? .green)
        } else {
            Label("Aucun changement", systemImage: "equal")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func trendColor(for change: Double) -> Color {
        if change > 0 {
            return theme?.palette.collected ?? .green
        }
        if change < 0 {
            return theme?.palette.overdue ?? .red
        }
        return .secondary
    }

    private func trendSymbol(for change: Double) -> String {
        if change > 0 { return "arrow.up.right" }
        if change < 0 { return "arrow.down.forward" }
        return "equal"
    }
}
