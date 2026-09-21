//
//  ListHistoriquesPaiements.swift
//  Bordero
//
//  Created by Grande Variable on 17/05/2024.
//

import CoreData
import SwiftUI

struct ListHistoriquesPaiements: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Paiement.date_, ascending: true)
        ]
    ) var payments: FetchedResults<Paiement>
    
    @State private var activeSheet : ActiveSheet? = nil
    
    var body: some View {
        Group {
            if payments.isEmpty {
                ContentUnavailableView(
                    "Pas de paiement",
                    systemImage: "person.and.background.striped.horizontal",
                    description: Text(
                        "Ici sera affichée la liste des paiements de vos clients."
                    )
                )
            } else {
                LazyVStack(alignment: .center, spacing: 12) {
                    ForEach(payments.prefix(5), id: \.id) { payment in
                        RowHistoriquePaiements(activeSheet: $activeSheet, payment: payment)
                        
                        Divider()
                    }
                    
                    Button {
                        activeSheet = .showAllHistoriquePaiement
                    } label: {
                        Text("Voir plus")
                    }
                    .sheet(item: $activeSheet) { activeSheet in
                        switch activeSheet {
                        case .showAllHistoriquePaiement:
                            ListAllClientPaiements()
                        case .showDetailPaiement(paiement: let paiement):
                            NavigationView {
                                DisplayPayementSheet(paiement: paiement)
                            }
                            .presentationDetents([.medium, .large])
                        default:
                            EmptyView() // Impossible
                        }
                    }
                }
            }
        }
        .background()
    }
}

struct RowHistoriquePaiements : View {
    
    @Binding var activeSheet : ActiveSheet?
    let payment : Paiement
    
    var body: some View {
        Button {
            activeSheet = .showDetailPaiement(paiement: payment)
        } label: {
            TextPaiementView(payment: payment)
        }
    }
}

struct TextPaiementView: View {
    let payment : Paiement
    
    private var statusBadgeFacture: some View {
        if (payment.document?.resteAPayer ?? 0) > 0 {
            Text(DocumentStatus.envoyer.rawValue)
                .foregroundStyle(.orange)
        } else {
            Text(DocumentStatus.paye.rawValue)
                .foregroundStyle(.green)
        }
    }
    
    var body: some View {
        HStack(spacing: 10) {
            
            RoundedRectangle(cornerRadius: 5)
                .fill(.fill)
                .frame(width: 110)
                .overlay {
                    Text("#\(payment.document?.numero ?? "Inconnu")")
                        .multilineTextAlignment(.center)
                        .padding(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            
            VStack(alignment: .leading) {
                Text("\(payment.client?.firstname ?? "Inconnu") \(Text(payment.client?.lastname ?? "Inconnu").bold())")
                
                Text(payment.date, format: .dateTime.day().month().year())
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(payment.montant, format: .currency(code: "EUR"))
                    .fontWeight(.medium)
                
                statusBadgeFacture
            }
            
        }
        .tint(.primary)
    }
}

#if DEBUG
#Preview("Paiements fictifs") {
    ListHistoriquesPaiements()
        .environment(\.managedObjectContext, PreviewDataController.invoices.context)
        .padding()
}

#Preview("Sans données") {
    List {
        ListHistoriquesPaiements()
    }
        .environment(\.managedObjectContext, PreviewDataController.empty.context)
        .padding()
}
#endif
