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

    @State private var urlSharing : URL? = nil
    
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
//            loadClient()
            if let dataPDF = document.contenuPdf {
                pdfDocument = PDFDocument(data: dataPDF) ?? nil
            }
            if urlSharing == nil {
                urlSharing =  getUrlForSharing()
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
                    
                    if let _ = pdfDocument, let url = urlSharing {
                        ShareLink(item: url)
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
    
    func getUrlForSharing() -> URL? {
        // Trouver le répertoire des documents
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to locate the document directory.")
            return nil
        }
        
        // Construire l'URL complet avec le nom du fichier
        if let nomFichier = document.nomFichierPdf, !nomFichier.isEmpty {
            let fileURL = documentsDirectory.appendingPathComponent(nomFichier)
            
            // Vérifier si le fichier existe déjà
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("File already exists, no need to recreate it.")
                return fileURL
            } else {
                print("File does not exist, attempting to write it.")
                // Écrire le document si le fichier n'existe pas
                let result = writeDocument()
                if result == .success {
                    return fileURL
                } else {
                    print("Failed to write document.")
                    return nil
                }
            }
        } else {
            print("Invalid or empty filename.")
            return nil
        }
    }
    
    func writeDocument() -> TroubleShotCreationFichier {
        guard let data = document.contenuPdf else { return .failure }
        let path = getPathForDocument() ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(UUID().uuidString).appendingPathExtension(for: .pdf)
        
        do {
            try data.write(to: path!, options: [.atomic, .completeFileProtection])
            print("Document écrit avec succès")
            document.nomFichierPdf = path!.lastPathComponent
            DataController.saveContext()
            return .success
        } catch {
            print("Échec de l'écriture du document: \(error.localizedDescription)")
            return .failure
        }
    }

    
    func getPathForDocument() -> URL? {
        guard let nomFichier = document.nomFichierPdf else {
            return nil
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(nomFichier)
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

