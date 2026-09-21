//
//  PerformanceClientsGraphView.swift
//  Bordero
//
//  Created by Grande Variable on 15/05/2024.
//

import SwiftUI
import Charts
import CoreData

struct PerformanceClientsGraphView: View {
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Paiement.date_, ascending: true)
        ]
    ) private var payments: FetchedResults<Paiement>
    
    var selectedPeriod: PeriodStats = .week
    
    private var clientRevenues: [ClientRevenue] {
        calculateClientRevenues(
            payments: Array(payments),
            period: selectedPeriod
        )
    }
    
    private var maximumRevenue : Double {
        max(clientRevenues.map(\.revenue).max() ?? 0, 1)
    }
    
    var body: some View {
        GroupBox {
            Chart(clientRevenues.prefix(10)) { clientRevenue in
                BarMark(
                    x: .value("Client", clientRevenue.clientName),
                    y: .value("Revenu", clientRevenue.revenue)
                )
                .foregroundStyle(.purple)
            }
            .chartYScale(domain: 0...maximumRevenue)
            .frame(minHeight: 220)
            .padding()
        } label: {
             Text("Répartition paiement récent")
        }
        .groupBoxStyle(PlainGroupBoxStyle())
    }
    
    private func calculateClientRevenues(
        payments: [Paiement],
        period: PeriodStats,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [ClientRevenue] {
        let component: Calendar.Component = switch period {
        case .week: .weekOfYear
        case .month: .month
        case .year: .year
        }
        let interval = calendar.dateInterval(of: component, for: now)
            ?? DateInterval(start: now, duration: 0)
        var revenueByClient: [String: Double] = [:]
        
        for payment in payments where interval.contains(payment.date) {
            let clientName = "\(payment.client?.firstname ?? "Inconnu") \(payment.client?.lastname ?? "")"
            revenueByClient[clientName, default: 0] += payment.montant
        }
        
        return revenueByClient.map { ClientRevenue(clientName: $0.key, revenue: $0.value) }
            .sorted { $0.revenue > $1.revenue } // Sort by revenue in descending order
    }
}

struct ClientRevenue: Identifiable {
    var id: String { clientName }
    let clientName: String
    let revenue: Double
}

#Preview {
    PerformanceClientsGraphView(selectedPeriod: .month)
}
