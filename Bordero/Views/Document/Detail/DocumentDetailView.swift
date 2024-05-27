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
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var praticien: FetchedResults<Praticien>
    
    @ObservedObject var document : Document
    
    @State private var selectedTab: Tab = .résumé
    @State var pdfDocument : PDFDocument? = nil
    @State private var urlSharing : URL? = nil
    
    @State private var showingShareSheet = false
    @State private var showAlertForDelete = false
    
    @State private var modifyDocument = false
    
    enum TroubleShotCreationFichier {
        case success, failure
    }
    
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
                document: document
            )
        }
        .onAppear() {
            if let dataPDF = document.contenuPdf {
                pdfDocument = PDFDocument(data: dataPDF) ?? nil
            }
            
            urlSharing =  getUrlForSharing()
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareLinkCustom(activityItems: [urlSharing!], applicationActivities: nil) // normalement le boutton pour partager n'existe pas si l'url n'existe pas donc aucune raison que ça soit null
        }
        .navigationTitle("\(document.estDeTypeFacture ? "Facture" : "Devis") # \(document.numero)")
        .safeAreaInset(edge: .bottom) {
            if horizontalSizeClass == .compact {
                ToolBarView(document: document, praticien: praticien.first)
            }
        }
        .toolbar {
            if horizontalSizeClass == .regular {
                ToolbarItemGroup(placement: .primaryAction) {
                    ToolBarView(document: document, praticien: praticien.first)
                }
            }
            
            ToolbarItemGroup(placement: .secondaryAction) {
                Button {
                    modifyDocument = true
                } label : {
                    Label("Modifier", systemImage: "rectangle.and.pencil.and.ellipsis")
                }
                .sheet(isPresented: $modifyDocument) {
                    NavigationStack {
                        DocumentFormView(document: document)
                    }
                }
                
                if let _ = pdfDocument, let _ = urlSharing {
                    Button {
                        prepareForSharing()
                        showingShareSheet = true
                    } label: {
                        Label("Exporter", systemImage: "square.and.arrow.up")
                    }
                }
                
                Button(role: .destructive) {
                    showAlertForDelete = true
                } label: {
                    Label("Supprimer", systemImage: "trash")
                }.alert(
                    Text("Supprimer ce document ?"),
                    isPresented: $showAlertForDelete,
                    actions: {
                        Button("Supprimer", role: .destructive) {
                            delete()
                        }
                        Button("Annuler", role: .cancel) { }
                    }, message : {
                        Text("Cette action est irréversible.")
                    })
            }
        }
        .toolbarRole(.editor)
    }
    
    func prepareForSharing() {
        if document.status == .created {
            document.status = .send
            DataController.saveContext()
        }
    }
    
    func getUrlForSharing() -> URL? {
        // Récupérer le répertoire des documents
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to locate the document directory.")
            return nil
        }
        
        let fileURL: URL
        if let nomFichier = document.nomFichierPdf, !nomFichier.isEmpty {
            // Construire l'URL avec le nom du fichier existant
            fileURL = documentsDirectory.appendingPathComponent(nomFichier)
        } else {
            // Générer un nouveau nom de fichier unique si nécessaire
            let newFileName = UUID().uuidString + ".pdf"
            fileURL = documentsDirectory.appendingPathComponent(newFileName)
            document.nomFichierPdf = newFileName // Mettre à jour le nom du fichier du document
            print("Generated new filename for document.")
        }
        
        // Tenter d'écrire le document, ou réécrire si nécessaire
        let writeResult = writeDocument(to: fileURL)
        switch writeResult {
        case .success:
            print("Document written successfully.")
            DataController.saveContext() // Sauvegarder les changements dans CoreData
            return fileURL
        case .failure:
            print("Failed to write document, attempting to rewrite...")
            return retryWritingDocument(originalURL: fileURL)
        }
    }
    
    /// Tente de réécrire le document sur un nouveau chemin si la première tentative échoue
    func retryWritingDocument(originalURL: URL) -> URL? {
        let newURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(UUID().uuidString + ".pdf")
        if writeDocument(to: newURL!) == .success {
            document.nomFichierPdf = newURL!.lastPathComponent // Mettre à jour le nom de fichier
            DataController.saveContext() // Sauvegarder les changements dans CoreData
            print("Document rewritten successfully.")
            return newURL
        } else {
            print("Failed to rewrite document.")
            return nil
        }
    }
    
    /// Écrire les données du document dans le fichier spécifié et retourner le résultat
    func writeDocument(to url: URL) -> TroubleShotCreationFichier {
        guard let data = document.contenuPdf else { return .failure }
        do {
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            return .success
        } catch {
            print("Failed to write document: \(error.localizedDescription)")
            return .failure
        }
    }
    
    func delete() {
        let fileManager = FileManager.default
        if let urlNeedToBeDelete = getUrlForSharing(), !urlNeedToBeDelete.lastPathComponent.isEmpty {
            do {
                try fileManager.removeItem(at: urlNeedToBeDelete)
                print("Fichier supprimé avec succès")
            } catch {
                print("Erreur lors de la suppression du fichier: \(error)")
            }
        }
        
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
    @ObservedObject var document : Document
    
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

struct ShareLinkCustom: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
