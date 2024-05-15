//
//  PerformanceClientsGraphView.swift
//  Bordero
//
//  Created by Grande Variable on 15/05/2024.
//

import SwiftUI
import Charts

struct PerformanceClientsGraphView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(
        entity: Document.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Document.totalTTC_, ascending: false)]
    ) var documents: FetchedResults<Document>
    
    @State var clientRevenues: [ClientRevenue] = []
    
    var body: some View {
        VStack {
            
            Chart(clientRevenues.prefix(10)) { clientRevenue in
                BarMark(
                    x: .value("Client", clientRevenue.clientName),
                    y: .value("Revenu", clientRevenue.revenue)
                )
                .foregroundStyle(.yellow)
            }
            .frame(height: 300)
            .padding()
        }
        .onAppear {
            clientRevenues = calculateClientRevenues(documents: Array(documents))
        }
    }
    
    func calculateClientRevenues(documents: [Document]) -> [ClientRevenue] {
        var revenueByClient: [String: Double] = [:]
        
        for document in documents {
            let clientName = "\(document.client_?.firstname ?? "Inconnu") \(document.client_?.lastname ?? "")"
            let revenue = document.totalTTC
            
            if revenueByClient[clientName] == nil {
                revenueByClient[clientName] = 0
            }
            revenueByClient[clientName]! += revenue
        }
        
        return revenueByClient.map { ClientRevenue(clientName: $0.key, revenue: $0.value) }
            .sorted { $0.revenue > $1.revenue } // Sort by revenue in descending order
    }
}

struct ClientRevenue: Identifiable {
    let id = UUID()
    let clientName: String
    let revenue: Double
}

#Preview {
    PerformanceClientsGraphView()
}
