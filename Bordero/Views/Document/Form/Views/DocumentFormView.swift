//
//  DocumentFormView.swift
//  Bordero
//
//  Created by Grande Variable on 08/06/2024.
//

import SwiftUI
import CoreData

struct DocumentFormView: View {
    @FetchRequest(sortDescriptors: []) var praticien: FetchedResults<Praticien>
    
    @State private var isPraticienDataSetup = false
    
    @State private var viewModel = PDFViewModel()
    var document : Document?
    var onCancel: (() -> Void)?
    
    init(document: Document? = nil, onCancel: (() -> Void)? = nil) {
        self.document = document
        self.onCancel = onCancel
    }
    
    var body: some View {
        ModifierDocumentView(viewModel: viewModel)
            .toolbar {
                if let onCancel {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Fermer", systemImage: "xmark", action: onCancel)
                    }
                }
            }
            .onAppear {
                if !isPraticienDataSetup {
                    setupViewModel()
                    isPraticienDataSetup = true
                }
            }
    }
    
    private func setupViewModel() {
        if let document = document {
            if viewModel.documentObject == nil {
                viewModel.retrieveDataFromDocument(document: document)
            }
        }
        viewModel.setupPraticienData(praticien: praticien.first)
    }
}

struct ModifierDocumentView: View {
    @State var viewModel: PDFViewModel
    @State private var activeSheet: ActiveSheet?
    @State private var estPayer: Bool = false
    @State private var selectedPayement: Payement = .carte
    @State private var typeSelected: TypeDoc = .facture
    @State private var launchSauvegarde = false
    @State private var showDetail = false
    @State private var detailDocument: Document?
    
    var body: some View {
        List {
            DocumentTypeSection(typeSelected: $typeSelected, viewModel: $viewModel)
            ClientSection(viewModel: viewModel, activeSheet: $activeSheet)
            TypeActeSection(viewModel: $viewModel, activeSheet: $activeSheet)
            if typeSelected == .facture {
                PaymentSection(estPayer: $estPayer, selectedPayement: $selectedPayement, viewModel: viewModel)
            }
            NoteSection(notes: $viewModel.pdfModel.optionsDocument.note)
        }
        .navigationTitle("Document")
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink {
                    DocumentOptionsView(viewModel: viewModel)
                } label: {
                    Label("Options", systemImage: "ellipsis")
                }

                Button("Aperçu", systemImage: "eye") {
                    activeSheet = .apercusDocument
                }

                SaveButton(launchSauvegarde: $launchSauvegarde, viewModel: viewModel)
            }
        }
        .task(id: launchSauvegarde) {
            guard launchSauvegarde else { return }
            defer { launchSauvegarde = false }
            if let document = await viewModel.finalizeAndSave() {
                detailDocument = document
                showDetail = true
            }
        }
        .navigationDestination(isPresented: $showDetail) {
            if let detailDocument {
                DocumentDetailView(document: detailDocument)
            }
        }
        .sheet(item: $activeSheet) { item in
            SheetView(activeSheet: item, viewModel: viewModel)
        }
    }
}
