import CoreData
import Foundation

struct ClientPaymentDelayStatistics {
    struct Value: Identifiable {
        var id: NSManagedObjectID
        var clientName: String
        var averageDelayInDays: Double
    }

    private static let maximumDisplayedClients = 10
    private static let secondsPerDay = 86_400.0

    var values: [Value]
    var averageDelayInDays: Double?
    var delayDomain: ClosedRange<Double>

    init(
        clients: [Client],
        period: StatisticsPeriod,
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        let interval = period.interval(containing: now, calendar: calendar)
        let allValues = clients.compactMap { client in
            Self.value(for: client, in: interval)
        }
        let displayedValues = Array(
            allValues
                .sorted { $0.averageDelayInDays > $1.averageDelayInDays }
                .prefix(Self.maximumDisplayedClients)
        )
        let average = Self.average(of: allValues.map(\.averageDelayInDays))

        values = displayedValues
        averageDelayInDays = average
        delayDomain = Self.domain(
            for: displayedValues.map(\.averageDelayInDays),
            including: average
        )
    }

    private static func value(
        for client: Client,
        in interval: DateInterval
    ) -> Value? {
        var average = 0.0
        var count = 0

        for document in client.listDocuments {
            for payment in document.listPayements where interval.contains(payment.date) {
                let delay = payment.date.timeIntervalSince(document.dateEmission) / secondsPerDay
                guard let delay = StatisticsLimits.paymentDelayInDays(delay) else {
                    continue
                }

                count += 1
                average += (delay - average) / Double(count)
            }
        }

        guard count > 0 else { return nil }
        return Value(
            id: client.objectID,
            clientName: client.lastname.isEmpty
                ? String(localized: "Client sans nom")
                : client.lastname,
            averageDelayInDays: average
        )
    }

    private static func average(of values: [Double]) -> Double? {
        guard !values.isEmpty else { return nil }
        var average = 0.0

        for (index, value) in values.enumerated() {
            average += (value - average) / Double(index + 1)
        }
        return average
    }

    private static func domain(
        for values: [Double],
        including average: Double?
    ) -> ClosedRange<Double> {
        let candidates = values + [average].compactMap { $0 }
        let lowerBound = min(candidates.min() ?? 0, 0)
        let upperBound = max(candidates.max() ?? 0, 1)
        return lowerBound...upperBound
    }
}
