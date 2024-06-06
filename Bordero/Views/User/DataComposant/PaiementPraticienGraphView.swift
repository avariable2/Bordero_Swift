//
//  Statistiques .swift
//  Bordero
//
//  Created by Grande Variable on 14/05/2024.
//

import SwiftUI
import Charts

struct PaiementPraticienGraphView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \Paiement.date_, ascending: true)
    ]) var payments : FetchedResults<Paiement>
    
    @State private var selectedDateInterval: DateInterval = {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -30, to: Date())!
        let end = Date()
        return DateInterval(start: start, end: end)
    }()
    
    @State private var showSelectionBar = false
    
    var body: some View {
        let cumulativePayments = getCumulativePaiements(paiments: Array(payments), for: selectedDateInterval)
        
        VStack {
            Chart(cumulativePayments) { data in
                LineMark(
                    x: .value("Date", data.date),
                    y: .value("Montant Additionnel", data.cumulativeAmount)
                )
                .symbol(by: .value("Date", data.date))
            }
            .chartXScale(domain: selectedDateInterval.start...selectedDateInterval.end)
            .frame(height: 300)
            
            // Optionnel : Sélecteur de période
            DatePicker("Début", selection: Binding(get: {
                self.selectedDateInterval.start
            }, set: { newStart in
                self.selectedDateInterval = DateInterval(start: newStart, end: self.selectedDateInterval.end)
            }), displayedComponents: .date)
            
            DatePicker("Fin", selection: Binding(get: {
                self.selectedDateInterval.end
            }, set: { newEnd in
                self.selectedDateInterval = DateInterval(start: self.selectedDateInterval.start, end: newEnd)
            }), displayedComponents: .date)
        }
        
        .padding()
    }
    
    func getCumulativePaiements(paiments: [Paiement], for duration: DateInterval) -> [CumulativePaiementData] {
        let filteredPaiements = paiments.filter { duration.contains($0.date) }
        
        let sortedPaiements = filteredPaiements.sorted(by: { $0.date < $1.date })
        
        var cumulativeAmount : Double = 0
        var cumulativePaiements : [CumulativePaiementData] = []
        
        for payment in sortedPaiements {
            cumulativeAmount += payment.montant
            cumulativePaiements.append(CumulativePaiementData(cumulativeAmount: cumulativeAmount, date: payment.date))
        }
        
        return cumulativePaiements
    }
}

struct CumulativePaiementData : Identifiable {
    let id = UUID()
    let cumulativeAmount : Double
    let date : Date
}

#Preview {
    PaiementPraticienGraphView()
}
