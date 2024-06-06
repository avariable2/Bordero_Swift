//
//  ListDocument.swift
//  Bordero
//
//  Created by Grande Variable on 21/04/2024.
//

import SwiftUI
import CoreData

struct ListDocument: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest var documents: FetchedResults<Document>
    @State private var searchText = ""
    @State private var documentScope : Document.Status = .all
    
    init() {
        let request: NSFetchRequest<Document> = Document.fetchRequest()
        let sortByDate = NSSortDescriptor(keyPath: \Document.dateEmission_, ascending: false)
        request.sortDescriptors = [ sortByDate]
        _documents = FetchRequest<Document>(fetchRequest: request, animation: .default)
    }
    
    let sectionOrder = [
        "Aujourd'hui",
        "Hier",
        "Cette semaine",
        "Ce mois",
        "Le mois dernier",
        "6 derniers mois",
        "Cette année",
        "Années précédentes"
    ]
    
    // Filtered and grouped documents
        var filteredListDocuments: Dictionary<String, [Document]> {
            // Determine the filtered documents based on scope
            let filteredDocuments: [Document]
            switch documentScope {
            case .created:
                filteredDocuments = documents.filter { $0.status == .created }
            case .payed:
                filteredDocuments = documents.filter { $0.status == .payed }
            case .send:
                filteredDocuments = documents.filter { $0.status == .send }
            case .all, .unknow:
                filteredDocuments = Array(documents)
            }

            // Filter based on search text if necessary
            let documentsToGroup = searchText.isEmpty
                ? filteredDocuments
                : filteredDocuments.filter {
                    $0.getNameOfDocument().lowercased().contains(searchText.lowercased())
                }

            // Group documents by section title by date
            return Dictionary(grouping: documentsToGroup) { document in
                document.sectionTitleByDate
            }
        }
    
    var body: some View {
        VStack {
            Picker(selection: $documentScope) {
                Text(Document.Status.all.rawValue).tag(Document.Status.all)
                Text(Document.Status.created.rawValue).tag(Document.Status.created)
                Text(Document.Status.payed.rawValue).tag(Document.Status.payed)
                Text(Document.Status.send.rawValue).tag(Document.Status.send)
            } label: {
                Text("Tri des documents")
            }
            .pickerStyle(.segmented)
            .padding([.trailing, .leading])
            
            if documents.isEmpty {
                ContentUnavailableView(
                    "Aucun document",
                    systemImage: "folder.badge.questionmark",
                    description: Text("Les documents créés apparaîtront ici.").foregroundStyle(.secondary)
                )
            } else {
                List {
                    if filteredListDocuments.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        ForEach(sectionOrder, id: \.self) { key in
                                                   if let documentsForSection = filteredListDocuments[key] {
                                                       Section(header: Text(key)) {
                                                           ForEach(documentsForSection, id: \.self) { document in
                                                               RowDocumentView(document: document)
                                                                   .tag(document.status)
                                                           }
                                                       }
                                                   }
                                               }
                    }
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            }
        }
        .navigationTitle("Documents")
        .trackEventOnAppear(event: .documentListBrowsed, category: .documentManagement)
    }
}

struct RowDocumentView :View {
    
    @ObservedObject var document : Document
    
    var body: some View {
        
        HStack {
            Image(systemName: "doc.circle.fill")
                .imageScale(.large)
                .foregroundStyle(.white, .blue)
            
            VStack(spacing: 6) {
                HStack {
                    Text(document.getNameOfDocument())
                    
                    Spacer()
                    
                    Text(document.totalTTC, format: .currency(code: "EUR"))
                        
                }
                .fontWeight(.medium)
                
                HStack {
                    
                    Text("Créé le: ")
                        .foregroundStyle(.secondary)
                    +
                    Text(document.dateEmission, format: .dateTime.day().month().year())
                        .foregroundStyle(.secondary)
                        
                    
                    Spacer()
                    
                    HStack(spacing: nil) {
                        Image(systemName: "circle.circle.fill")
                            .foregroundStyle(.black, document.determineColor())
                        
                        Text(document.determineStatut())
                            .foregroundStyle(.primary)
                            .fontWeight(.light)
                    }
                }
                .font(.footnote)
            }
        }
        .background(
            NavigationLink("") {
                DocumentDetailView(document: document)
            }.opacity(0)
        )
    }
}

#Preview {
    ListDocument()
}
