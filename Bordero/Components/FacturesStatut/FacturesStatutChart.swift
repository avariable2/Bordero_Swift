import SwiftUI
import Charts

struct FacturesStatutChart: View {
    let statistics: FacturesChartStatistics
    @State private var selectedPeriod: String?

    var body: some View {
        Chart {
            ForEach(statistics.data) { element in
                BarMark(
                    x: .value("Période", element.period),
                    y: .value("Nombre de factures", element.count)
                )
                .foregroundStyle(by: .value("Statut", element.status.rawValue))
                .opacity(statistics.opacity(for: element))
                .accessibilityLabel("\(element.period), \(element.status.rawValue)")
                .accessibilityValue("\(element.count) factures")
            }
            if let selectedPeriod {
                RuleMark(x: .value("Période", selectedPeriod))
                    .foregroundStyle(.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .fit(to: .chart))) {
                        FacturesStatutSelection(
                            period: selectedPeriod,
                            data: statistics.data.filter { $0.period == selectedPeriod }
                        )
                    }
            }
        }
        .chartXSelection(value: $selectedPeriod)
        .chartGesture { proxy in
            SpatialTapGesture().onEnded { value in
                proxy.selectXValue(at: value.location.x)
            }
        }
        .onChange(of: statistics.periods) { selectedPeriod = nil }
        .chartXScale(domain: statistics.periods)
        .chartYScale(domain: 0...statistics.maximumCount)
        .chartXAxis {
            AxisMarks {
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks {
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartForegroundStyleScale([
            DocumentStatus.paye.rawValue: Color.green,
            DocumentStatus.envoyer.rawValue: Color.orange,
            DocumentStatus.enRetard.rawValue: Color.red
        ])
        .frame(minHeight: 220)
        .padding()
    }
}
