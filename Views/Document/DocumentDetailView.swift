//
//  FormDetailView.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI
import PDFKit
import CoreData

struct DocumentDetailView: View {
    enum TroubleShotCreationFichier {
        case success, failure
    }
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @State private var selectedTab: Tab = .résumé
    @State var document : Document
    @State var pdfDocument : PDFDocument? = nil
    @State private var client: Client?

    
    init(document : Document) {
        self.document = document
    }
    
    var body: some View {
        VStack {
            Picker("Afficher", selection: $selectedTab.animation()) {
                ForEach(Tab.allCases) { tab in
                    Text(tab.rawValue.capitalized).tag(tab.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.trailing, .leading])
            
            ChoosenView(
                selectedElement: selectedTab,
                document: $document, 
                client: $client
            )
        }
        .onAppear() {
            loadClient()
            if let dataPDF = document.contenuPdf {
                pdfDocument = PDFDocument(data: dataPDF) ?? nil
            }
        }
        .navigationTitle("\(document.estDeTypeFacture ? "Facture" : "Devis") # \(document.numero)")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Modifier") {
                        
                    }
                    
                    Divider()
                    
                    Button("Dupliquer") {
                        
                    }
                    
                    if let _ = pdfDocument {
                        ShareLink(item: getUrlForSharing())
                    }
                    
                    Divider()
                    
                    Button("Supprimer", role: .destructive) {
                        delete()
                    }
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    private func loadClient() {
        guard let uuid = document.snapshotClient.uuidClient else { return }
        let request: NSFetchRequest<Client> = Client.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
        request.fetchLimit = 1

        DispatchQueue.global(qos: .userInitiated).async {
            let results = try? moc.fetch(request)
            DispatchQueue.main.async {
                self.client = results?.first
            }
        }
    }
    
    func getUrlForSharing() -> URL {
        if let path = document.nomFichierPdf, !path.isEmpty && FileManager.default.fileExists(atPath: path) {
            return URL(string: path)!
        } else {
            let result = writeDocument()
            return result == .success ? URL(string: document.nomFichierPdf!)! : URL(string: "")!
        }
    }
    
    func writeDocument() -> TroubleShotCreationFichier {
        guard let data = document.contenuPdf, let path = getPathForDocument() else { return .failure }
        do {
            try data.write(to: path, options: [.atomic, .completeFileProtection])
            print("Réecriture reussi")
        } catch {
            print(error.localizedDescription)
            return .failure
        }
        document.nomFichierPdf = path.absoluteString
        DataController.saveContext()
        
        return .success
    }
    
    func getPathForDocument() -> URL? {
        guard
            let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
                .appendingPathComponent(document.getNameOfDocument())
                .appendingPathExtension(for: .pdf) else {
            return nil
        }
        return path
    }
    
    func delete() {
        moc.delete(document)
        
        DataController.saveContext()
        dismiss()
    }
}

enum Tab : String, CaseIterable, Identifiable {
    case résumé, aperçu, historique
    
    var id: Self { self }
}

struct ChoosenView : View {
    var selectedElement : Tab
    @Binding var document : Document
    @Binding var client : Client?
    
    var body: some View {
        switch selectedElement {
        case .résumé:
            ResumeTabDetailViewPDF(document: document, client: $client)
        case .aperçu:
            DocumentApercus(document: document)
        case .historique:
            HistoriqueTabDetailView(document: document)
        }
    }
}

//#Preview {
//    NavigationStack {
//        DocumentDetailView(viewModel: PDFViewModel())
//    }
//}

