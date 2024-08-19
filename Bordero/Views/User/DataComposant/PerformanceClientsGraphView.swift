//
//  PerformanceClientsGraphView.swift
//  Bordero
//
//  Created by Grande Variable on 15/05/2024.
//

import SwiftUI
import Charts

struct PerformanceClientsGraphView: View {
    
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \Paiement.date_, ascending: true)
    ]) var payments : FetchedResults<Paiement>
    
    @State var clientRevenues: [ClientRevenue] = []
    
    var body: some View {
        Chart(clientRevenues.prefix(10)) { clientRevenue in
            BarMark(
                x: .value("Client", clientRevenue.clientName),
                y: .value("Revenu", clientRevenue.revenue)
            )
            .foregroundStyle(.yellow)
        }
        .frame(height: 250)
        .padding()
        .onAppear {
            calculateClientRevenues()
        }
        .overlay {
            if clientRevenues.isEmpty {
                ContentUnavailableView(
                    "Aucun Top Client",
                    systemImage: "trophy.fill",
                    description: Text("Aucun paiement n'a été enregistré pour un client")
                )
            }
        }
    }
    
    func calculateClientRevenues() {
        let revenueByClient = payments.reduce(into: [String: Double]()) { result, payment in
            let clientName = "\(payment.client?.firstname ?? "Inconnu") \(payment.client?.lastname ?? "")"
            let revenue = payment.montant
            
            result[clientName, default: 0] += revenue
        }
        
        clientRevenues = revenueByClient.map { ClientRevenue(clientName: $0.key, revenue: $0.value) }
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
