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
        Form {
            Section {
                Picker("Temporalité", selection: $temporalite.animation()) {
                    ForEach(TempoChart.allCases) { type in
                        Text(type.rawValue)
                            .font(.title)
                    }
                }
                .pickerStyle(.segmented)
                
                GraphPiView(
                    client: client,
                    temporalite: $temporalite
                )
            }
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden, edges: .bottom)
            .listRowInsets(.none)
            .listRowSpacing(.none)
            
            Section {
                Text("Informations")
            }
        }
        .navigationTitle("Données du client")
        .navigationBarTitleDisplayMode(.inline)
        .contentMargins(.top, 0)
    }
}

#Preview {
    VStack {
        ClientDataView(client: Client.example)
    }
    
}
