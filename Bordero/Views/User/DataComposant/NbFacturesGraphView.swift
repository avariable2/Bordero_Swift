//
//  NbFacturesGraphView.swift
//  Bordero
//
//  Created by Grande Variable on 15/05/2024.
//

import SwiftUI
import Charts

struct NbFacturesGraphView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \Document.dateEmission_, ascending: true)
    ]) var documents : FetchedResults<Document>
    
    @State private var selectedPeriod: String = "Month"
    
    var body: some View {
        VStack {
            Picker("Select Period", selection: $selectedPeriod) {
                Text("Day").tag("Day")
                Text("Week").tag("Week")
                Text("Month").tag("Month")
                Text("Year").tag("Year")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Chart(chartData(for: selectedPeriod)) { element in
                BarMark(
                    x: .value("Period", element.period),
                    y: .value("Count", element.count)
                )
                .foregroundStyle(by: .value("Status", element.status.rawValue))
            }
            .padding()
        }
    }
    
    func chartData(for period: String) -> [DocumentChartData] {
        var groupedData: [String: [Document]] = [:]
        
        // Grouper les documents par période
        for document in documents {
            let periodKey = getPeriodKey(for: document.dateEmission, period: period)
            if groupedData[periodKey] == nil {
                groupedData[periodKey] = []
            }
            groupedData[periodKey]?.append(document)
        }
        
        // Créer les données pour les graphiques
        var chartData: [DocumentChartData] = []
        for (period, docs) in groupedData {
            let payeCount = docs.filter { $0.status == .payed }.count
            let envoyerCount = docs.filter { $0.status == .send && $0.dateEcheance <= Date() }.count
            let enRetardCount = docs.filter { $0.status == .send && $0.dateEcheance <= Date() }.count
            
            if payeCount > 0 {
                chartData.append(DocumentChartData(period: period, status: DocumentStatus.paye, count: payeCount))
            }
            if envoyerCount > 0 {
                chartData.append(DocumentChartData(period: period, status: DocumentStatus.enRetard, count: envoyerCount))
            }
            if enRetardCount > 0 {
                chartData.append(DocumentChartData(period: period, status: DocumentStatus.enRetard, count: enRetardCount))
            }
        }
        
        return chartData
    }
    
    func getPeriodKey(for date: Date, period: String) -> String {
            let dateFormatter = DateFormatter()
            switch period {
            case "Day":
                dateFormatter.dateFormat = "dd MMM yyyy"
            case "Week":
                let weekOfYear = Calendar.current.component(.weekOfYear, from: date)
                let year = Calendar.current.component(.year, from: date)
                return "Week \(weekOfYear), \(year)"
            case "Month":
                dateFormatter.dateFormat = "MMM yyyy"
            case "Year":
                dateFormatter.dateFormat = "yyyy"
            default:
                dateFormatter.dateFormat = "MMM yyyy"
            }
            return dateFormatter.string(from: date)
        }
}

enum DocumentStatus: String, CaseIterable {
    case paye = "Payé"
    case envoyer = "En attente"
    case enRetard = "En Retard"
}

struct DocumentChartData: Identifiable {
    let id = UUID()
    let period: String
    let status: DocumentStatus
    let count: Int
}

#Preview {
    NbFacturesGraphView()
}
