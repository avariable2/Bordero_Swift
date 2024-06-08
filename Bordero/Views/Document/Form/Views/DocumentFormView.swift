//
//  DocumentFormView.swift
//  Bordero
//
//  Created by Grande Variable on 08/06/2024.
//

import SwiftUI

struct DocumentFormView: View {
    static func getVersion() -> Int32 {
        return 1
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var praticien: FetchedResults<Praticien>
    
    @State private var isPraticienDataSetup = false
    
    private var viewModel : PDFViewModel = PDFViewModel()
    var document : Document?
    
    init(document: Document? = nil) {
        self.document = document
    }
    
    var body: some View {
        ModifierDocumentView(viewModel: viewModel)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    BackButton(viewModel: viewModel, dismiss: dismiss)
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

struct BackButton: View {
    var viewModel: PDFViewModel
    var dismiss: DismissAction
    
    var body: some View {
        Button {
            viewModel.reset()
            dismiss()
        } label: {
            withAnimation {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Retour")
                }
            }
        }
    }
}

struct ModifierDocumentView: View {
    static func getVersion() -> Int32 {
        return 1
    }
    
    @State var viewModel: PDFViewModel
    @State private var activeSheet: ActiveSheet?
    @State private var estPayer: Bool = false
    @State private var selectedPayement: Payement = .carte
    @State private var typeSelected: TypeDoc = .facture
    
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
        .safeAreaInset(edge: .bottom) {
            FormButtonsPrimaryActionView(activeSheet: $activeSheet, viewModel: $viewModel)
        }
        .navigationTitle("Document")
        .listStyle(.plain)
        .contentMargins(.top, 2)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Options") {
                    DocumentOptionsView(viewModel: viewModel)
                }
            }
        }
        .sheet(item: $activeSheet) { item in
            SheetView(activeSheet: item, viewModel: viewModel)
        }
    }
}
