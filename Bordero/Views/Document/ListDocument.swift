//
//  ListDocument.swift
//  Bordero
//
//  Created by Grande Variable on 21/04/2024.
//

import SwiftUI
import CoreData

private struct DocumentSearchToken: Identifiable, Hashable {
    enum Category {
        case client
        case date
        case typeDoc
    }
    
    var id = UUID()
    var value: String
    var type: Category
}

struct ListDocument: View {
    @Environment(\.tendancesVisualTheme) private var theme
    @FetchRequest var documents: FetchedResults<Document>
    @State private var searchText = ""
    @State private var tags: [DocumentSearchToken] = []
    @State private var documentScope : Document.Status = .all
    @State private var scrollOffset: CGFloat = 0

    var selectedDocumentID: Binding<NSManagedObjectID?>?
    var onCreateDocument: () -> Void
    
    init(
        selectedDocumentID: Binding<NSManagedObjectID?>? = nil,
        onCreateDocument: @escaping () -> Void = {}
    ) {
        self.selectedDocumentID = selectedDocumentID
        self.onCreateDocument = onCreateDocument
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
        let tokens = (tags.map(\.value) + [searchText])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let documentsToGroup: [Document]
        if tokens.isEmpty {
            documentsToGroup = filteredDocuments
        } else {
            documentsToGroup = filteredDocuments.filter { document in
                tokens.allSatisfy { term in
                    let type = document.estDeTypeFacture ? "Facture" : "Devis"
                    let matchesType = type.localizedCaseInsensitiveContains(term)
                        || (term.localizedCaseInsensitiveCompare("Factures") == .orderedSame
                            && document.estDeTypeFacture)
                    return document.client_?.getFullName().localizedCaseInsensitiveContains(term) == true
                        || document.dateEmission.formatted(.dateTime.month().year()).localizedCaseInsensitiveContains(term)
                        || matchesType
                        || document.numero.localizedCaseInsensitiveContains(term)
                }
            }
        }
        
        // Group documents by section title by date
        return Dictionary(grouping: documentsToGroup) { document in
            document.sectionTitleByDate
        }
    }
    
    var suggestedClients: [String] {
        let names = documents.compactMap { $0.client_?.getFullName() }
        return Array(Set(names))
            .filter { name in
                !name.isEmpty
                    && name.localizedCaseInsensitiveContains(searchText)
                    && !tags.contains { $0.type == .client && $0.value == name }
            }
            .sorted()
    }
    
    var suggestedDates: [String] {
        let dates = documents.map { $0.dateEmission.formatted(.dateTime.month().year()) }
        return Array(Set(dates))
            .filter { date in
                date.localizedCaseInsensitiveContains(searchText)
                    && !tags.contains { $0.type == .date && $0.value == date }
            }
            .sorted()
    }
    
    var filteredSuggestionsTypeDocs: [String] {
        ["Factures", "Devis"].filter { type in
            !tags.contains(where: { $0.value == type && $0.type == .typeDoc })
                && type.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var emptyFilterTitle: String {
        switch documentScope {
        case .created:
            "Aucun brouillon"
        case .payed:
            "Aucun document payé"
        case .send:
            "Aucun document envoyé"
        case .all, .unknow:
            "Aucun document"
        }
    }

    var body: some View {
        let resolvedTheme = theme ?? .facturierOriginal
        let palette = resolvedTheme.palette

        ZStack {
            LedgerGridBackgroundView(
                theme: resolvedTheme,
                verticalOffset: scrollOffset
            )
            .ignoresSafeArea()

            List(selection: selectedDocumentID) {
                if !documents.isEmpty {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("État des documents", systemImage: "line.3.horizontal.decrease")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(palette.accent)

                            scopePicker.pickerStyle(.segmented)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemGroupedBackground))
                        .overlay {
                            Rectangle().stroke(palette.border, lineWidth: palette.borderWidth)
                        }
                        .shadow(
                            color: palette.shadowColor,
                            radius: palette.shadowRadius,
                            y: palette.shadowRadius / 2
                        )
                        .listRowInsets(
                            EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }

                ForEach(sectionOrder, id: \.self) { key in
                    if let documentsForSection = filteredListDocuments[key] {
                        Section(key) {
                            ForEach(documentsForSection, id: \.objectID) { document in
                                RowDocumentView(
                                    document: document,
                                    usesSplitSelection: selectedDocumentID != nil
                                )
                                .padding(16)
                                .background(Color(.secondarySystemGroupedBackground))
                                .overlay {
                                    Rectangle().stroke(
                                        palette.border,
                                        lineWidth: palette.borderWidth
                                    )
                                }
                                .shadow(
                                    color: palette.shadowColor,
                                    radius: palette.shadowRadius,
                                    y: palette.shadowRadius / 2
                                )
                                .tag(document.objectID)
                                .listRowInsets(
                                    EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                                )
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                    }
                }

                if filteredListDocuments.isEmpty {
                    Section {
                        if documents.isEmpty {
                            ContentUnavailableView(
                                "Aucun document",
                                systemImage: "doc.badge.plus",
                                description: Text("Les documents créés apparaîtront ici.")
                            )
                        } else if !searchText.isEmpty || !tags.isEmpty {
                            ContentUnavailableView.search
                        } else {
                            ContentUnavailableView(
                                emptyFilterTitle,
                                systemImage: "line.3.horizontal.decrease.circle",
                                description: Text("Essayez un autre filtre.")
                            )
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
//            .scrollContentBackground(.hidden)
            .onScrollGeometryChange(
                for: CGFloat.self,
                of: { geometry in
                    geometry.contentOffset.y + geometry.contentInsets.top
                },
                action: { _, offset in
                    scrollOffset = offset
                }
            )
        }
        .searchable(
            text: $searchText,
            tokens: $tags,
            placement: .toolbar,
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
            if !filteredSuggestionsTypeDocs.isEmpty || !suggestedClients.isEmpty || !suggestedDates.isEmpty {
                Section("Suggestions") {
                    ForEach(filteredSuggestionsTypeDocs, id: \.self) { suggestion in
                        Label {
                            HighlightedText(text: suggestion, highlight: searchText)
                        } icon: {
                            Image(systemName: "doc")
                                .foregroundStyle(.blue)
                                .imageScale(.large)
                        }
                        .searchCompletion(DocumentSearchToken(value: suggestion, type: .typeDoc))
                    }

                    ForEach(suggestedClients, id: \.self) { suggestion in
                        Label {
                            HighlightedText(text: suggestion, highlight: searchText)
                        } icon: {
                            Image(systemName: "person.crop.circle")
                                .foregroundStyle(.blue)
                                .imageScale(.large)
                        }
                        .searchCompletion(DocumentSearchToken(value: suggestion, type: .client))
                    }

                    ForEach(suggestedDates, id: \.self) { suggestion in
                        Label {
                            HighlightedText(text: suggestion, highlight: searchText)
                        } icon: {
                            Image(systemName: "calendar")
                                .foregroundStyle(.blue)
                                .imageScale(.large)
                        }
                        .searchCompletion(DocumentSearchToken(value: suggestion, type: .date))
                    }
                }
            }
        }
        .tint(.green)
        .navigationTitle("Documents")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Créer un document", systemImage: "plus", action: onCreateDocument)
            }
        }
        .onChange(of: visibleDocumentIDs) {
            guard let selectedDocumentID else { return }
            if let selectedID = selectedDocumentID.wrappedValue,
                visibleDocumentIDs.contains(selectedID)
            {
                return
            }
            selectedDocumentID.wrappedValue = visibleDocumentIDs.first
        }
        .trackEventOnAppear(event: .documentListBrowsed, category: .documentManagement)
    }

    private var visibleDocumentIDs: [NSManagedObjectID] {
        sectionOrder.flatMap { filteredListDocuments[$0] ?? [] }
            .map(\.objectID)
    }

    private var scopePicker: some View {
        Picker("Filtrer les documents", selection: $documentScope) {
            Text("Tous").tag(Document.Status.all)
            Text("Brouillons").tag(Document.Status.created)
            Text("Payés").tag(Document.Status.payed)
            Text("Envoyés").tag(Document.Status.send)
        }
    }
}

struct RowDocumentView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ObservedObject var document: Document
    var usesSplitSelection = false

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
            return "Brouillon"
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
        Group {
            if usesSplitSelection {
                NavigationLink(value: document.objectID) {
                    rowContent
                }
            } else {
                NavigationLink {
                    DocumentDetailView(document: document)
                } label: {
                    rowContent
                }
            }
        }
    }

    private var rowContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 4) {
                    Text(documentTitle)
                        .font(.headline)
                    amount
                }
            } else {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(documentTitle)
                            .font(.headline)
                            .fixedSize(horizontal: true, vertical: false)
                        Spacer(minLength: 0)
                        amount.fixedSize(horizontal: true, vertical: false)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(documentTitle)
                            .font(.headline)
                        amount
                    }
                }
            }

            Text(clientName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)

            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 4) {
                    issueDate
                    statusLabel
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    issueDate
                    Spacer(minLength: 4)
                    statusLabel
                }
            }
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }

    private var amount: some View {
        Text(document.totalTTC, format: .currency(code: "EUR"))
            .font(.subheadline.weight(.semibold))
            .monospacedDigit()
            .lineLimit(1)
    }

    private var issueDate: some View {
        Text(document.dateEmission, format: .dateTime.day().month(.abbreviated).year())
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private var statusLabel: some View {
        Label(statusTitle, systemImage: statusSymbol)
            .font(.caption.weight(.medium))
            .foregroundStyle(statusColor)
            .lineLimit(1)
    }
}

#Preview {
    ListDocument()
}
