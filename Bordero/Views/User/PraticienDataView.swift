//
//  StatistiquesPraticien.swift
//  Bordero
//
//  Created by Grande Variable on 15/05/2024.
//

import SwiftUI

struct PraticienDataView: View {
    
    
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
                    NbFacturesGraphView()
                }
                
                Section("Historique paiements") {
                    ListHistoriquesPaiements()
                }
            }
            .navigationTitle("Tableau de bord")
            .headerProminence(.increased)
        }
    }
}

#Preview {
    PraticienDataView()
}
