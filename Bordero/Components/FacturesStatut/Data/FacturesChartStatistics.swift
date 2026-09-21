import Foundation

struct FacturesChartStatistics {
    let data: [DocumentChartData]
    let periods: [String]
    let maximumCount: Int
    let currentRevenue: Double
    let previousRevenue: Double
    private let currentPeriod: Date
    private let maximumDistance: TimeInterval

    var revenueChange: Double? {
        guard previousRevenue > 0 else { return nil }
        return (currentRevenue - previousRevenue) / previousRevenue
    }

    init(documents: [Document], period: PeriodStats, now: Date = Date(), calendar: Calendar = .current) {
        let scope: Calendar.Component
        let unit: Calendar.Component
        switch period {
        case .year: (scope, unit) = (.year, .month)
        case .week: (scope, unit) = (.weekOfYear, .day)
        case .month: (scope, unit) = (.month, .weekOfYear)
        }
        let interval = calendar.dateInterval(of: scope, for: now) ?? DateInterval(start: now, duration: 0)
        let previousDate = calendar.date(byAdding: scope, value: -1, to: interval.start) ?? interval.start
        let previousInterval = calendar.dateInterval(of: scope, for: previousDate)
            ?? DateInterval(start: previousDate, duration: 0)
        let first = calendar.dateInterval(of: unit, for: interval.start)?.start ?? interval.start
        var dates: [Date] = []
        var date = first
        while date < interval.end {
            dates.append(date)
            guard let next = calendar.date(byAdding: unit, value: 1, to: date), next > date else { break }
            date = next
        }

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = calendar.locale ?? .current
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = period == .year ? "MMM" : "EEE"
        periods = dates.enumerated().map { index, date in
            period == .month ? "Sem. \(index + 1)" : formatter.string(from: date)
        }

        // Les semaines à cheval sur deux mois ne comptent que les factures du mois affiché.
        let eligibleDocuments = documents.filter {
            $0.dateEmission >= interval.start && $0.dateEmission < interval.end &&
            ($0.status == .payed || $0.status == .send)
        }
        currentRevenue = eligibleDocuments.reduce(0) { $0 + $1.totalTTC }
        previousRevenue = documents.reduce(0) { total, document in
            guard document.dateEmission >= previousInterval.start,
                  document.dateEmission < previousInterval.end,
                  document.status == .payed || document.status == .send else {
                return total
            }
            return total + document.totalTTC
        }

        let grouped = Dictionary(grouping: eligibleDocuments) {
            calendar.dateInterval(of: unit, for: $0.dateEmission)?.start ?? $0.dateEmission
        }
        data = zip(dates, periods).flatMap { date, label in
            let counts = (grouped[date] ?? []).reduce(into: [DocumentStatus: Int]()) { counts, document in
                let status: DocumentStatus = document.status == .payed ? .paye :
                    document.dateEcheance < now ? .enRetard : .envoyer
                counts[status, default: 0] += 1
            }
            return [DocumentStatus.envoyer, .paye, .enRetard].compactMap { status -> DocumentChartData? in
                guard let count = counts[status] else { return nil }
                return DocumentChartData(period: label, date: date, status: status, count: count)
            }
        }
        maximumCount = max(grouped.values.map(\.count).max() ?? 0, 5)
        currentPeriod = calendar.dateInterval(of: unit, for: now)?.start ?? now
        maximumDistance = dates.map { [currentPeriod] in
            abs($0.timeIntervalSince(currentPeriod))
        }.max() ?? 0
    }

    func opacity(for element: DocumentChartData) -> Double {
        maximumDistance == 0 ? 1 :
            1 - 0.4 * abs(element.date.timeIntervalSince(currentPeriod)) / maximumDistance
    }
}
