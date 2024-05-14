//
//  HistoriquePaiementView.swift
//  Bordero
//
//  Created by Grande Variable on 14/05/2024.
//

import SwiftUI

struct HistoriquePaiementView: View {
    @Environment(\.dismiss) var dismiss
    @FetchRequest(
        entity: Paiement.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Paiement.date_, ascending: true)]
    ) var payments: FetchedResults<Paiement>
    
    @State private var searchStart = Date()
    @State private var searchEnd = Date()
    @State private var showingSearchResults = false
    
    var filteredPaymentsByWeek: [WeeklyPaymentData] {
        let filteredPayments: [Paiement]
        if showingSearchResults {
            filteredPayments = payments.filter { $0.date >= searchStart && $0.date <= searchEnd }
        } else {
            filteredPayments = Array(payments)
        }
        return paymentsByWeek(payments: filteredPayments)
    }
    
    var body: some View {
        VStack {
            VStack {
                DatePicker("Date de début", selection: $searchStart, displayedComponents: .date)
                DatePicker("Date de fin", selection: $searchEnd, displayedComponents: .date)
            }
            .padding()
            
            HStack {
                Button("Effacer") {
                    searchStart = Date()
                    searchEnd = Date()
                    showingSearchResults = false
                }
                
                Button("Rechercher") {
                    showingSearchResults = true
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
            }
            
            List {
                ForEach(filteredPaymentsByWeek, id: \.id) { payment in
                    Section(header: Text(payment.week)) {
                        ForEach(payment.payments) { paiement in
                            RowPaiementView(paiement: paiement)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text("Retour")
                }
            }
        }
        .navigationTitle("Historique des paiements")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WeeklyPaymentData: Identifiable {
    let id = UUID()
    let week: String
    let total: Double
    let payments: [Paiement]
}

func paymentsByWeek(payments: [Paiement]) -> [WeeklyPaymentData] {
    var paymentDictionary: [String: [Paiement]] = [:]
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "'Semaine du' MMM dd, yyyy"
    
    for payment in payments {
        let weekString = dateFormatter.string(from: payment.date.startOfWeek())
        paymentDictionary[weekString, default: []].append(payment)
    }
    
    return paymentDictionary.map { WeeklyPaymentData(week: $0.key, total: $0.value.reduce(0) { $0 + $1.montant }, payments: $0.value) }
}

extension Date {
    func startOfWeek() -> Date {
        let gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        return gregorian.date(byAdding: .day, value: 1, to: sunday)!
    }
}

#Preview {
    HistoriquePaiementView()
}
