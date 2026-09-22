import Foundation

enum StatisticsLimits {
    private static let maximumAmountMagnitude = 1_000_000_000_000.0
    private static let maximumPaymentDelayInDays = 36_525.0

    static func amount(_ value: Double) -> Double? {
        guard value.isFinite,
            abs(value) <= maximumAmountMagnitude
        else { return nil }
        return value
    }

    static func addingAmount(_ value: Double, to total: Double) -> Double {
        guard let value = amount(value), total.isFinite else { return total }
        return min(
            max(total + value, -maximumAmountMagnitude),
            maximumAmountMagnitude
        )
    }

    static func paymentDelayInDays(_ value: Double) -> Double? {
        guard value.isFinite,
            abs(value) <= maximumPaymentDelayInDays
        else { return nil }
        return value
    }
}
