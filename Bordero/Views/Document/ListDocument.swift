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
    @State private var isPresentingDocumentForm = false
    
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

    private var emptyFilterTitle: String {
        switch documentScope {
        case .created:
            "Aucun document ouvert"
        case .payed:
            "Aucun document payé"
        case .send:
            "Aucun document envoyé"
        case .all, .unknow:
            "Aucun document"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("Filtrer les documents", selection: $documentScope) {
                    Text("Tous").tag(Document.Status.all)
                    Text("Ouverts").tag(Document.Status.created)
                    Text("Payés").tag(Document.Status.payed)
                    Text("Envoyés").tag(Document.Status.send)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 520)

                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            if documents.isEmpty {
                ContentUnavailableView {
                    Label("Aucun document", systemImage: "doc.badge.plus")
                } description: {
                    Text("Les documents créés apparaîtront ici.")
                } actions: {
                    Button("Créer un document", systemImage: "plus", action: createDocument)
                        .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    if !filteredListDocuments.isEmpty {
                        ForEach(sectionOrder, id: \.self) { key in
                            if let documentsForSection = filteredListDocuments[key] {
                                Section(key) {
                                    ForEach(documentsForSection, id: \.self) { document in
                                        RowDocumentView(document: document)
                                    }
                                }
                            }
                        }
                    }
                }
                .overlay {
                    if filteredListDocuments.isEmpty {
                        if !searchText.isEmpty || !tags.isEmpty {
                            ContentUnavailableView.search
                        } else {
                            ContentUnavailableView(
                                emptyFilterTitle,
                                systemImage: "line.3.horizontal.decrease.circle",
                                description: Text("Essayez un autre filtre.")
                            )
                        }
                    }
                }
                .searchable(
                    text: $searchText,
                    tokens: $tags,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text("Client, date ou type"),
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
                                    HighlightedText(text: suggestion, highlight: searchText)
                                } icon: {
                                    Image(systemName: "doc")
                                        .foregroundStyle(.blue)
                                        .imageScale(.large)
                                }
                                .searchCompletion(TokenDocumentModel(value: suggestion, type: .typeDoc))
                            }
                            
                            ForEach(filteredSuggestionsClients, id: \.self) { suggestion in
                                Label {
                                    HighlightedText(text: suggestion, highlight: searchText)
                                } icon: {
                                    Image(systemName: "person.crop.circle")
                                        .foregroundStyle(.blue)
                                        .imageScale(.large)
                                }
                                .searchCompletion(TokenDocumentModel(value: suggestion, type: .client))
                            }
                            
                            ForEach(filteredSuggestionsDates, id: \.self) { suggestion in
                                Label {
                                    HighlightedText(text: suggestion, highlight: searchText)
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Créer un document", systemImage: "plus", action: createDocument)
            }
        }
        .sheet(isPresented: $isPresentingDocumentForm) {
            DocumentFormView()
        }
        .trackEventOnAppear(event: .documentListBrowsed, category: .documentManagement)
    }

    private func createDocument() {
        isPresentingDocumentForm = true
    }
}

struct RowDocumentView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @ObservedObject var document: Document

    private var isOverdue: Bool {
        document.dateEcheance <= .now && document.status == .send
    }

    private var documentTitle: String {
        let type = document.estDeTypeFacture ? "Facture" : "Devis"
        return document.numero.isEmpty ? type : "\(type) #\(document.numero)"
    }

    private var clientName: String {
        let name = "\(document.client_?.firstname ?? "") \(document.client_?.lastname ?? "")"
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Client inconnu" : name
    }

    private var statusTitle: String {
        if isOverdue {
            return "En retard"
        }

        switch document.status {
        case .created:
            return document.estDeTypeFacture ? "Ouverte" : "Ouvert"
        case .payed:
            return document.estDeTypeFacture ? "Payée" : "Payé"
        case .send:
            return document.estDeTypeFacture ? "Envoyée" : "Envoyé"
        case .all, .unknow:
            return "Inconnu"
        }
    }

    private var statusSymbol: String {
        if isOverdue {
            return "exclamationmark.triangle.fill"
        }

        return switch document.status {
        case .created: "pencil"
        case .payed: "checkmark"
        case .send: "paperplane.fill"
        case .all, .unknow: "questionmark"
        }
    }

    private var statusColor: Color {
        if isOverdue {
            return .red
        }

        return document.determineColor()
    }

    var body: some View {
        NavigationLink {
            DocumentDetailView(document: document)
        } label: {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    DocumentRowDetails(
                        title: documentTitle,
                        clientName: clientName,
                        issueDate: document.dateEmission,
                        dueDate: document.dateEcheance,
                        showsDueDate: horizontalSizeClass == .regular
                    )

                    DocumentRowSummary(
                        amount: document.totalTTC,
                        statusTitle: statusTitle,
                        statusSymbol: statusSymbol,
                        statusColor: statusColor,
                        alignment: .leading
                    )
                }
            } else {
                HStack(alignment: .top, spacing: 12) {
                    DocumentRowDetails(
                        title: documentTitle,
                        clientName: clientName,
                        issueDate: document.dateEmission,
                        dueDate: document.dateEcheance,
                        showsDueDate: horizontalSizeClass == .regular
                    )

                    Spacer(minLength: 12)

                    DocumentRowSummary(
                        amount: document.totalTTC,
                        statusTitle: statusTitle,
                        statusSymbol: statusSymbol,
                        statusColor: statusColor,
                        alignment: .trailing
                    )
                }
            }
        }
        .foregroundStyle(.primary)
        .padding(.vertical, 4)
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
    }
}

private struct DocumentRowDetails: View {
    var title: String
    var clientName: String
    var issueDate: Date
    var dueDate: Date
    var showsDueDate: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "doc.text.fill")
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(clientName)
                    .foregroundStyle(.secondary)

                Text("Créé le \(issueDate.formatted(.dateTime.day().month().year()))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if showsDueDate {
                    Text("Échéance le \(dueDate.formatted(.dateTime.day().month().year()))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct DocumentRowSummary: View {
    var amount: Double
    var statusTitle: String
    var statusSymbol: String
    var statusColor: Color
    var alignment: HorizontalAlignment

    var body: some View {
        VStack(alignment: alignment, spacing: 8) {
            Text(amount, format: .currency(code: "EUR"))
                .font(.headline)
                .monospacedDigit()

            Label(statusTitle, systemImage: statusSymbol)
                .font(.caption)
                .bold()
                .foregroundStyle(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.12), in: Capsule())
        }
    }
}

#Preview {
    ListDocument()
}

extension Client {
    var fullname: String {
        "\(firstname) \(lastname)"
    }
}
