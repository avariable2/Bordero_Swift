import CoreData
import Foundation

struct ClientRevenueStatistics {
    struct Value: Identifiable {
        enum ID: Hashable {
            case client(NSManagedObjectID)
            case unknown
        }

        var id: ID
        var clientName: String
        var revenue: Double
    }

    private static let maximumDisplayedClients = 10

    var values: [Value]
    var revenueDomain: ClosedRange<Double>

    init(
        payments: [Paiement],
        period: StatisticsPeriod,
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        let interval = period.interval(containing: now, calendar: calendar)
        var revenueByClient: [Value.ID: Value] = [:]

        for payment in payments where interval.contains(payment.date) {
            guard let amount = StatisticsLimits.amount(payment.montant) else {
                continue
            }

            let id = payment.client.map { Value.ID.client($0.objectID) } ?? .unknown
            let previousValue = revenueByClient[id]
            revenueByClient[id] = Value(
                id: id,
                clientName: previousValue?.clientName ?? Self.clientName(for: payment.client),
                revenue: StatisticsLimits.addingAmount(
                    amount,
                    to: previousValue?.revenue ?? 0
                )
            )
        }

        values = Array(
            revenueByClient.values
                .sorted { $0.revenue > $1.revenue }
                .prefix(Self.maximumDisplayedClients)
        )
        revenueDomain = Self.domain(for: values.map(\.revenue))
    }

    private static func clientName(for client: Client?) -> String {
        guard let client else { return String(localized: "Client inconnu") }
        let name = [client.firstname, client.lastname]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return name.isEmpty ? String(localized: "Client sans nom") : name
    }

    private static func domain(for values: [Double]) -> ClosedRange<Double> {
        let lowerBound = min(values.min() ?? 0, 0)
        let upperBound = max(values.max() ?? 0, 1)
        return lowerBound...upperBound
    }
}
