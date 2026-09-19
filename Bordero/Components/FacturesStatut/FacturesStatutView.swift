import SwiftUI
import CoreData

struct FacturesStatutView: View {
    @FetchRequest(fetchRequest: Document.fetch()) private var documents: FetchedResults<Document>
    @State private var selectedPeriod = "Month"

    var body: some View {
        VStack {
            Picker("Selectionner la période", selection: $selectedPeriod) {
                Text("Semaine").tag("Week")
                Text("Mois").tag("Month")
                Text("Année").tag("Year")
            }
            .pickerStyle(.segmented)
            .padding()

            FacturesStatutChart(statistics: FacturesChartStatistics(
                documents: Array(documents), period: selectedPeriod
            ))
        }
        .background()
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#if DEBUG
#Preview("Statistiques fictives") {
    FacturesStatutView()
        .environment(\.managedObjectContext, PreviewDataController.invoices.context)
        .frame(height: 360)
        .padding()
}

#Preview("Sans données") {
    FacturesStatutView()
        .environment(\.managedObjectContext, PreviewDataController.empty.context)
        .frame(height: 360)
        .padding()
}
#endif
