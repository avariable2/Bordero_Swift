import Foundation

struct GridTotalStatistics {
    struct Value {
        let count: Int
        let amount: Double
        let progress: Double
    }

    let totalPending: Value
    let collected: Value
    let pending: Value
    let overdue: Value

    init(
        documents: [Document],
        period: PeriodStats,
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        let component: Calendar.Component = switch period {
        case .week:
            .weekOfYear
        case .month:
            .month
        case .year:
            .year
        }

        let interval = calendar.dateInterval(of: component, for: now)
            ?? DateInterval(start: now, duration: 0)
        let periodDocuments = documents.filter {
            $0.dateEmission >= interval.start &&
            $0.dateEmission < interval.end &&
            ($0.status == .payed || $0.status == .send)
        }

        let collectedDocuments = periodDocuments.filter { $0.status == .payed }
        let pendingDocuments = periodDocuments.filter {
            $0.status == .send && $0.dateEcheance >= now
        }
        let overdueDocuments = periodDocuments.filter {
            $0.status == .send && $0.dateEcheance < now
        }
        let totalPendingDocuments = pendingDocuments + overdueDocuments
        let totalAmount = periodDocuments.reduce(0) { $0 + $1.totalTTC }

        totalPending = Self.value(
            for: totalPendingDocuments,
            amount: { max($0.resteAPayer, 0) },
            totalAmount: totalAmount
        )
        collected = Self.value(
            for: collectedDocuments,
            amount: \.totalTTC,
            totalAmount: totalAmount
        )
        pending = Self.value(
            for: pendingDocuments,
            amount: { max($0.resteAPayer, 0) },
            totalAmount: totalAmount
        )
        overdue = Self.value(
            for: overdueDocuments,
            amount: { max($0.resteAPayer, 0) },
            totalAmount: totalAmount
        )
    }

    private static func value(
        for documents: [Document],
        amount: (Document) -> Double,
        totalAmount: Double
    ) -> Value {
        let amount = documents.reduce(0) { $0 + amount($1) }
        let progress = totalAmount > 0 ? min(max(amount / totalAmount, 0), 1) : 0

        return Value(count: documents.count, amount: amount, progress: progress)
    }
}
