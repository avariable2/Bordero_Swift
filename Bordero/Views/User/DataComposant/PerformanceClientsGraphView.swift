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
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \Paiement.date_, ascending: true)
    ]) var payments : FetchedResults<Paiement>
    
    @State var clientRevenues: [ClientRevenue] = []
    
    var body: some View {
        VStack {
            if clientRevenues.isEmpty {
                ContentUnavailableView(
                    "Aucun Top Client",
                    systemImage: "trophy.fill",
                    description: Text("Aucun paiement n'a été enregistré pour un client")
                )
            } else {
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
        }
        .onAppear {
            clientRevenues = calculateClientRevenues(payments: Array(payments))
        }
    }
    
    func calculateClientRevenues(payments: [Paiement]) -> [ClientRevenue] {
        var revenueByClient: [String: Double] = [:]
        
        for payement in payments {
            let clientName = "\(payement.client?.firstname ?? "Inconnu") \(payement.client?.lastname ?? "")"
            let revenue = payement.montant
            
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
