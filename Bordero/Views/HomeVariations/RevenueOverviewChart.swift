import Charts
import SwiftUI

struct RevenueOverviewChart: View {
    @Environment(\.tendancesVisualTheme) private var theme

    var statistics: RevenueTimelineStatistics
    var selectedPeriod: StatisticsPeriod

    var body: some View {
        let accent = theme?.palette.primaryMetric ?? Color.green

        Chart(statistics.points) { point in
            AreaMark(
                x: .value("Date", point.date),
                y: .value("Chiffre d’affaires", point.amount)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(accent.opacity(0.12))

            LineMark(
                x: .value("Date", point.date),
                y: .value("Chiffre d’affaires", point.amount)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(accent)
            .lineStyle(StrokeStyle(lineWidth: 2))

            PointMark(
                x: .value("Date", point.date),
                y: .value("Chiffre d’affaires", point.amount)
            )
            .foregroundStyle(accent)
            .symbolSize(28)
        }
        .chartYScale(domain: statistics.amountDomain)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: desiredAxisCount)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        axisLabel(for: date)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks {
                AxisGridLine()
                AxisTick()
                AxisValueLabel(anchor: .trailing)
            }
        }
        .frame(minHeight: 220)
        .padding(.top, 8)
        .accessibilityLabel("Évolution du chiffre d’affaires")
        .accessibilityValue(
            Text(statistics.total, format: .currency(code: currencyCode))
        )
    }

    @Environment(\.locale) private var locale

    private var currencyCode: String {
        locale.currency?.identifier ?? "EUR"
    }

    private var desiredAxisCount: Int {
        switch selectedPeriod {
        case .week: 7
        case .month: 5
        case .year: 12
        }
    }

    @ViewBuilder
    private func axisLabel(for date: Date) -> some View {
        switch selectedPeriod {
        case .week:
            Text(date, format: .dateTime.weekday(.narrow))
        case .month:
            Text(date, format: .dateTime.day().month(.abbreviated))
        case .year:
            Text(date, format: .dateTime.month(.abbreviated))
        }
    }
}
