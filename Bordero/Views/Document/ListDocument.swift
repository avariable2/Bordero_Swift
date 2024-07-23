//
//  ListDocument.swift
//  Bordero
//
//  Created by Grande Variable on 21/04/2024.
//

import SwiftUI
import CoreData

private struct TokenDocumentModel: Identifiable, Hashable, Equatable {
    enum TokenDocumentType {
        case client
        case date
        case typeDoc
    }
    
    var id = UUID()
    var value : String
    var type : TokenDocumentType
}

struct ListDocument: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest var documents: FetchedResults<Document>
    @State private var searchText = ""
    @State private var tags: [TokenDocumentModel] = []
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
        
        // Filter based on tokens
        let tokens = tags.map { $0.value }.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let documentsToGroup: [Document]
        if tokens.isEmpty {
            documentsToGroup = filteredDocuments
        } else {
            documentsToGroup = filteredDocuments.filter { document in
                tokens.allSatisfy { term in
                    let matchesClient = document.client_?.fullname.lowercased().contains(term.lowercased()) ?? false
                    let matchesDate = document.dateEmission.formatted(.dateTime.month().year()).lowercased().contains(term.lowercased())
                    let matchesType = (term == "Factures" && document.estDeTypeFacture) || (term == "Devis" && !document.estDeTypeFacture)
                    
                    switch term {
                    case _ where term == "Factures" || term == "Devis":
                        return matchesType
                    default:
                        return matchesClient || matchesDate
                    }
                }
            }
        }
        
        // Group documents by section title by date
        return Dictionary(grouping: documentsToGroup) { document in
            document.sectionTitleByDate
        }
    }
    
    var suggestedClients : [String] {
        let clients = documents.map { $0.client_ }
        let uniqueClients = Set(clients.map { "\($0?.firstname ?? "") \($0?.lastname ?? "Inconnu")"})
        return uniqueClients.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    var suggestedDates: [String] {
        let dates = documents.map { $0.dateEmission }
        let uniqueDates = Set(dates.map { $0.formatted(.dateTime.month().year()) })
        return uniqueDates.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    var suggestedTypeDocs : [String] {
        let uniqueType = ["Factures", "Devis"]
        return uniqueType.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    
    // Pré-calcul pour réduire le besoin de vérification conditionnelle de rendu
    var filteredSuggestionsTypeDocs: [String] {
        let uniqueType = ["Factures", "Devis"]
        return uniqueType.filter { type in
            !tags.contains(where: { $0.value == type && $0.type == .typeDoc }) && type.lowercased().contains(searchText.lowercased())
        }
    }
    
    var filteredSuggestionsClients: [String] {
        suggestedClients.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    var filteredSuggestionsDates: [String] {
        suggestedDates.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        VStack {
            
            if documents.isEmpty {
                ContentUnavailableView(
                    "Aucun document",
                    systemImage: "folder.badge.questionmark",
                    description: Text("Les documents créés apparaîtront ici.").foregroundStyle(.secondary)
                )
            } else {
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
                
                List {
                    
                    Section("Répartition documents sur le mois") {
                        NbFacturesGraphView(showPicker: false)
                        
                        NavigationLink {
                            PraticienDataView()
                        } label: {
                            Text("Voir plus")
                                .foregroundStyle(.link)
                        }
                    }
                    
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
                .searchable(
                    text: $searchText,
                    tokens: $tags,
                    placement: .navigationBarDrawer(displayMode: .always),
                    token: { token in
                        switch token.type {
                        case .client:
                            Label(token.value, systemImage: "person.crop.circle")
                        case .date:
                            Label(token.value, systemImage: "calendar")
                        case .typeDoc:
                            Label(token.value, systemImage: "doc.circle")
                        }
                    }
                )
                .searchSuggestions {
                    if !filteredSuggestionsTypeDocs.isEmpty || !filteredSuggestionsClients.isEmpty || !filteredSuggestionsDates.isEmpty {
                        Section("Suggestions") {
                            ForEach(filteredSuggestionsTypeDocs, id: \.self) { suggestion in
                                Label {
                                    HighlightedText(text: suggestion, highlight: searchText, primaryColor: .primary, secondaryColor: .secondary)
                                } icon: {
                                    Image(systemName: "doc")
                                        .foregroundStyle(.blue)
                                        .imageScale(.large)
                                }
                                .searchCompletion(TokenDocumentModel(value: suggestion, type: .typeDoc))
                            }
                            
                            ForEach(filteredSuggestionsClients, id: \.self) { suggestion in
                                Label {
                                    HighlightedText(text: suggestion, highlight: searchText, primaryColor: .primary, secondaryColor: .secondary)
                                } icon: {
                                    Image(systemName: "person.crop.circle")
                                        .foregroundStyle(.blue)
                                        .imageScale(.large)
                                }
                                .searchCompletion(TokenDocumentModel(value: suggestion, type: .client))
                            }
                            
                            ForEach(filteredSuggestionsDates, id: \.self) { suggestion in
                                Label {
                                    HighlightedText(text: suggestion, highlight: searchText, primaryColor: .primary, secondaryColor: .secondary)
                                } icon: {
                                    Image(systemName: "calendar")
                                        .foregroundStyle(.blue)
                                        .imageScale(.large)
                                }
                                .searchCompletion(TokenDocumentModel(value: suggestion, type: .date))
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Documents")
        .trackEventOnAppear(event: .documentListBrowsed, category: .documentManagement)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    DocumentFormView()
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}

struct RowDocumentView :View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var document : Document
    
    var body: some View {
        let isLate = document.dateEcheance <= Date() && document.status == .send
        NavigationLink {
            DocumentDetailView(document: document)
        } label : {
            HStack {
                VStack(alignment: .center) {
                    Text(document.dateEmission.formatted(.dateTime.month()))
                    + Text("\n")
                    + Text(document.dateEmission.formatted(.dateTime.day()))
                }
                .foregroundStyle(isLate ? .red : .primary)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.getNameOfDocument())
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if horizontalSizeClass == .regular {
                        Text("N° : \(document.numero)")
                    }
                    
                    HStack {
                        VStack {
                            if isLate {
                                Image(systemName: "hourglass.tophalf.filled")
                                    .foregroundStyle(.pink)
                            } else {
                                viewStatus
                            }
                        }
                        
                        Divider()
                        
                        Image(systemName: "stopwatch")
                        
                        Text(document.dateEcheance.formatted(.dateTime.day().month().year()))
                        
                        Divider()
                        
                        Text(document.totalTTC, format: .currency(code: "EUR"))
                            .fontWeight(.semibold)
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
                .padding(8)
            }
            .tint(.primary)
        }
    }
    
    var viewStatus : some View {
        switch document.determineStatut() {
        case Document.Status.created.rawValue:
            Image(systemName: "doc.badge.clock.fill")
                .foregroundStyle(.orange)
        case Document.Status.payed.rawValue:
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(.green)
        case Document.Status.send.rawValue:
            Image(systemName: "checkmark.bubble.fill")
                .foregroundStyle(.blue)
        default:
            Image(systemName: "questionmark.circle.fill")
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    NavigationStack {
        List{
            RowDocumentView(document: Document.example)
        }
        
        ListDocument()
    }
}

extension Client {
    var fullname: String {
        "\(firstname) \(lastname)"
    }
}
