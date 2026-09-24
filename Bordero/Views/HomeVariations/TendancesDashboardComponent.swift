import Foundation

enum TendancesDashboardComponent: String, CaseIterable, Identifiable {
    case period
    case revenue
    case invoiceDistribution
    case totals
    case clients

    var id: Self { self }

    static var defaultOrder: [Self] {
        [
            .period,
            .revenue,
            .invoiceDistribution,
            .totals,
            .clients,
        ]
    }

    static var defaultStorageValue: String {
        storageValue(for: defaultOrder)
    }

    static func order(from storageValue: String) -> [Self] {
        var seen = Set<Self>()
        let savedComponents = storageValue
            .split(separator: ",")
            .compactMap { Self(rawValue: String($0)) }
            .filter { seen.insert($0).inserted }
        let missingComponents = defaultOrder.filter { seen.insert($0).inserted }
        return savedComponents + missingComponents
    }

    static func storageValue(for components: [Self]) -> String {
        components.map(\.rawValue).joined(separator: ",")
    }
}
