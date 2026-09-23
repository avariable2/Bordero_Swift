import SwiftUI

struct HomeGraphPairView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var selectedPeriod: StatisticsPeriod

    private var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 2 : 1
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: count)
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            PerformanceClientsGraphView(selectedPeriod: selectedPeriod)
            ClientPaymentEstimateGraphView(selectedPeriod: selectedPeriod)
        }
    }
}
