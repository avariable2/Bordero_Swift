import Foundation

struct FacturesChartStatistics {
    private static let displayedStatuses: [DocumentStatus] = [
        .envoyer,
        .paye,
        .enRetard,
    ]

    var data: [DocumentChartData]
    var periods: [String]
    var countDomain: ClosedRange<Double>
    var currentRevenue: Double
    var previousRevenue: Double

    private var currentPeriod: Date
    private var maximumDistance: TimeInterval

    var revenueChange: Double? {
        guard previousRevenue > 0 else { return nil }
        let change = (currentRevenue - previousRevenue) / previousRevenue
        return change.isFinite ? change : nil
    }

    init(
        documents: [Document],
        period: StatisticsPeriod,
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        let interval = period.interval(containing: now, calendar: calendar)
        let previousInterval = Self.previousInterval(
            before: interval,
            period: period,
            calendar: calendar
        )
        let periodStarts = Self.periodStarts(
            in: interval,
            component: period.chartComponent,
            calendar: calendar
        )
        let labels = Self.labels(
            for: periodStarts,
            period: period,
            calendar: calendar
        )
        let eligibleDocuments = documents.filter {
            interval.contains($0.dateEmission) && ($0.status == .payed || $0.status == .send)
        }
        let documentsByPeriod = Dictionary(grouping: eligibleDocuments) {
            calendar.dateInterval(of: period.chartComponent, for: $0.dateEmission)?.start
                ?? $0.dateEmission
        }

        periods = labels
        currentRevenue = Self.revenue(for: eligibleDocuments)
        previousRevenue = Self.revenue(
            for: documents.filter {
                previousInterval.contains($0.dateEmission) && ($0.status == .payed || $0.status == .send)
            }
        )
        data = zip(periodStarts, labels).flatMap { date, label in
            Self.chartData(
                for: documentsByPeriod[date] ?? [],
                date: date,
                label: label,
                now: now
            )
        }

        let maximumCount = max(documentsByPeriod.values.map(\.count).max() ?? 0, 5)
        countDomain = 0...Double(maximumCount)
        let currentPeriod =
            calendar.dateInterval(
                of: period.chartComponent,
                for: now
            )?.start ?? now
        self.currentPeriod = currentPeriod
        maximumDistance =
            periodStarts.map {
                abs($0.timeIntervalSince(currentPeriod))
            }.max() ?? 0
    }

    func opacity(for element: DocumentChartData) -> Double {
        guard maximumDistance.isFinite, maximumDistance > 0 else { return 1 }
        let distance = abs(element.date.timeIntervalSince(currentPeriod))
        guard distance.isFinite else { return 1 }
        return min(max(1 - 0.4 * distance / maximumDistance, 0.6), 1)
    }

    private static func previousInterval(
        before interval: DateInterval,
        period: StatisticsPeriod,
        calendar: Calendar
    ) -> DateInterval {
        guard
            let previousDate = calendar.date(
                byAdding: period.calendarComponent,
                value: -1,
                to: interval.start
            )
        else {
            return DateInterval(start: interval.start, duration: 0)
        }
        return period.interval(containing: previousDate, calendar: calendar)
    }

    private static func periodStarts(
        in interval: DateInterval,
        component: Calendar.Component,
        calendar: Calendar
    ) -> [Date] {
        let firstDate =
            calendar.dateInterval(of: component, for: interval.start)?.start
            ?? interval.start
        var dates: [Date] = []
        var date = firstDate

        while date < interval.end {
            dates.append(date)
            guard
                let nextDate = calendar.date(
                    byAdding: component,
                    value: 1,
                    to: date
                ), nextDate > date
            else {
                break
            }
            date = nextDate
        }
        return dates
    }

    private static func labels(
        for dates: [Date],
        period: StatisticsPeriod,
        calendar: Calendar
    ) -> [String] {
        guard period != .month else {
            return dates.indices.map { "Sem. \($0 + 1)" }
        }

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = calendar.locale ?? .current
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = period == .year ? "MMM" : "EEE"
        return dates.map(formatter.string(from:))
    }

    private static func chartData(
        for documents: [Document],
        date: Date,
        label: String,
        now: Date
    ) -> [DocumentChartData] {
        let counts = documents.reduce(into: [DocumentStatus: Int]()) { counts, document in
            counts[chartStatus(for: document, now: now), default: 0] += 1
        }

        return displayedStatuses.compactMap { status in
            guard let count = counts[status] else { return nil }
            return DocumentChartData(
                period: label,
                date: date,
                status: status,
                count: count
            )
        }
    }

    private static func chartStatus(
        for document: Document,
        now: Date
    ) -> DocumentStatus {
        if document.status == .payed {
            return .paye
        }
        return document.dateEcheance < now ? .enRetard : .envoyer
    }

    private static func revenue(for documents: [Document]) -> Double {
        documents.reduce(0) { total, document in
            StatisticsLimits.addingAmount(document.totalTTC, to: total)
        }
    }
}
