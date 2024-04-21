//
//  HistoriqueTabDetailView.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI
import CoreData

struct HistoriqueTabDetailView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest var historique: FetchedResults<HistoriqueEvenement>
    
    init(document: Document) {
        let request: NSFetchRequest<HistoriqueEvenement> = HistoriqueEvenement.fetchRequest()
        request.predicate = NSPredicate(format: "correspond == %@",
                                        argumentArray: [document])
        _historique = FetchRequest<HistoriqueEvenement>(fetchRequest: request, animation: .default)
    }
    
    var body: some View {
        List {
            ForEach(historique) { evenement in
                RowHistorique(evenement: evenement)
            }
        }
    }
}

struct RowHistorique : View {
    let evenement : HistoriqueEvenement
    
    private var color : Color {
        switch evenement.nom {
        case Evenement.TypeEvenement.création.rawValue:
            .yellow
        case Evenement.TypeEvenement.modification.rawValue:
            .red
        case Evenement.TypeEvenement.envoie.rawValue,
            Evenement.TypeEvenement.exporté.rawValue:
            .blue
        case Evenement.TypeEvenement.renvoie.rawValue:
            .indigo
        case Evenement.TypeEvenement.payer.rawValue:
            .pink
        default: .gray
        }
    }
    
    private var image : String {
        switch evenement.nom {
        case Evenement.TypeEvenement.création.rawValue:
            "doc.badge.plus"
        case Evenement.TypeEvenement.modification.rawValue:
            "doc.badge.ellipsis"
        case Evenement.TypeEvenement.envoie.rawValue:
            "paperplane"
        case Evenement.TypeEvenement.renvoie.rawValue:
            "arrowshape.turn.up.right"
        case Evenement.TypeEvenement.payer.rawValue:
            "bag.badge.plus"
        case Evenement.TypeEvenement.exporté.rawValue:
            "square.and.arrow.up"
        default:
            "doc"
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .symbolRenderingMode(.palette)
                .foregroundStyle(color, .gray)
                .imageScale(.large)
            
            VStack(alignment: .leading) {
                Text(evenement.nom.capitalized)
                    .foregroundStyle(.primary)
                
                Text(evenement.date, format: .dateTime)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

//#Preview {
//    HistoriqueTabDetailView(historique: [Evenement(nom: .création, date: Date())])
//}
