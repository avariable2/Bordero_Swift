//
//  HomeView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        HomeScrollableGradientBackgroundCustomView(
            heightPercentage: 0.4,
            maxHeight: 200,
            minHeight: 0,
            startColor: Color.green.opacity(0.85),
            endColor: Color(uiColor: .secondarySystemBackground),
            navigationTitle: "Résumé",
            content: {
                
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
    }
}

#Preview {
    HomeView()
}

