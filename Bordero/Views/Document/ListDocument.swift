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
    
//    @Environment(\.managedObjectContext) var moc
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Document.dateEmission_, ascending: false),
        ],
//        predicate: PraticienUtils.predicate,
        animation: .default
    ) var documents: FetchedResults<Document>
    
    @State private var searchText = ""
    @State private var tags: [TokenDocumentModel] = []
    @State private var documentScope : Document.Status = .all
    
    var filteredListDocuments: Dictionary<String, [Document]> {
        let tokens = tags.map { $0.value.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        
        // Filter documents based on scope and tokens
        let documentsToGroup = documents.filter { document in
            let isInScope: Bool
            switch documentScope {
            case .created: isInScope = document.status == .created
            case .payed: isInScope = document.status == .payed
            case .send: isInScope = document.status == .send
            default: isInScope = true
            }
            guard isInScope else { return false }
            
            // If no tokens, return the document
            guard !tokens.isEmpty else { return true }
            
            return tokens.allSatisfy { term in
                let matchesClient = document.client_?.fullname.lowercased().contains(term) ?? false
                let matchesDate = document.dateEmission.formatted(.dateTime.month().year()).lowercased().contains(term)
                let matchesType = (term == "factures" && document.estDeTypeFacture) || (term == "devis" && !document.estDeTypeFacture)
                
                if term == "factures" || term == "devis" {
                    return matchesType
                } else {
                    return matchesClient || matchesDate
                }
            }
        }
        
        // Group documents by section title by date
        return Dictionary(grouping: documentsToGroup) { document in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: document.dateEmission)
        }
    }
    
    var sortedGroupKeys: [String] {
        filteredListDocuments.keys.sorted { key1, key2 in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            if let date1 = formatter.date(from: key1), let date2 = formatter.date(from: key2) {
                return date1 > date2
            }
            return false
        }
    }
    
    var suggestedClients: [String] {
        let clients = documents.compactMap { $0.client_?.fullname }
        let uniqueClients = Set(clients).sorted()
        return uniqueClients.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    var suggestedDates: [String] {
        let dates = documents.map { $0.dateEmission.formatted(.dateTime.month().year()) }
        let uniqueDates = Set(dates).sorted()
        return uniqueDates.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
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
            List {
                Section {
                    NbFacturesGraphView(
                        documents: documents,
                        showPicker: false
                    )
                }
                
                if filteredListDocuments.isEmpty {
                    ContentUnavailableView(
                        "Aucun document",
                        systemImage: "folder.badge.questionmark",
                        description: Text("Les documents créés apparaîtront ici.").foregroundStyle(.secondary)
                    )
                } else {
                    ForEach(sortedGroupKeys, id: \.self) { key in
                        Section(header: Text(key)) {
                            ForEach(filteredListDocuments[key]!, id: \.uuid) { document in
                                RowDocumentView(
                                    horizontalSizeClass: horizontalSizeClass,
                                    document: document
                                )
                                    .tag(document.status)
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
            .searchScopes($documentScope, activation: .onSearchPresentation) {
                Text(Document.Status.all.rawValue).tag(Document.Status.all)
                Text(Document.Status.created.rawValue).tag(Document.Status.created)
                Text(Document.Status.payed.rawValue).tag(Document.Status.payed)
                Text(Document.Status.send.rawValue).tag(Document.Status.send)
            }
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
        .navigationTitle("Documents")
        .headerProminence(.increased)
        .trackEventOnAppear(event: .documentListBrowsed, category: .documentManagement)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    DocumentFormView()
                } label: {
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}

struct RowDocumentView :View {
    
    var horizontalSizeClass : UserInterfaceSizeClass?
    @ObservedObject var document : FetchedResults<Document>.Element
    
    var isLate : Bool {
        document.dateEcheance <= Date() && document.status == .send
    }
    
    var body: some View {
        NavigationLink {
            DocumentDetailView(document: document)
        } label : {
            HStack {
                VStack(alignment: .trailing) {
                    Text(document.dateEmission.formatted(.dateTime.day()))
                    + Text("\n")
                    + Text(document.dateEmission.formatted(.dateTime.month()))
                    
                }
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(4)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(document.getNameOfDocument())
                        .font(.callout)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 4) {
                        IconStatusDocument(status: document.determineStatut())
                        
                        Divider()
                            .frame(height: 10)
                        
                        Image(systemName: "stopwatch")
                        
                        Text(document.dateEcheance.formatted(.dateTime.day().month().year()))
                            .foregroundStyle(isLate ? .red : .secondary)
                        
                        Divider()
                            .frame(height: 10)
                        
                        Text(document.totalTTC, format: .currency(code: "EUR"))
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)
                    
                }
                .padding(.leading, 4)
            }
        }
    }
}

#Preview {
    NavigationStack {
        List{
            RowDocumentView(horizontalSizeClass: .regular, document: Document.example)
            RowDocumentView(horizontalSizeClass: .regular, document: Document.example)
        }
        
//        ListDocument()
    }
}

extension Client {
    var fullname: String {
        "\(firstname) \(lastname)"
    }
}
