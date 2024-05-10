//
//  GraphPiView.swift
//  Bordero
//
//  Created by Grande Variable on 10/05/2024.
//

import SwiftUI
import Charts

struct GraphPiView: View {
    
    @State var client : Client
    @State var data : [PieChartData] = []
    @Binding var temporalite : TempoChart
    @State var temporaliteText : String = Date().formatted(.dateTime.month().year())
    
    var body: some View {
        VStack {
            if data.isEmpty {
                ContentUnavailableView("Aucun donnée", systemImage: "chart.pie", description: Text("Vous retrouverez ici l'ensemble des données d'un client (exemple : reste à payer, ...)"))
            } else {
                Text(temporaliteText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                
                Chart(data, id: \.name) { dataItem in
                    SectorMark(
                        angle: .value("Type", dataItem.value),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .cornerRadius(5)
                    .foregroundStyle(by: .value("Product category", dataItem.name))
                    .annotation(position: .overlay, alignment: .center) {
                        if dataItem.value != 0 {
                            Text("\(dataItem.annotation, format: .currency(code: "EUR"))")
                                .foregroundStyle(.white)
                        }
                    }
                    .accessibilityLabel(dataItem.name)
                    .accessibilityValue("\(dataItem.annotation) euros")
                }
                .frame(height: 250)
                .padding()
            }
        }
        .onAppear() {
            getData()
        }
        .onChange(of: temporalite) { oldValue, newValue in
            getData()
        }
        
    }
    
    func getData() {
        data.removeAll()
        
        let documentsDeTravail = getListByTempo()
        temporaliteText = getTextTemporalite()
        
        guard documentsDeTravail.count > 0 else {
            return
        }
        
        getResteAPayer(documents: documentsDeTravail)
        getMontantPayer(documents: documentsDeTravail)
        
    }
    
    func getListByTempo() -> Set<Document> {
        switch temporalite {
        case .semaine:
            return client.listDocuments.filter { doc in
                Calendar.current.isDate(doc.dateEmission, equalTo: Date(), toGranularity: .weekOfYear)
            }
        case .mois:
            return client.listDocuments.filter { doc in
                Calendar.current.isDate(doc.dateEmission, equalTo: Date(), toGranularity: .month)
            }
        case .sixMois:
            let range = getSixMonthPeriodRange()
            return client.listDocuments.filter { doc in
                doc.dateEmission >= range.start && doc.dateEmission <= range.end
            }
        case .annee:
            return client.listDocuments.filter { doc in
                Calendar.current.isDate(doc.dateEmission, equalTo: Date(), toGranularity: .year)
            }
        }
    }
    
    func getResteAPayer(documents : Set<Document>) {
        let documentsAPayerDuMois = documents.filter { $0.estDeTypeFacture && $0.payementFinish == false }
        if documentsAPayerDuMois.count == 0 { return }
        
        var resteAPayer : Double = 0
        for doc in documentsAPayerDuMois {
            resteAPayer += doc.totalTTC
        }
        
        let pourcentageSur100 : Double = Double(documentsAPayerDuMois.count / documents.count)
        data.append(PieChartData(name: "Reste à payer", value: pourcentageSur100, annotation: resteAPayer))
    }
    
    func getMontantPayer(documents : Set<Document>) {
        let documentsPayer = documents.filter { $0.estDeTypeFacture && $0.payementFinish == true }
        let pourcentageSur100 : Double = Double(documentsPayer.count / documents.count)
        guard documents.count > 0 else {
            data.append(PieChartData(name: "Montant payer", value: pourcentageSur100, annotation: 0))
            return
        }
        
        
        
        var restePayer : Double = 0
        for doc in documentsPayer {
            restePayer += doc.montantPayer
        }
        
        
        data.append(PieChartData(name: "Montant payer", value: pourcentageSur100, annotation: restePayer))
    }
    
    func getTextTemporalite() -> String {
        switch temporalite {
        case .semaine:
            let calendar = Calendar.current
            let now = Date()
            
            // Calculate the start of the week
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            
            // Add 6 days to get the end of the week
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            return "\(weekStart.formatted(.dateTime.day()))-\(weekEnd.formatted(.dateTime.day())) \(now.formatted(.dateTime.month().year()))"
        case .mois:
            return Date().formatted(.dateTime.month().year())
        case .sixMois:
            let range = getSixMonthPeriodRange()
            return "\(range.start.formatted(.dateTime.day().month()))-\(range.end.formatted(.dateTime.day().month().year()))"
        case .annee:
            return Date().formatted(.dateTime.year())
        }
    }
    
    func getSixMonthPeriodRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        
        let year = calendar.component(.year, from: now)
        var startComponents = DateComponents(year: year)
        var endComponents = DateComponents(year: year, month: 7, day: 1)
        
        if month >= 1 && month <= 6 {
            // Dans les 6 premiers mois, donc de janvier à juin
            startComponents.month = 1
            endComponents.month = 7
            endComponents.day = 1
        } else {
            // Dans les 6 derniers mois, donc de juillet à décembre
            startComponents.month = 7
            endComponents.year = year + 1
            endComponents.month = 1
            endComponents.day = 1
        }
        
        let startDate = calendar.date(from: startComponents)!
        let endDate = calendar.date(from: endComponents)!
        
        return (startDate, endDate)
    }
}

struct PieChartData : Identifiable {
    let id = UUID()
    let name : String
    let value : Double
    let annotation: Double
    
    init(name: String, value: Double, annotation: Double) {
        self.name = name
        self.value = value
        self.annotation = annotation
    }
}

#Preview {
    GraphPiView(client: Client.example, temporalite: .constant(.mois))
}
