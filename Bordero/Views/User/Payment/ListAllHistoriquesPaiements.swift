//
//  ListAllHistoriquesPaiements.swift
//  Bordero
//
//  Created by Grande Variable on 06/06/2024.
//

import CoreData
import SwiftUI

struct ListAllClientPaiements: View {
    @AppStorage("home.selectedStatisticsPeriod")
    private var selectedPeriod = StatisticsPeriod.week

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Paiement.date_, ascending: false)
        ]
    )
    private var payments: FetchedResults<Paiement>

    @State private var searchText = ""
    @State private var searchTokens: [SearchToken] = []
    @State private var scrollOffset: CGFloat = 0

    private var filteredPayments: [Paiement] {
        let terms = (searchTokens.map(\.value) + [searchText])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !terms.isEmpty else { return Array(payments) }
        return payments.filter { payment in
            let clientName = [payment.client?.firstname, payment.client?.lastname]
                .compactMap { $0 }
                .joined(separator: " ")
                .lowercased()
            let date = payment.date
                .formatted(.dateTime.month().year())
                .lowercased()

            return terms.allSatisfy { term in
                clientName.contains(term.lowercased()) || date.contains(term.lowercased())
            }
        }
    }

    private var suggestedClients: [String] {
        let names = payments.map { payment in
            [payment.client?.firstname, payment.client?.lastname]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
                .joined(separator: " ")
        }
        return Array(Set(names))
            .filter { !$0.isEmpty && $0.localizedCaseInsensitiveContains(searchText) }
            .sorted()
    }

    private var suggestedDates: [String] {
        let dates = payments.map {
            $0.date.formatted(.dateTime.month().year())
        }
        return Array(Set(dates))
            .filter { $0.localizedCaseInsensitiveContains(searchText) }
            .sorted()
    }

    var body: some View {
        List {
            if searchText.isEmpty && searchTokens.isEmpty {
                Section("Vue d’ensemble") {
                    RevenueOverviewView(selectedPeriod: selectedPeriod)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)

                    NavigationLink {
                        TendancesView()
                    } label: {
                        Label("Voir les tendances", systemImage: "chart.xyaxis.line")
                            .font(.headline)
                            .padding(.vertical, 4)
                    }
                }
            }

            Section("Tous les paiements") {
                if payments.isEmpty {
                    ContentUnavailableView(
                        "Aucun paiement",
                        systemImage: "creditcard",
                        description: Text("Les paiements enregistrés apparaîtront ici.")
                    )
                    .frame(minHeight: 120)
                } else {
                    ForEach(filteredPayments) { payment in
                        NavigationLink {
                            DetailPaiementView(paiement: payment)
                        } label: {
                            PaiementRowView(payment: payment)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .onScrollGeometryChange(
            for: CGFloat.self,
            of: { geometry in
                geometry.contentOffset.y + geometry.contentInsets.top
            },
            action: { _, offset in
                scrollOffset = offset
            }
        )
        .background {
            LedgerGridBackgroundView(
                theme: .facturierOriginal,
                verticalOffset: scrollOffset
            )
        }
        .overlay {
            if filteredPayments.isEmpty && (!searchText.isEmpty || !searchTokens.isEmpty) {
                ContentUnavailableView(
                    "Pas de paiement",
                    systemImage: "creditcard",
                    description: Text("Aucun paiement ne correspond à votre recherche.")
                )
            }
        }
        .searchable(
            text: $searchText,
            tokens: $searchTokens,
            placement: .toolbar,
            prompt: "Rechercher un paiement"
        ) { token in
            switch token.type {
            case .client:
                Label(token.value, systemImage: "person.crop.circle")
            case .date:
                Label(token.value, systemImage: "calendar")
            }
        }
        .searchSuggestions {
            if !suggestedClients.isEmpty || !suggestedDates.isEmpty {
                Section("Suggestions") {
                    ForEach(suggestedClients, id: \.self) { suggestion in
                        Label {
                            HighlightedText(
                                text: suggestion,
                                highlight: searchText,
                                primaryColor: .primary,
                                secondaryColor: .secondary
                            )
                        } icon: {
                            Image(systemName: "person.crop.circle")
                                .foregroundStyle(.blue)
                                .imageScale(.large)
                        }
                        .searchCompletion(
                            SearchToken(value: suggestion, type: .client)
                        )
                    }

                    ForEach(suggestedDates, id: \.self) { suggestion in
                        Label {
                            HighlightedText(
                                text: suggestion,
                                highlight: searchText,
                                primaryColor: .primary,
                                secondaryColor: .secondary
                            )
                        } icon: {
                            Image(systemName: "calendar")
                                .foregroundStyle(.blue)
                                .imageScale(.large)
                        }
                        .searchCompletion(
                            SearchToken(value: suggestion, type: .date)
                        )
                    }
                }
            }
        }
        .trackEventOnAppear(
            event: .paymentListBrowsed,
            category: .paymentManagement
        )
        .navigationTitle("Paiements")
        .environment(\.tendancesVisualTheme, .facturierOriginal)
        .tint(.green)
    }

    private struct SearchToken: Identifiable, Hashable {
        enum TokenType: String, Hashable {
            case client
            case date
        }

        var id: String { "\(type.rawValue)-\(value)" }
        var value: String
        var type: TokenType
    }
}

#if DEBUG
#Preview("Paiements fictifs") {
    NavigationStack {
        ListAllClientPaiements()
    }
    .environment(\.managedObjectContext, PreviewDataController.invoices.context)
}

#Preview("Sans données") {
    NavigationStack {
        ListAllClientPaiements()
    }
    .environment(\.managedObjectContext, PreviewDataController.empty.context)
}
#endif
