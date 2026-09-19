import Foundation

struct DocumentChartData: Identifiable {
    var id: String { "\(date.timeIntervalSinceReferenceDate)-\(status.rawValue)" }
    let period: String
    let date: Date
    let status: DocumentStatus
    let count: Int
}
