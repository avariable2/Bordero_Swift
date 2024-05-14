//
//  HistoriquePaiementView.swift
//  Bordero
//
//  Created by Grande Variable on 14/05/2024.
//

import SwiftUI
import CoreData

struct HistoriquePaiementView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var context
    
    let client : Client
    
    @State private var payments: [Paiement] = []
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
            
            if filteredPaymentsByWeek.isEmpty {
                ContentUnavailableView("Aucun paiements", systemImage: "magnifyingglass")
            } else {
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
        }
        .onAppear(perform: fetchPayments)
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
    
    private func fetchPayments() {
        let request: NSFetchRequest<Paiement> = Paiement.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Paiement.date_, ascending: true)
        ]
        request.predicate = NSPredicate(format: "client == %@", argumentArray: [client])
        
        do {
            payments = try context.fetch(request)
        } catch {
            print("Error fetching payments: \(error)")
        }
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
    HistoriquePaiementView(client: Client.example)
}
