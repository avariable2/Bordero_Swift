//
//  StatistiquesPraticien.swift
//  Bordero
//
//  Created by Grande Variable on 15/05/2024.
//

import SwiftUI

struct PraticienDataView: View {
    var documents : FetchedResults<Document>
    
    var body: some View {
        VStack {
            List {
                Section {
                    ClientPaymentEstimateGraphView()
                } header: {
                    Text("Temps moyen de paiement des clients")
                        .fixedSize()
                }
                
                Section("Revenu sur période") {
                    PaiementPraticienGraphView()
                }
                
                Section("Top Clients par Revenu (€)") {
                    PerformanceClientsGraphView()
                }
                
                Section("Répartition factures") {
                    NbFacturesGraphView(documents: documents)
                }
                
                Section("Historique paiements") {
                    ListHistoriquesPaiements()
                }
            }
            .navigationTitle("Tableau de bord")
            .headerProminence(.increased)
        }
        .trackEventOnAppear(event: .praticienDashboardShowed, category: .praticienManagement)
    }
}

//#Preview {
//    PraticienDataView(documents: Document.fetchRequest())
//}
