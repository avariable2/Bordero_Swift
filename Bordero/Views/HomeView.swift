//
//  HomeView.swift
//  Bordero
//
//  Created by Grande Variable on 17/09/2026.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    
    private var columns: [GridItem] {
        let count = horizontalSizeClass == .compact ? 1 : 2
        
        return Array(
            repeating: GridItem(
                .flexible(),
                spacing: 20,
                alignment: .center
            ),
            count: count
        )
    }
    
    @State private var periodStatSelected = PeriodStats.week

    private var selectedPeriodTitle: String {
        let now = Date.now
        let calendar = Calendar.current
        let component: Calendar.Component = switch periodStatSelected {
        case .week: .weekOfYear
        case .month: .month
        case .year: .year
        }

        guard let interval = calendar.dateInterval(of: component, for: now) else {
            return now.formatted(date: .abbreviated, time: .omitted)
        }

        let endDate = interval.end.addingTimeInterval(-1)
        return (interval.start..<endDate).formatted(date: .abbreviated, time: .omitted)
    }
    
    var body: some View {
        List {
            Section(selectedPeriodTitle) {
                LazyVGrid(columns: columns, spacing: 20) {
                    FacturesStatutView(
                        selectedPeriod: periodStatSelected
                    )
                    
                    GridTotalStatsView(
                        selectedPeriod: periodStatSelected
                    )
                    
                    ListHistoriquesPaiements()
                    
                    PerformanceClientsGraphView()
                    
                    ClientPaymentEstimateGraphView()
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            
            ListHistoriquesPaiements()
        }
        .headerProminence(.increased)
        .navigationTitle("Accueil")
        .toolbar {
            ToolbarItemGroup {
                ForEach(PeriodStats.allCases, id: \.self) { period in
                    Button(period.rawValue.capitalized) {
                        periodStatSelected = period
                    }
                    .foregroundStyle(periodStatSelected == period ? .purple : .primary)
                }
            }
        }

    }
}

#if DEBUG
#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(\.managedObjectContext, PreviewDataController.empty.context)
}
#endif
