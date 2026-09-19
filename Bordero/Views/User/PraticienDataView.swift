//
//  StatistiquesPraticien.swift
//  Bordero
//
//  Created by Grande Variable on 15/05/2024.
//

import SwiftUI

struct PraticienDataView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    private var usesDashboardLayout: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    private var dashboardColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), alignment: .top),
            count: dynamicTypeSize.isAccessibilitySize ? 1 : 2
        )
    }
    
    var body: some View {
        Group {
            if usesDashboardLayout {
                ScrollView {
                    VStack(spacing: 24) {
                        LazyVGrid(columns: dashboardColumns, alignment: .leading, spacing: 24) {
                            GroupBox {
                                FacturesStatutView()
                                    .frame(minHeight: 340)
                            } label: {
                                Text("Répartition factures")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            GroupBox {
                                ClientPaymentEstimateGraphView()
                                    .frame(minHeight: 340)
                            } label: {
                                Text("Temps moyen de paiement des clients")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            GroupBox {
                                PaiementPraticienGraphView()
                            } label: {
                                Text("Revenu sur période")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            GroupBox {
                                PerformanceClientsGraphView()
                                    .frame(minHeight: 340)
                            } label: {
                                Text("Top Clients par Revenu (€)")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        GroupBox("Historique paiements") {
                            VStack(alignment: .leading, spacing: 16) {
                                ListHistoriquesPaiements()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .buttonStyle(.borderless)
                        }
                    }
                    .frame(maxWidth: 1120)
                    .padding(24)
                    .frame(maxWidth: .infinity)
                }
            } else {
                List {
                    Section("Répartition factures") {
                        FacturesStatutView()
                    }
                    
                    Section {
                        ClientPaymentEstimateGraphView()
                    } header: {
                        Text("Temps moyen de paiement des clients")
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Section("Revenu sur période") {
                        PaiementPraticienGraphView()
                    }
                    
                    Section("Top Clients par Revenu (€)") {
                        PerformanceClientsGraphView()
                    }
                    
                    Section("Historique paiements") {
                        ListHistoriquesPaiements()
                    }
                }
                .headerProminence(.increased)
            }
        }
        .trackEventOnAppear(event: .praticienDashboardShowed, category: .praticienManagement)
    }
}

#Preview {
    PraticienDataView()
}
