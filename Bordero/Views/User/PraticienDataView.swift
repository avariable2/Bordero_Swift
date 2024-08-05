//
//  StatistiquesPraticien.swift
//  Bordero
//
//  Created by Grande Variable on 15/05/2024.
//

import SwiftUI

struct PraticienDataView: View {
    var documents : FetchedResults<Document>
    
    @State private var isExpandClientPayement = true
    @State private var isExpandPayementPraticien = true
    @State private var isExpandPerfClient = true
    @State private var isExpandHistoPayement = true
    
    var body: some View {
        VStack {
            List {
                Section {
                    DisclosureGroup(isExpanded: $isExpandClientPayement) {
                        ClientPaymentEstimateGraphView()
                    } label: {
                        ViewThatFits {
                            Text("Temps moyen de paiement des clients")
                            
                            Text("Délai moyen de paiement")
                        }
                        .bold()
                    }
                }
                
                Section {
                    DisclosureGroup(isExpanded: $isExpandPayementPraticien) {
                        PaiementPraticienGraphView()
                    } label: {
                        Text("Revenu sur période").bold()
                    }
                }
                
                
                Section {
                    DisclosureGroup(isExpanded: $isExpandPerfClient) {
                        PerformanceClientsGraphView()
                    } label: {
                        Text("Top Clients par Revenu (€)").bold()
                    }
                }
                
                Section {
                    NbFacturesGraphView(documents: documents)
                }
                
                
                Section {
                    DisclosureGroup(isExpanded: $isExpandHistoPayement) {
                        ListHistoriquesPaiements()
                    } label: {
                        Text("Historique paiements").bold()
                    }
                }
                
            }
            .navigationTitle("Tableau de bord")
            .headerProminence(.increased)
        }
//        .listStyle(.plain)
        .trackEventOnAppear(event: .praticienDashboardShowed, category: .praticienManagement)
    }
}

//#Preview {
//    PraticienDataView(documents: Document.fetchRequest())
//}
