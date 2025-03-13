//
//  NbFacturesGraphView.swift
//  Bordero
//
//  Created by Grande Variable on 15/05/2024.
//

import SwiftUI
import Charts

enum PeriodChart : String, CaseIterable, Identifiable {
    case jour
    case semaine
    case mois
    case annee = "Année"
    
    var id : String { self.rawValue }
}

struct NbFacturesGraphView: View {
    @Environment(\.isSearching) var isSearching
    var documents : FetchedResults<Document>
    
    @State private var selectedPeriod: PeriodChart = .mois
    @State private var tabDataChart : [DocumentChartData] = []
    
    var showPicker = true
    
    var body: some View {
        DisclosureGroup(isExpanded: .constant(isSearching ? false : true).animation()) {
            
            if showPicker {
                Picker("Selectionner la période", selection: $selectedPeriod) {
                    ForEach(PeriodChart.allCases) { period in
                        Text(period.rawValue.capitalized).tag(period)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Chart(tabDataChart) { element in
                BarMark(
                    x: .value("Période", element.period),
                    y: .value("Somme", element.count)
                )
                .foregroundStyle(by: .value("Status", element.status.rawValue))
            }
            .chartForegroundStyleScale([
                DocumentStatus.envoyer.rawValue : .blue,
                DocumentStatus.enRetard.rawValue : .red,
                DocumentStatus.paye.rawValue : .green
            ])
            .padding(.vertical)
            .task {
                tabDataChart = getChartData(for: selectedPeriod)
            }
            .onChange(of: selectedPeriod, { oldValue, newValue in
                tabDataChart = getChartData(for: selectedPeriod)
            })
            .overlay {
                if tabDataChart.isEmpty {
                    ContentUnavailableView(
                        "Aucune facture",
                        systemImage: "questionmark.circle",
                        description: Text(selectedPeriod == .jour ? "Aucune facture pour la date sélectionnée" : "Il n'y a aucun document avec le statut payé ou envoyé.")
                    )
                }
            }
            
            if !showPicker {
                NavigationLink("Toutes les stats") {
                    PraticienDataView(
                        documents: documents
                    )
                }
                .foregroundStyle(.accent)
            }
            
        } label: {
            Text(showPicker ? "Répartion documents sur période" : "Répartition mensuels")
                .bold()
        }
    }
    
    func getChartData(for period: PeriodChart) -> [DocumentChartData] {
        var groupedData: [String: [Document]] = [:]
        
        // Grouper les documents par période
        for document in documents {
            let periodKey = getPeriodKey(for: document.dateEmission, period: period)
            
            // Filtrer les factures pour ne garder que celles du mois actuel en vue "Day"
            if period == .jour {
                let currentMonth = Calendar.current.component(.month, from: Date())
                let documentMonth = Calendar.current.component(.month, from: document.dateEmission)
                if currentMonth != documentMonth {
                    continue
                }
            }
            
            if groupedData[periodKey] == nil {
                groupedData[periodKey] = []
            }
            groupedData[periodKey]?.append(document)
        }
        
        // Créer les données pour les graphiques
        var chartData: [DocumentChartData] = []
        for (period, docs) in groupedData.sorted(by: { $0.key < $1.key }) {
            let payeCount = docs.filter { $0.status == .payed }.count
            let enAttenteCount = docs.filter { $0.status == .send && $0.dateEcheance >= Date() }.count
            let enRetardCount = docs.filter { $0.status == .send && $0.dateEcheance <= Date() }.count
            
            if enAttenteCount > 0 {
                chartData.append(DocumentChartData(period: period, status: .envoyer, count: enAttenteCount))
            }
            if payeCount > 0 {
                chartData.append(DocumentChartData(period: period, status: .paye, count: payeCount))
            }
            if enRetardCount > 0 {
                chartData.append(DocumentChartData(period: period, status: .enRetard, count: enRetardCount))
            }
        }
        
        return chartData
    }
    
    func getPeriodKey(for date: Date, period: PeriodChart) -> String {
        let dateFormatter = DateFormatter()
        switch period {
        case .jour:
            dateFormatter.dateFormat = "dd MMM yyyy"
        case .semaine:
            let weekOfYear = Calendar.current.component(.weekOfYear, from: date)
            return "\(weekOfYear)"
        case .mois:
            dateFormatter.dateFormat = "MMM yyyy"
        case .annee:
            dateFormatter.dateFormat = "yyyy"
        }
        return dateFormatter.string(from: date)
    }
}

enum DocumentStatus: String, CaseIterable {
    case paye = "Payé"
    case envoyer = "Envoyée"
    case enRetard = "Retard"
}

struct DocumentChartData: Identifiable {
    let id = UUID()
    let period: String
    let status: DocumentStatus
    let count: Int
}

//#Preview {
//    NbFacturesGraphView()
//}
