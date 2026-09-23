import SwiftUI

struct HomeDashboardComponentView: View {
    var component: HomeDashboardComponent
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
        case .recentPayments:
            GroupBox {
                ListHistoriquesPaiements()
            } label: {
                Text("Paiements récents")
            }
            .groupBoxStyle(PlainGroupBoxStyle())
        }
    }
}
