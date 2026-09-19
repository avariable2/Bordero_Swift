//
//  HomeView.swift
//  Bordero
//
//  Created by Grande Variable on 17/09/2026.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \Paiement.date_, ascending: true)
    ])
    private var payments: FetchedResults<Paiement>
    
    private var columns: [GridItem] {
        let count = horizontalSizeClass == .compact ? 1 : 2
        
        return Array(
            repeating: GridItem(
                .flexible(),
                spacing: 16,
                alignment: .top
            ),
            count: count
        )
    }
    
    var body: some View {
        List {
            LazyVGrid(columns: columns, spacing: 16) {
                FacturesStatutView()
                
                GridTotalStatsView()
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            Section {
                ListHistoriquesPaiements()
            } header : {
                HStack {
                    Text("Historique des paiements")
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("Voir plus")
                            .font(.callout)
                    }
                }
            }
        }
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem {
                Button {
                    
                } label: {
                    Label("Autres statistiques", systemImage: "chart.line.uptrend.xyaxis.circle")
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
    .environment(\.managedObjectContext, PreviewDataController.invoices.context)
}
#endif
