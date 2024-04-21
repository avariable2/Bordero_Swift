//
//  ListDocument.swift
//  Bordero
//
//  Created by Grande Variable on 21/04/2024.
//

import SwiftUI
import CoreData

struct ListDocument: View {
    
    @State var sortDescriptor = NSSortDescriptor(keyPath: \Document.dateEmission_, ascending: true)
    @State private var sortType : Int = 0
    
    var body: some View {
        VStack {
            Picker(selection: $sortType) {
                Text("Tous").tag(0)
                Text("Ouvert").tag(1)
                Text("Payer").tag(2)
            } label: {
                Text("Trie des documents")
            }
            .onChange(of: sortType) { oldValue, newValue in
                sortType = newValue
                switch newValue {
                case 1:
                    sortDescriptor = NSSortDescriptor(keyPath: \Document.status_, ascending: true)
                default:
                    sortDescriptor = NSSortDescriptor(keyPath: \Document.dateEmission_, ascending: true)
                }
            }
            .pickerStyle(.segmented)
            .padding([.trailing, .leading])
            
            DisplayListWithSort(sortDescriptor: sortDescriptor)
        }
        .navigationTitle("Documents")
    }
}

struct DisplayListWithSort : View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest var documents: FetchedResults<Document>
    
    init(sortDescriptor : NSSortDescriptor) {
        let request: NSFetchRequest<Document> = Document.fetchRequest()
        let sortByDate = NSSortDescriptor(keyPath: \Document.dateEmission_, ascending: false)
        request.sortDescriptors = [ sortByDate, sortDescriptor]
        _documents = FetchRequest<Document>(fetchRequest: request, animation: .default)
    }
    
    var body: some View {
        
        if documents.isEmpty {
            ContentUnavailableView(
                "Aucun document",
                systemImage: "folder.badge.questionmark",
                description: Text("Les documents créer apparaitront ici.").foregroundStyle(.secondary)
            )
        } else {
            List {
                ForEach(documents, id: \.id_) { document in
                    Section {
                        let nomFichier = "\(document.snapshotClient.firstname) \(document.snapshotClient.lastname) \(document.estDeTypeFacture ? "Facture" : "Devis")"
                        RowDocumentView(
                            titre: nomFichier,
                            date: document.dateEmission,
                            montantTot: document.totalTTC,
                            etat: "Ouvert"
                        )
                    } header: {
                        Text(document.sectionTitleByDate)
                    }
                }
            }
        }
    }
}

struct RowDocumentView :View {
    let titre : String
    let date : Date
    let montantTot : Double
    let etat : String
    
    var body: some View {
        Label {
            VStack {
                
                HStack {
                    Text(titre)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(montantTot, format: .currency(code: "EUR"))
                        .fontWeight(.semibold)
                }
                
                HStack {
                    
                    Text("Crée le: ")
                        .foregroundStyle(.secondary)
                    +
                    Text(date, format: .dateTime.day().month().year())
                        .foregroundStyle(.secondary)
                        
                    
                    Spacer()
                    
                    Label {
                        Text(etat)
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "circle.circle.fill")
                            .foregroundStyle(.black, .yellow)
                    }
                }
                .font(.footnote)
                
            }
        } icon: {
            Image(systemName: "doc.circle.fill")
                .imageScale(.large)
                .foregroundStyle(.white, .blue)
        }
        
    }
}

#Preview {
    ListDocument()
}
