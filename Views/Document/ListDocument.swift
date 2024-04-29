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
    
    var fileteredListDocuments : [Document] {
//        guard !searchText.isEmpty else { return Array(documents) }
        
        var documentTrier = Array(documents)
        
        switch documentScope {
        case .all, .unknow:
            break
        case .created:
            documentTrier = documents.filter { $0.status == .created }
        case .payed:
            documentTrier = documents.filter { $0.status == .payed }
        case .send:
            documentTrier = documents.filter { $0.status == .send }
        }
        
        if !searchText.isEmpty {
            documentTrier = documentTrier.filter { document in
                document.getNameOfDocument().lowercased().contains(searchText.lowercased())
            }
        }
        
        return documentTrier
    }
    
    var body: some View {
        VStack {
            Picker(selection: $documentScope) {
                Text(Document.Status.all.rawValue).tag(Document.Status.all)
                Text(Document.Status.created.rawValue).tag(Document.Status.created)
                Text(Document.Status.payed.rawValue).tag(Document.Status.payed)
                Text(Document.Status.send.rawValue).tag(Document.Status.send)
            } label: {
                Text("Trie des documents")
            }
            .pickerStyle(.segmented)
            .padding([.trailing, .leading])
            
            if documents.isEmpty {
                ContentUnavailableView(
                    "Aucun document",
                    systemImage: "folder.badge.questionmark",
                    description: Text("Les documents créer apparaitront ici.").foregroundStyle(.secondary)
                )
            } else {
                List {
                    if fileteredListDocuments.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        ForEach(fileteredListDocuments, id: \.self) { document in
                            Section {
                                RowDocumentView(document: document)
                                    .tag(document.status)
                                    .background(
                                        NavigationLink("") {
                                            DocumentDetailView(document: document)
                                        }.opacity(0)
                                    )
                            } header: {
                                Text(document.sectionTitleByDate)
                            }
                        }
                    }
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            }
        }
        .navigationTitle("Documents")
    }
}

struct RowDocumentView :View {
    
    @ObservedObject var document : Document
    
    var body: some View {
        
        HStack {
            Image(systemName: "doc.circle.fill")
                .imageScale(.large)
                .foregroundStyle(.white, .blue)
            
            VStack {
                HStack {
                    Text(document.getNameOfDocument())
                    
                    Spacer()
                    
                    Text(document.totalTTC, format: .currency(code: "EUR"))
                        
                }
                .fontWeight(.medium)
                
                HStack {
                    
                    Text("Crée le: ")
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
    }
}

#Preview {
    ListDocument()
}
