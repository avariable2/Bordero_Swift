import SwiftUI

struct HomeGraphPairView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var availableWidth: CGFloat = 0

    var selectedPeriod: StatisticsPeriod

    private var columns: [GridItem] {
        let count = availableWidth >= 700 && !dynamicTypeSize.isAccessibilitySize ? 2 : 1
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: count)
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            PerformanceClientsGraphView(selectedPeriod: selectedPeriod)
            ClientPaymentEstimateGraphView(selectedPeriod: selectedPeriod)
        }
        .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) { _, width in
            availableWidth = width
        }
    }
}
