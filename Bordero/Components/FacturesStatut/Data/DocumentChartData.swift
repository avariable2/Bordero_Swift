import Foundation

struct DocumentChartData: Identifiable {
    struct ID: Hashable {
        var date: Date
        var status: DocumentStatus
    }

    var id: ID { ID(date: date, status: status) }
    var period: String
    var date: Date
    var status: DocumentStatus
    var count: Int
}
