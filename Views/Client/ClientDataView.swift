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
    @State var data : [PieChartData] = []
    @State var temporalite : TempoChart = .mois
    
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
                Section {
                    GraphPiView(
                        client: client,
                        temporalite: $temporalite
                    )
                }
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden, edges: .bottom)
                .listRowInsets(.none)
                .listRowSpacing(.none)
                
                DataBrutView(client: client, temporalite: $temporalite)
                    .listRowInsets(EdgeInsets())
            }
            .navigationTitle("Données du client")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    VStack {
        ClientDataView(client: Client.example)
    }
    
}
