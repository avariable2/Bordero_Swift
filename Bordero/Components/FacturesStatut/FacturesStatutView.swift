import SwiftUI
import CoreData

struct FacturesStatutView: View {
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Document.dateEmission_, ascending: true)
        ]
    )
    private var documents: FetchedResults<Document>

    var selectedPeriod: StatisticsPeriod = .week

    var body: some View {
        let statistics = FacturesChartStatistics(
            documents: Array(documents),
            period: selectedPeriod
        )

        GroupBox {
            if statistics.data.isEmpty {
                ContentUnavailableView(
                    "Aucune donnée",
                    systemImage: "chart.xyaxis.line",
                    description: Text("Les documents de cette période apparaîtront ici.")
                )
                .frame(minHeight: 120)
            } else {
                FacturesStatutChart(statistics: statistics)
            }
        } label: {
            Text("Répartition des factures")
        }
        .groupBoxStyle(PlainGroupBoxStyle())
    }
}

#if DEBUG
#Preview("Statistiques fictives") {
    List {
        FacturesStatutView(selectedPeriod: .month)
    }
    .environment(\.managedObjectContext, PreviewDataController.invoices.context)
    .padding()
}

#Preview("Sans données") {
    FacturesStatutView(selectedPeriod: .month)
        .environment(\.managedObjectContext, PreviewDataController.empty.context)
        .frame(height: 360)
        .padding()
}
#endif
