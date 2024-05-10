//
//  ClientDataView.swift
//  Bordero
//
//  Created by Grande Variable on 06/05/2024.
//

import SwiftUI
import Charts

struct ClientDataView: View {
    enum TempoChart : String, CaseIterable, Identifiable, Codable {
        case semaine = "Semaine"
        case mois = "Mois"
        case sixMois = "6 mois"
        case annee = "Année"
        
        var id: Self { self }
    }
    
    @State var client : Client
    @State var data : [PieChartData] = []
    @State var temporalite : TempoChart = .mois
    
    var body: some View {
        Form {
            Section {
                Picker("Temporalité", selection: $temporalite.animation()) {
                    ForEach(TempoChart.allCases) { type in
                        Text(type.rawValue)
                            .font(.title)
                    }
                }
                .pickerStyle(.segmented)
                
                if data.isEmpty {
                    ContentUnavailableView("Aucun donnée", systemImage: "chart.pie", description: Text("Vous retrouverez ici l'ensemble des données d'un client (exemple : reste à payer, ...)"))
                } else {
                    Text(Date().formatted(.dateTime.month().year()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
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
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden, edges: .bottom)
            .listRowInsets(.none)
            .listRowSpacing(.none)
            
            Section {
                Text("Informations")
            }
        }
        .navigationTitle("Données du client")
        .navigationBarTitleDisplayMode(.inline)
        .contentMargins(.top, 0)
        .onAppear() {
            getData()
        }
    }
    
    func getData() {
        let documentsDuMois = client.listDocuments.filter { doc in
            doc.dateEmission.formatted(.dateTime.month()) == Date().formatted(.dateTime.month())
        }
        
        getResteAPayer(documents: documentsDuMois)
        getMontantPayer(documents: documentsDuMois)
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
        let documentsPayerDuMois = documents.filter { $0.estDeTypeFacture && $0.payementFinish == true }
        guard documents.count > 0 else { return }
        
        let pourcentageSur100 : Double = Double(documentsPayerDuMois.count / documents.count)
        
        if documentsPayerDuMois.count == 0 {
            data.append(PieChartData(name: "Montant payer", value: pourcentageSur100, annotation: 0))
            return
        }
        
        var restePayer : Double = 0
        for doc in documentsPayerDuMois {
            restePayer += doc.montantPayer
        }
        
        
        data.append(PieChartData(name: "Montant payer", value: pourcentageSur100, annotation: restePayer))
    }
    
    func getOverdueDocument() {
        
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
    VStack {
        ClientDataView(client: Client.example)
    }
    
}
