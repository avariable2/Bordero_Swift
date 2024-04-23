//
//  FormDetailView.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI
import PDFKit

struct DocumentDetailView: View {
    enum TroubleShotCreationFichier {
        case success, failure
    }
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @State private var selectedTab: Tab = .résumé
    @State var document : Document
    @State var pdfDocument : PDFDocument? = nil
    
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
                document: $document
            )
        }
        .onAppear() {
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
    
    var body: some View {
        switch selectedElement {
        case .résumé:
            ResumeTabDetailViewPDF(document: document)
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

