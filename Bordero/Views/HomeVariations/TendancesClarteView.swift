import SwiftUI

struct TendancesClarteView: View {
    @Environment(\.tendancesVisualTheme) private var theme
    @AppStorage("home.dashboardComponentOrder")
    private var componentOrderStorage = TendancesDashboardComponent.defaultStorageValue

    @Binding var selectedPeriod: StatisticsPeriod
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ZStack {
            LedgerGridBackgroundView(
                theme: theme ?? .facturierOriginal,
                verticalOffset: scrollOffset
            )
            .ignoresSafeArea()

            List {
                ForEach(orderedComponents) { component in
                    TendancesDashboardComponentView(
                        component: component,
                        selectedPeriod: $selectedPeriod
                    )
                    .listRowInsets(
                        EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .onMove(perform: moveComponents)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .onScrollGeometryChange(
                for: CGFloat.self,
                of: { geometry in
                    geometry.contentOffset.y + geometry.contentInsets.top
                },
                action: { _, newScrollOffset in
                    scrollOffset = newScrollOffset
                }
            )
        }
        .animation(.snappy, value: componentOrderStorage)
    }

    private var orderedComponents: [TendancesDashboardComponent] {
        TendancesDashboardComponent.order(from: componentOrderStorage)
    }

    private func moveComponents(from source: IndexSet, to destination: Int) {
        var components = orderedComponents
        components.move(fromOffsets: source, toOffset: destination)
        componentOrderStorage = TendancesDashboardComponent.storageValue(for: components)
    }
}
