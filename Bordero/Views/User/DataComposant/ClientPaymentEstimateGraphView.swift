//
//  ClientPaymentEstimateGraphView.swift
//  Bordero
//
//  Created by Grande Variable on 17/05/2024.
//

import SwiftUI
import Charts

struct ClientPaymentEstimateGraphView: View {
    @FetchRequest(
        entity: Client.entity(),
        sortDescriptors: []
    ) var clients: FetchedResults<Client>
    
    var body: some View {
        let clientData = calculateClientPaymentData(clients: Array(clients))
        if !clientData.isEmpty  {
            CombinedChartView(clientData: clientData)
        } else {
            ContentUnavailableView("Pas de données disponibles", systemImage: "chart.line.flattrend.xyaxis")
        }
    }
}

struct CombinedChartView: View {
    let clientData: [ClientPaymentData]
    
    var body: some View {
        let averageTime = clientData.map { $0.averagePaymentTime }.reduce(0, +) / Double(clientData.count)
        
        VStack {
            Chart {
                ForEach(clientData) { data in
                    BarMark(
                        x: .value("Client", data.clientName),
                        y: .value("Temps moyen de paiement (jours)", data.averagePaymentTime)
                    )
                    .foregroundStyle(.blue)
                }
                
                RuleMark(y: .value("Moyenne", averageTime))
                    .foregroundStyle(.green)
                    .annotation(position: .top, alignment: .leading) {
                        Text("Moyenne: \(averageTime, specifier: "%.1f") jours")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 5)
            .frame(height: 300)
        }
        .padding()
    }
}

struct ClientPaymentData: Identifiable {
    let id = UUID()
    let clientName: String
    let averagePaymentTime: Double // in days
}

func calculateClientPaymentData(clients: [Client]) -> [ClientPaymentData] {
    var clientData = [ClientPaymentData]()
    
    for client in clients {
        let documents = client.listDocuments
        var totalPaymentTime: Double = 0
        var totalPaidDocuments: Int = 0
        
        for document in documents {
            for paiement in document.listPayements {
                let paymentTime = paiement.date.timeIntervalSince(document.dateEmission) / (60 * 60 * 24) // in days
                totalPaymentTime += paymentTime
                totalPaidDocuments += 1
            }
        }
        
        if totalPaidDocuments > 0 {
            let averagePaymentTime = totalPaymentTime / Double(totalPaidDocuments)
            clientData.append(ClientPaymentData(clientName: client.lastname, averagePaymentTime: averagePaymentTime))
        }
    }
    
    return clientData
}


#Preview {
    ClientPaymentEstimateGraphView()
}
