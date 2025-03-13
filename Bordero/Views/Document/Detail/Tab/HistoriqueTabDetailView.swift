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
        let sortByDate = NSSortDescriptor(keyPath: \HistoriqueEvenement.date_, ascending: false)
        request.sortDescriptors = [ sortByDate]
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
            .orange
        case Evenement.TypeEvenement.modification.rawValue:
            .brown
        case Evenement.TypeEvenement.envoie.rawValue,
            Evenement.TypeEvenement.exporté.rawValue:
            .blue
        case Evenement.TypeEvenement.renvoie.rawValue:
            .indigo
        case Evenement.TypeEvenement.payer.rawValue:
            .green
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
            "doc.badge.arrow.up"
        case Evenement.TypeEvenement.renvoie.rawValue:
            "doc.badge.arrow.up"
        case Evenement.TypeEvenement.payer.rawValue:
            "eurosign.arrow.circlepath"
        case Evenement.TypeEvenement.exporté.rawValue:
            "arrow.up.doc"
        default:
            "doc"
        }
    }
    
    var body: some View {
        
        Label {
            LabeledContent {
                Text(evenement.date, format: .dateTime)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } label: {
                Text(evenement.nom.capitalized)
                    .foregroundStyle(.primary)
            }
        } icon: {
            Image(systemName: image)
                .symbolRenderingMode(.palette)
                .foregroundStyle(color, .gray)
                .imageScale(.large)
        }
    }
}

//#Preview {
//    HistoriqueTabDetailView(historique: [Evenement(nom: .création, date: Date())])
//}
