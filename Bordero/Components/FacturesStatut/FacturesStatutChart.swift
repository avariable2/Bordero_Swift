import SwiftUI
import Charts

struct FacturesStatutChart: View {
    private static let barWidth = 16.0

    @State private var selectedPeriod: String?

    var statistics: FacturesChartStatistics

    var body: some View {
        Chart {
            ForEach(statistics.data) { element in
                BarMark(
                    x: .value("Période", element.period),
                    y: .value("Nombre de factures", Double(element.count)),
                    width: .fixed(Self.barWidth)
                )
                .foregroundStyle(by: .value("Statut", element.status.rawValue))
                .opacity(statistics.opacity(for: element))
                .accessibilityLabel("\(element.period), \(element.status.rawValue)")
                .accessibilityValue("\(element.count) factures")
            }
            if let selectedPeriod,
                statistics.periods.contains(selectedPeriod)
            {
                RuleMark(x: .value("Période", selectedPeriod))
                    .foregroundStyle(.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    .annotation(
                        position: .top,
                        overflowResolution: .init(
                            x: .fit(to: .chart),
                            y: .fit(to: .chart)
                        )
                    ) {
                        FacturesStatutSelection(
                            period: selectedPeriod,
                            data: statistics.data.filter { $0.period == selectedPeriod }
                        )
                    }
            }
        }
        .chartXSelection(value: $selectedPeriod)
        .onChange(of: statistics.periods) {
            selectedPeriod = nil
        }
        .chartXScale(domain: statistics.periods)
        .chartYScale(domain: statistics.countDomain)
        .dashboardChartAxes()
        .chartForegroundStyleScale([
            DocumentStatus.paye.rawValue: Color.green,
            DocumentStatus.envoyer.rawValue: Color.orange,
            DocumentStatus.enRetard.rawValue: Color.red,
        ])
        .frame(minHeight: 220)
        .padding()
    }
}
