import Foundation

struct RevenueTimelinePoint: Identifiable {
    var date: Date
    var amount: Double

    var id: Date { date }
}
