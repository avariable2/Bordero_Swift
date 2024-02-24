//
//  HomeView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI
import ScrollableGradientBackground

struct HomeView: View {
    
    var body: some View {
        ScrollableGradientBackgroundCustomView(
            heightPercentage: 0.4,
            maxHeight: 200,
            minHeight: 0,
            startColor: Color.green,
            endColor: Color.clear,
            navigationTitle: "Résumé",
            content: {
                BandeauCreateDocument()
                VStack(alignment: .leading) {
                    Text("Statistiques")
                        .font(.title2)
                        .bold()
                    
                    StatistiquePaticientView()
                }
            }
        )
    }
}

#Preview {
    HomeView()
}

