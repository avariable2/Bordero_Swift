//
//  ClientDataView.swift
//  Bordero
//
//  Created by Grande Variable on 06/05/2024.
//

import SwiftUI
import Charts

enum TempoChart : String, CaseIterable, Identifiable, Codable {
    case semaine = "Semaine"
    case mois = "Mois"
    case sixMois = "6 mois"
    case annee = "Année"
    
    var id: Self { self }
}

struct ClientDataView: View {
    @State var client : Client
    @State var temporalite : TempoChart = .mois
    
    @State var showHistoriquePaiement = false
    
    var body: some View {
        VStack {
            Picker("Temporalité", selection: $temporalite.animation()) {
                ForEach(TempoChart.allCases) { type in
                    Text(type.rawValue)
                        .font(.title)
                }
            }
            .pickerStyle(.segmented)
            .padding([.leading, .trailing, .top])
            
            Form {
                Section("Paiement(s)") {
                    let listTrier = client.listPaiements.sorted { $0.date < $1.date }
                    PaiementClientGraphView(
                        temporalite: $temporalite, paiements: Array(listTrier)
                    )
                    
                    Button {
                        showHistoriquePaiement = true
                    } label: {
                        Text("Voir l'historique des paiements")
                    }
                }
                
                Section("Suivi document(s)") {
                    GraphPiView(
                        client: client,
                        temporalite: $temporalite
                    )
                }
                
                DataBrutView(client: client, temporalite: $temporalite)
                    .listRowInsets(EdgeInsets())
            }
            .navigationTitle("Données de \(client.firstname) \(client.lastname)")
            .navigationBarTitleDisplayMode(.inline)
            .headerProminence(.increased)
            .sheet(isPresented: $showHistoriquePaiement) {
                NavigationStack {
                    HistoriquePaiementView(client: client)
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview {
    VStack {
        ClientDataView(client: Client.example)
    }
    
}
