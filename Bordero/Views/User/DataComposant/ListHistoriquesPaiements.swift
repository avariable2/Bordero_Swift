//
//  ListHistoriquesPaiements.swift
//  Bordero
//
//  Created by Grande Variable on 17/05/2024.
//

import SwiftUI

struct ListHistoriquesPaiements: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \Paiement.date_, ascending: true)
    ]) var payments : FetchedResults<Paiement>
    
    @State private var activeSheet : ActiveSheet? = nil
    
    var body: some View {
        if payments.isEmpty {
            ContentUnavailableView("Pas de paiements", systemImage: "person.and.background.striped.horizontal", description: Text("Ici sera afficher la liste des paiements de vos clients."))
        } else {
            ForEach(payments.prefix(5), id: \.id) { payment in
                RowHistoriquePaiements(activeSheet: $activeSheet, payment: payment)
                
            }
            
            Button {
                activeSheet = .showAllHistoriquePaiement
            } label: {
                Text("Voir plus")
            }
            .sheet(item: $activeSheet) { activeSheet in
                switch activeSheet {
                case .showAllHistoriquePaiement:
                    NavigationStack {
                        ListAllClientPaiements(payments: payments)
                    }
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

#Preview {
    ListHistoriquesPaiements()
}

struct TextPaiementView: View {
    let payment : Paiement
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(payment.client?.firstname ?? "Inconnu") ") + Text("\(payment.client?.lastname ?? "Inconnu")").bold()
                
                Text(payment.date, format: .dateTime)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(payment.montant, format: .currency(code: "EUR"))
                .fontWeight(.semibold)
        }
        .tint(.primary)
    }
}

struct ListAllClientPaiements: View {
    @Environment(\.dismiss) var dismiss
    @State var payments : FetchedResults<Paiement>
    
    var body: some View {
        List(payments) { payment in
            NavigationLink {
                DisplayPayementSheet(paiement: payment)
            } label: {
                TextPaiementView(payment: payment)
            }
        }
        .trackEventOnAppear(event: .paymentListBrowsed, category: .paymentManagement)
        .navigationTitle("Historique paiements")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text("Retour")
                }
            }
        }
    }
}
