//
//  ClientPaymentEstimateGraphView.swift
//  Bordero
//
//  Created by Grande Variable on 17/05/2024.
//

import SwiftUI
import Charts
import CoreData

struct ClientPaymentEstimateGraphView: View {
    @FetchRequest(sortDescriptors: [])
    private var clients: FetchedResults<Client>
    var selectedPeriod: PeriodStats = .week
    
    private var clientData :  [ClientPaymentData] {
        calculateClientPaymentData(
            clients: Array(clients),
            period: selectedPeriod
        )
    }
    
    var body: some View {
        GroupBox {
            CombinedChartView(clientData: clientData)
        } label: {
            Text("Temps de paiement moyen")
                .font(.title2)
                .fontWeight(.medium)
        }
        .groupBoxStyle(PlainGroupBoxStyle())
        
    }
}

struct CombinedChartView: View {
    let clientData: [ClientPaymentData]
    
    private var averageTime : Double? {
        clientData.isEmpty
        ? nil
        : clientData.map(\.averagePaymentTime).reduce(0, +) / Double(clientData.count)
    }
    
    var body: some View {
        VStack {
            Chart {
                ForEach(clientData) { data in
                    BarMark(
                        x: .value("Client", data.clientName),
                        y: .value("Temps moyen de paiement (jours)", data.averagePaymentTime)
                    )
                    .foregroundStyle(.blue)
                }
                
                if let averageTime {
                    RuleMark(y: .value("Moyenne", averageTime))
                        .foregroundStyle(.green)
                        .annotation(position: .top, alignment: .leading) {
                            Text("Moyenne: \(averageTime, specifier: "%.1f") jours")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 5)
            .chartYScale(domain: 0...maximumPaymentTime)
        }
        .frame(minHeight: 220)
        .padding()
    }
    
    private var maximumPaymentTime: Double {
        max(clientData.map(\.averagePaymentTime).max() ?? 0, 1)
    }
}

struct ClientPaymentData: Identifiable {
    let id = UUID()
    let clientName: String
    let averagePaymentTime: Double // in days
}

func calculateClientPaymentData(
    clients: [Client],
    period: PeriodStats,
    now: Date = .now,
    calendar: Calendar = .current
) -> [ClientPaymentData] {
    let component: Calendar.Component = switch period {
    case .week: .weekOfYear
    case .month: .month
    case .year: .year
    }
    let interval = calendar.dateInterval(of: component, for: now)
    ?? DateInterval(start: now, duration: 0)
    var clientData = [ClientPaymentData]()
    
    for client in clients {
        let documents = client.listDocuments
        var totalPaymentTime: Double = 0
        var totalPaidDocuments: Int = 0
        
        for document in documents {
            for paiement in document.listPayements where interval.contains(paiement.date) {
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
    ClientPaymentEstimateGraphView(selectedPeriod: .month)
}
