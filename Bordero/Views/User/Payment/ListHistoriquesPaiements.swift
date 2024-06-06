//
//  ListHistoriquesPaiements.swift
//  Bordero
//
//  Created by Grande Variable on 17/05/2024.
//

import SwiftUI
import TokenTextField

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
                    ListAllClientPaiements(payments: payments)
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
    @State private var searchText = ""
    @State private var selectedTokens: [SearchToken] = []
    
    var filteredPayments: [Paiement] {
        var paymentsFilter = Array(self.payments)
        if selectedTokens.count > 0 {
            paymentsFilter = payments.filter { payment in  payment.client?.lastname.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        if selectedTokens.count > 0 {
            let tokens = selectedTokens.map { $0.value }
//            paymentsFilter = payments.filter { payment in
//                payment.client?.lastname.contains(<#T##regex: RegexComponent##RegexComponent#>)
//            }
        }
        return paymentsFilter
    }
    
    var body: some View {
        NavigationStack {
            
            List(payments) { payment in
                NavigationLink {
                    DisplayPayementSheet(paiement: payment)
                } label: {
                    TextPaiementView(payment: payment)
                }
            }
            .searchable(text: $searchText, tokens: $selectedTokens, prompt: "Rechercher par nom de client ou date") { token in
                Text(token.value)
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
}

struct TokenView: View {
    var token: SearchToken
    var removeAction: () -> Void
    
    var body: some View {
        HStack {
            Text(token.value)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            Button(action: removeAction) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding(.leading, 4)
            }
        }
    }
}

struct SearchToken: Identifiable, Hashable {
    let id = UUID()
    var value: String
    var type: TokenType
    
    static func testData() -> [SearchToken] {
        [
            SearchToken(value: "John Appleseed", type: .client),
            SearchToken(value: "Kate Bell", type: .client),
            SearchToken(value: "16/05/2024", type: .date)
        ]
    }
}

enum TokenType {
    case client
    case date
}

#Preview {
    ListHistoriquesPaiements()
}
