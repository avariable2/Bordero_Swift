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
                Section("Revenu sur période") {
                    PaiementPraticienGraphView()
                }
                
                Section("Répartition factures") {
                    NbFacturesGraphView()
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
