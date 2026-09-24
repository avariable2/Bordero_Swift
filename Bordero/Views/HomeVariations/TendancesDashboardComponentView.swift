import SwiftUI

struct TendancesDashboardComponentView: View {
    var component: TendancesDashboardComponent
    @Binding var selectedPeriod: StatisticsPeriod

    @ViewBuilder
    var body: some View {
        switch component {
        case .period:
            HomePeriodControlView(selectedPeriod: $selectedPeriod)
        case .revenue:
            RevenueOverviewView(selectedPeriod: selectedPeriod)
        case .invoiceDistribution:
            FacturesStatutView(selectedPeriod: selectedPeriod)
        case .totals:
            GridTotalStatsView(selectedPeriod: selectedPeriod)
        case .clients:
            HomeGraphPairView(selectedPeriod: selectedPeriod)
        }
    }
}
