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
    
    @State var hasInitOneTime = false
    
    var body: some View {
        VStack {
            if data.isEmpty {
                ContentUnavailableView("Aucun donnée", systemImage: "chart.pie", description: Text("Seront affichées ici la répartition des montant exigible de votre part. Revenez quand vous aurez envoyé des factures"))
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
                                .bold()
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
            if !hasInitOneTime {
                getData()
            }
        }
        .onChange(of: temporalite) { oldValue, newValue in
            getData()
        }
        
    }
    
    func getData() {
        data.removeAll()

        let documentsDeTravail = getListByTempo()
        temporaliteText = ClientDataUtils.getTextTemporalite(temporalite: temporalite)

        guard !documentsDeTravail.isEmpty else {
            return
        }

        calculateChartData(documents: documentsDeTravail)
    }

    func calculateChartData(documents: Set<Document>) {
        let currentDate = Date()
        var montantPayé: Double = 0
        var montantImpayé: Double = 0
        var montantEnAttente: Double = 0
        var countPayé = 0
        var countImpayé = 0
        var countEnAttente = 0

        for document in documents where document.estDeTypeFacture {
            switch document.status {
            case .payed:
                montantPayé += document.totalTTC
                countPayé += 1
            case .send where document.dateEcheance < currentDate:
                montantImpayé += document.totalTTC
                countImpayé += 1
            case .send where document.dateEcheance > currentDate:
                montantEnAttente += document.totalTTC
                countEnAttente += 1
            default:
                break
            }
        }

        data.append(PieChartData(name: "Montant en attente", value: countEnAttente, annotation: montantEnAttente))
        
        data.append(PieChartData(name: "Montant payé", value: countPayé, annotation: montantPayé))

        data.append(PieChartData(name: "Montant impayé", value: countImpayé, annotation: montantImpayé))

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

}

struct PieChartData : Identifiable, Equatable {
    let id = UUID()
    let name : String
    let value : Int
    let annotation: Double
    
    init(name: String, value: Int, annotation: Double) {
        self.name = name
        self.value = value
        self.annotation = annotation
    }
}

#Preview {
    GraphPiView(client: Client.example, temporalite: .constant(.mois))
}
