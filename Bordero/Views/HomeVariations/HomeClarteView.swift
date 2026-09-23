import SwiftUI

struct HomeClarteView: View {
    @Environment(\.homeVisualTheme) private var theme
    @AppStorage("home.dashboardComponentOrder")
    private var componentOrderStorage = HomeDashboardComponent.defaultStorageValue

    @Binding var selectedPeriod: StatisticsPeriod
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ZStack {
            HomePaperBackgroundView(
                theme: theme ?? .facturierOriginal,
                verticalOffset: scrollOffset
            )
            .ignoresSafeArea()

            List {
                ForEach(orderedComponents) { component in
                    HomeDashboardComponentView(
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

    private var orderedComponents: [HomeDashboardComponent] {
        HomeDashboardComponent.order(from: componentOrderStorage)
    }

    private func moveComponents(from source: IndexSet, to destination: Int) {
        var components = orderedComponents
        components.move(fromOffsets: source, toOffset: destination)
        componentOrderStorage = HomeDashboardComponent.storageValue(for: components)
    }
}
