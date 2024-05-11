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
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .cornerRadius(5)
                    .foregroundStyle(by: .value("Product category", dataItem.name))
                    .annotation(position: .overlay, alignment: .center) {
                        if dataItem.value != 0 {
                            Text("\(dataItem.annotation, format: .currency(code: "EUR"))")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                    }
                    .accessibilityLabel(dataItem.name)
                    .accessibilityValue("\(dataItem.annotation) euros")
                }
                .chartLegend(position: .bottom, spacing: 20)
                .frame(height: 350)
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
            let range = ClientDataUtils.getSixMonthPeriodRange()
            return client.listDocuments.filter { doc in
                doc.dateEmission >= range.start && doc.dateEmission <= range.end
            }
        case .annee:
            return client.listDocuments.filter { doc in
                Calendar.current.isDate(doc.dateEmission, equalTo: Date(), toGranularity: .year)
            }
        }
    }
    
    func getResteAPayer(documents: Set<Document>) {
        calculateChartData(for: documents, isPaid: false, title: "Reste à payer")
    }

    func getMontantPayer(documents: Set<Document>) {
        calculateChartData(for: documents, isPaid: true, title: "Montant payé")
    }
    
    func calculateChartData(for documents: Set<Document>, isPaid: Bool, title: String) {
        let filteredDocuments = documents.filter { $0.estDeTypeFacture && $0.payementFinish == isPaid }
        
        guard !filteredDocuments.isEmpty else {
            data.append(PieChartData(name: title, value: 0, annotation: 0))
            return
        }
        
        let totalTTC = filteredDocuments.reduce(0) { $0 + $1.totalTTC }
        
        data.append(
            PieChartData(
                name: title,
                value: Double(filteredDocuments.count) / Double(documents.count),
                annotation: totalTTC
            )
        )
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
            let range = ClientDataUtils.getSixMonthPeriodRange()
            return "\(range.start.formatted(.dateTime.day().month()))-\(range.end.formatted(.dateTime.day().month().year()))"
        case .annee:
            return Date().formatted(.dateTime.year())
        }
    }
}

struct PieChartData : Identifiable, Equatable {
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
