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
    @State private var searchText = ""
    
    init(sortDescriptor : NSSortDescriptor, predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Document> = Document.fetchRequest()
        let sortByDate = NSSortDescriptor(keyPath: \Document.dateEmission_, ascending: false)
        request.sortDescriptors = [ sortByDate, sortDescriptor]
        _documents = FetchRequest<Document>(fetchRequest: request, animation: .default)
    }
    
    var fileteredListDocuments : [Document] {
        guard !searchText.isEmpty else { return Array(documents) }
        
        return documents.filter { document in
            document.getNameOfDocument().lowercased().contains(searchText.lowercased())
        }
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
                if fileteredListDocuments.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ForEach(fileteredListDocuments, id: \.self) { document in
                        Section {
                            RowDocumentView(document: document)
                                .background(
                                    NavigationLink("") {
                                        DocumentDetailView(document: document)
                                    }
                                        .opacity(0)
                                )
                        } header: {
                            Text(document.sectionTitleByDate)
                        }
                    }
                }
            }
            .searchable(text: $searchText)
        }
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
