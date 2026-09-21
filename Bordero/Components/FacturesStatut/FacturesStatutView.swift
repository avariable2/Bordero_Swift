import SwiftUI
import CoreData

enum PeriodStats: String, CaseIterable {
    case week = "semaine"
    case month = "mois"
    case year = "année"
    
    var previousPeriodDescription: String {
        switch self {
        case .week: "la semaine précédente"
        case .month: "le mois précédent"
        case .year: "l’année précédente"
        }
    }
}

struct FacturesStatutView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Document.dateEmission_, ascending: true)]
    ) private var documents: FetchedResults<Document>
    
    var selectedPeriod: PeriodStats = .week
    
    private var statistics : FacturesChartStatistics {
        FacturesChartStatistics(
            documents: Array(documents),
            period: selectedPeriod
        )
    }
    private var isRevenueImproving : Bool {
        statistics.currentRevenue > statistics.previousRevenue
    }
    private var isRevenueDeclining : Bool {
        statistics.currentRevenue < statistics.previousRevenue
    }
    private var colorIndicator : Color {
        if isRevenueImproving {
            .green
        } else if isRevenueDeclining {
            .red
        } else {
            .secondary
        }
    }
    private var imageIndicator : String {
        if isRevenueImproving {
            "arrow.up.right"
        } else if isRevenueDeclining {
            "arrow.down.forward"
        } else {
            "equal.circle"
        }
    }
    
    var body: some View {
        GroupBox {
            FacturesStatutChart(statistics: statistics)
        } label: {
            VStack(alignment: .leading) {
                Text("Chiffre d’affaires")
                
                Label {
                    if let revenueChange = statistics.revenueChange {
                        Text(
                            "\(Text(abs(revenueChange), format: .percent.precision(.fractionLength(1))).foregroundStyle(colorIndicator)) vs \(selectedPeriod.previousPeriodDescription)"
                        )
                    } else if statistics.currentRevenue > 0 {
                        Text(
                            "\(Text("Nouveau chiffre d’affaires").foregroundStyle(colorIndicator)) vs \(selectedPeriod.previousPeriodDescription)"
                        )
                    } else {
                        Text("Aucun changement vs \(selectedPeriod.previousPeriodDescription)")
                    }
                } icon: {
                    Image(systemName: imageIndicator)
                        .foregroundStyle(colorIndicator)
                        .imageScale(.medium)
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .labelIconToTitleSpacing(4)
            }
            
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
