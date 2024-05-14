//
//  PaiementGraphView.swift
//  Bordero
//
//  Created by Grande Variable on 12/05/2024.
//

import SwiftUI
import Charts

struct PaiementGraphView: View {
    @Binding var temporalite : TempoChart
    let paiements : Array<Paiement>
    
    var body: some View {
        VStack {
            let payementsData = paymentsByPeriod(payments: paiements, temporalite: temporalite)
            Chart(payementsData) { paiement in
                BarMark(
                    x: .value(temporalite.rawValue, paiement.period),
                    y: .value("Montant", paiement.montant)
                )
                .accessibilityLabel(temporalite.rawValue)
                .accessibilityValue("\(paiement.montant) euros")
                .annotation {
                    Text(paiement.montant, format: .currency(code: "EUR"))
                }
            }
            .padding()
            .chartXAxisLabel(ClientDataUtils.getTextTemporalite(temporalite: temporalite))
            .chartYAxisLabel("Total Paiement")
        }
        .frame(height: 300)
        
    }
}

struct PaymentData: Identifiable {
    var period: String
    var montant: Double
    let id = UUID()
    
    
}

func paymentsByPeriod(payments: [Paiement], temporalite : TempoChart) -> [PaymentData] {
    var paymentDictionary: [String: Double] = [:]
    let dateFormatter = DateFormatter()
    
    switch temporalite {
    case .semaine:
        dateFormatter.dateFormat = "EEEE"
        for payment in payments {
            let dayString = dateFormatter.string(from: payment.date)
            paymentDictionary[dayString, default: 0.0] += payment.montant
        }
    case .mois:
        dateFormatter.dateFormat = "dd MMMM"
        for payment in payments {
            let dayString = dateFormatter.string(from: payment.date)
            paymentDictionary[dayString, default: 0.0] += payment.montant
        }
    case .sixMois:
        dateFormatter.dateFormat = "MMMM yyyy"
        for payment in payments {
            let monthString = dateFormatter.string(from: payment.date)
            paymentDictionary[monthString, default: 0.0] += payment.montant
        }
    case .annee:
        dateFormatter.dateFormat = "MMMM"
        for payment in payments {
            let monthString = dateFormatter.string(from: payment.date)
            paymentDictionary[monthString, default: 0.0] += payment.montant
        }
    }
    
    return paymentDictionary.map { PaymentData(period: $0.key, montant: $0.value) }.sorted { $0.period < $1.period }
}

#Preview {
    PaiementGraphView(temporalite: .constant(.mois), paiements: [Paiement.example2, Paiement.example])
}
