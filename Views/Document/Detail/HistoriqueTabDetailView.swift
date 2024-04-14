//
//  HistoriqueTabDetailView.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI

struct HistoriqueTabDetailView: View {
    var historique : [Evenement]
    
    var body: some View {
        List {
            ForEach(historique) { evenement in
                RowHistorique(evenement: evenement)
            }
        }
    }
}

struct RowHistorique : View {
    let evenement : Evenement
    
    private var color : Color {
        switch evenement.nom {
        case .création:
            .green
        case .modification:
            .red
        case .envoie, .exporté:
            .blue
        case .renvoie:
            .indigo
        case .payer:
            .purple
        }
    }
    
    private var image : String {
        switch evenement.nom {
        case .création:
            "doc.badge.plus"
        case .modification:
            "doc.badge.ellipsis"
        case .envoie:
            "paperplane"
        case .renvoie:
            "arrowshape.turn.up.right"
        case .payer:
            "bag.badge.plus"
        case .exporté:
            "square.and.arrow.up"
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: "doc.badge.plus")
                .symbolRenderingMode(.palette)
                .foregroundStyle(color, .gray)
                .imageScale(.large)
            
            VStack(alignment: .leading) {
                Text(evenement.nom.rawValue.capitalized)
                    .foregroundStyle(.primary)
                
                Text(evenement.date, format: .dateTime)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    HistoriqueTabDetailView(historique: [Evenement(nom: .création, date: Date())])
}
