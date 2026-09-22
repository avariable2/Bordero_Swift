import Foundation

struct GridTotalStatistics {
    struct Value {
        var count: Int
        var amount: Double
        var progress: Double
    }

    var totalPending: Value
    var collected: Value
    var pending: Value
    var overdue: Value

    init(
        documents: [Document],
        period: StatisticsPeriod,
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        let interval = period.interval(containing: now, calendar: calendar)
        let periodDocuments = documents.filter {
            $0.dateEmission >= interval.start && $0.dateEmission < interval.end
                && ($0.status == .payed || $0.status == .send)
        }

        let collectedDocuments = periodDocuments.filter { $0.status == .payed }
        let pendingDocuments = periodDocuments.filter {
            $0.status == .send && $0.dateEcheance >= now
        }
        let overdueDocuments = periodDocuments.filter {
            $0.status == .send && $0.dateEcheance < now
        }
        let totalPendingDocuments = pendingDocuments + overdueDocuments
        let totalAmount = periodDocuments.reduce(0) { total, document in
            StatisticsLimits.addingAmount(document.totalTTC, to: total)
        }

        totalPending = Self.value(
            for: totalPendingDocuments,
            amountForDocument: { max($0.resteAPayer, 0) },
            totalAmount: totalAmount
        )
        collected = Self.value(
            for: collectedDocuments,
            amountForDocument: \.totalTTC,
            totalAmount: totalAmount
        )
        pending = Self.value(
            for: pendingDocuments,
            amountForDocument: { max($0.resteAPayer, 0) },
            totalAmount: totalAmount
        )
        overdue = Self.value(
            for: overdueDocuments,
            amountForDocument: { max($0.resteAPayer, 0) },
            totalAmount: totalAmount
        )
    }

    private static func value(
        for documents: [Document],
        amountForDocument: (Document) -> Double,
        totalAmount: Double
    ) -> Value {
        let amount = documents.reduce(0) { total, document in
            StatisticsLimits.addingAmount(
                amountForDocument(document),
                to: total
            )
        }
        let progress = totalAmount > 0 ? min(max(amount / totalAmount, 0), 1) : 0

        return Value(count: documents.count, amount: amount, progress: progress)
    }
}
