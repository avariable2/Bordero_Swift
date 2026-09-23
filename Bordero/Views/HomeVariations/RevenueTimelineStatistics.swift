import Foundation

struct RevenueTimelineStatistics {
    var points: [RevenueTimelinePoint]
    var total: Double
    var previousTotal: Double
    var amountDomain: ClosedRange<Double>
    var hasDocuments: Bool

    var change: Double? {
        guard abs(previousTotal) > 0.005 else { return nil }
        let value = (total - previousTotal) / abs(previousTotal)
        return value.isFinite ? value : nil
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
        let currentDocuments = documents.filter {
            Self.isIncluded($0, in: interval)
        }
        let previousDocuments = documents.filter {
            Self.isIncluded($0, in: previousInterval)
        }
        let starts = Self.periodStarts(
            in: interval,
            component: period.chartComponent,
            calendar: calendar
        )
        let documentsByStart = Dictionary(grouping: currentDocuments) { document in
            calendar.dateInterval(
                of: period.chartComponent,
                for: document.dateEmission
            )?.start ?? document.dateEmission
        }

        points = starts.map { start in
            RevenueTimelinePoint(
                date: start,
                amount: Self.revenue(for: documentsByStart[start] ?? [])
            )
        }
        total = Self.revenue(for: currentDocuments)
        previousTotal = Self.revenue(for: previousDocuments)
        hasDocuments = !currentDocuments.isEmpty
        amountDomain = Self.domain(for: points.map(\.amount))
    }

    private static func isIncluded(
        _ document: Document,
        in interval: DateInterval
    ) -> Bool {
        document.dateEmission >= interval.start
            && document.dateEmission < interval.end
            && (document.status == .payed || document.status == .send)
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
        let firstStart = calendar.dateInterval(
            of: component,
            for: interval.start
        )?.start ?? interval.start
        var starts: [Date] = []
        var start = firstStart

        while start < interval.end {
            starts.append(start)
            guard
                let nextStart = calendar.date(
                    byAdding: component,
                    value: 1,
                    to: start
                ),
                nextStart > start
            else {
                break
            }
            start = nextStart
        }
        return starts
    }

    private static func revenue(for documents: [Document]) -> Double {
        documents.reduce(0) { total, document in
            StatisticsLimits.addingAmount(document.totalTTC, to: total)
        }
    }

    private static func domain(for amounts: [Double]) -> ClosedRange<Double> {
        let lowerValue = min(amounts.min() ?? 0, 0)
        let upperValue = max(amounts.max() ?? 0, 0)
        let span = max(upperValue - lowerValue, 1)
        return (lowerValue - span * 0.08)...(upperValue + span * 0.12)
    }
}
