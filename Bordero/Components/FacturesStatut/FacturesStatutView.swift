import SwiftUI
import CoreData

struct FacturesStatutView: View {
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Document.dateEmission_, ascending: true)
        ]
    )
    private var documents: FetchedResults<Document>

    var selectedPeriod: StatisticsPeriod = .week

    var body: some View {
        let statistics = FacturesChartStatistics(
            documents: Array(documents),
            period: selectedPeriod
        )

        GroupBox {
            if statistics.data.isEmpty {
                ContentUnavailableView(
                    "Aucune donnée",
                    systemImage: "chart.xyaxis.line",
                    description: Text("Les documents de cette période apparaîtront ici.")
                )
                .frame(minHeight: 120)
            } else {
                FacturesStatutChart(statistics: statistics)
            }
        } label: {
            header(for: statistics)
        }
        .groupBoxStyle(PlainGroupBoxStyle())
    }

    private func header(for statistics: FacturesChartStatistics) -> some View {
        let trend = RevenueTrend(
            currentRevenue: statistics.currentRevenue,
            previousRevenue: statistics.previousRevenue
        )

        return VStack(alignment: .leading) {
            Text("Chiffre d’affaires")

            Label {
                HStack(spacing: 3) {
                    if let revenueChange = statistics.revenueChange {
                        Text(
                            abs(revenueChange),
                            format: .percent.precision(.fractionLength(1))
                        )
                        .foregroundStyle(trend.color)
                    } else if statistics.currentRevenue > 0 {
                        Text("Nouveau chiffre d’affaires")
                            .foregroundStyle(trend.color)
                    } else {
                        Text("Aucun changement")
                    }

                    Text("vs")
                    Text(selectedPeriod.previousPeriodDescription)
                }
            } icon: {
                Image(systemName: trend.symbolName)
                    .foregroundStyle(trend.color)
                    .imageScale(.medium)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .labelIconToTitleSpacing(4)
        }
    }

    private enum RevenueTrend {
        case improving
        case declining
        case unchanged

        init(currentRevenue: Double, previousRevenue: Double) {
            if currentRevenue > previousRevenue {
                self = .improving
            } else if currentRevenue < previousRevenue {
                self = .declining
            } else {
                self = .unchanged
            }
        }

        var color: Color {
            switch self {
            case .improving: .green
            case .declining: .red
            case .unchanged: .secondary
            }
        }

        var symbolName: String {
            switch self {
            case .improving: "arrow.up.right"
            case .declining: "arrow.down.forward"
            case .unchanged: "equal"
            }
        }
    }
}

#if DEBUG
#Preview("Statistiques fictives") {
    List {
        FacturesStatutView(selectedPeriod: .month)
    }
    .environment(\.managedObjectContext, PreviewDataController.invoices.context)
    .padding()
}

#Preview("Sans données") {
    FacturesStatutView(selectedPeriod: .month)
        .environment(\.managedObjectContext, PreviewDataController.empty.context)
        .frame(height: 360)
        .padding()
}
#endif
