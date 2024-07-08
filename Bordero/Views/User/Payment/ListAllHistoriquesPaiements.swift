//
//  ListAllHistoriquesPaiements.swift
//  Bordero
//
//  Created by Grande Variable on 06/06/2024.
//

import SwiftUI

private struct TokenPaiementModel: Identifiable, Hashable, Equatable {
    enum TokenPaiementType {
        case client
        case date
    }
    
    var id = UUID()
    var value : String
    var type : TokenPaiementType
}

struct ListAllClientPaiements: View {
    @Environment(\.dismiss) var dismiss
    @State var payments : FetchedResults<Paiement>
    @State private var searchText = ""
    @State private var tags: [TokenPaiementModel] = []
    
    var filteredPayments: [Paiement] {
        let tokens = tags.map { $0.value }.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        if tokens.isEmpty {
            return Array(self.payments)
        } else {
            return payments.filter { paiement in
                tokens.allSatisfy { term in
                    let clientName = "\(paiement.client?.firstname ?? "") \(paiement.client?.lastname ?? "")".lowercased()
                    let dateFormatted = paiement.date.formatted(.dateTime.month().year()).lowercased()
                    return clientName.contains(term.lowercased()) || dateFormatted.contains(term.lowercased())
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredPayments) { payment in
                NavigationLink {
                    DisplayPayementSheet(paiement: payment)
                } label: {
                    TextPaiementView(payment: payment)
                }
            }
            .searchable(
                text: $searchText,
                tokens: $tags, 
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Recherche",
                token: { token in
                    switch token.type {
                    case .client:
                        Label(token.value, systemImage: "person.crop.circle")
                    case .date:
                        Label(token.value, systemImage: "calendar")
                    }
                }
            )
            .searchSuggestions({
                if !suggestedClients.isEmpty || !suggestedDates.isEmpty {
                    Section("Suggestions") {
                        ForEach(suggestedClients, id: \.self) { suggestion in
                            Label {
                                HighlightedText(text: suggestion, highlight: searchText, primaryColor: .primary, secondaryColor: .secondary)
                            } icon : {
                                Image(systemName: "person.crop.circle")
                                    .foregroundStyle(.blue)
                                    .imageScale(.large)
                            }
                            .searchCompletion(TokenPaiementModel(value: suggestion, type: .client))
                        }
                        
                        ForEach(suggestedDates, id: \.self) { suggestion in
                            Label {
                                HighlightedText(text: suggestion, highlight: searchText, primaryColor: .primary, secondaryColor: .secondary)
                            } icon : {
                                Image(systemName: "calendar")
                                    .foregroundStyle(.blue)
                                    .imageScale(.large)
                            }
                            .searchCompletion(TokenPaiementModel(value: suggestion, type: .date))
                        }
                    }
                }
            })
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
    
    var suggestedClients : [String] {
        let clients = payments.map { $0.client }
        let uniqueClients = Set(clients.map { "\($0?.firstname ?? "") \($0?.lastname ?? "Inconnu")"})
        return uniqueClients.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    var suggestedDates: [String] {
        let dates = payments.map { $0.date }
        let uniqueDates = Set(dates.map { $0.formatted(.dateTime.month().year()) })
        return uniqueDates.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
}
