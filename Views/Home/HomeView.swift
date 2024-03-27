//
//  HomeView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

struct HomeView: View {
    
    @FetchRequest(sortDescriptors: []) var praticien: FetchedResults<Praticien>
    
    @State private var userHasSeenAllOnBoarding = false
    
    var showNeediCloud : Bool
    
    var body: some View {
        HomeScrollableGradientBackgroundCustomView(
            heightPercentage: 0.4,
            maxHeight: 200,
            minHeight: 0,
            startColor: Color.green.opacity(0.85),
            endColor: Color(uiColor: .secondarySystemBackground),
            navigationTitle: "Résumé",
            content: {
                
                if showNeediCloud {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Données Bordero non synchronisées")
                                .bold()
                            
                            Text("Vos données et vos documents ne sont pas synchronisées. En tant que praticien, il est important d'avoir un point de sauvegarde de vos données.")
                                .foregroundStyle(.secondary)
                            
                            Button {
                                if let url = URL(string: UIApplication.openSettingsURLString),
                                   UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text("Ouvrir Réglages")
                            }
                        }
                    } label: {
                        Text("état de la sauvegarde".uppercased())
                            .bold()
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .groupBoxStyle(CustomGroupBoxStyle())
                    .padding(.bottom)
                }
                
                BandeauCreateDocument()
                
                SectionHomeComponentView(title: "Statistiques") {
                    StatistiquePaticientView()
                }
                
                SectionHomeComponentView(title: "Articles") {
                    Grid() {
                        GridRow {
                            ArticleComponentView(
                                titre: "Les bonnes pratiques pour les factures de psychologie",
                                sousTitre: "Cette article couvre l'ensemble des bases et répond aux question de l'importance des factures.",
                                image: "ArticleImageFacture"
                            )
                            
                        }
                    }
                    
                }
            }
        )
        .onAppear {
            if praticien.isEmpty { // First time que l'utilisateur arrive sur l'ecran
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    userHasSeenAllOnBoarding = false
                }
            }
        }
        .sheet(isPresented: $userHasSeenAllOnBoarding) {
            OnBoardingView(userHasSeenAllOnBoarding: $userHasSeenAllOnBoarding)
        }
        
    }
}

#Preview {
    HomeView(showNeediCloud: true)
}

