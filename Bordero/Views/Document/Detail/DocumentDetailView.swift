//
//  DocumentDetailView.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI
import PDFKit
import CoreData
import UserNotifications

struct DocumentDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var praticien: FetchedResults<Praticien>
    
    @ObservedObject var document : Document
    
    @State private var selectedTab: DocumentDetailTab = .résumé
    @State private var shareItem: DocumentShareItem?
    @State private var shareCompleted = false
    @State private var showShareError = false
    @State private var showConfirmSent = false
    @State private var showFacturXInformation = false
    @State private var showConversionError = false
    @State private var showDeleteError = false
    @State private var showPaymentSheet = false
    @State private var showAlertForDelete = false
    @State private var modifyDocument = false

    private struct DocumentShareItem: Identifiable {
        var id = UUID()
        var url: URL
    }
    
    init(document : Document) {
        self.document = document
    }
    
    var body: some View {
        VStack {
            Picker("Afficher", selection: $selectedTab.animation()) {
                ForEach(DocumentDetailTab.allCases) { tab in
                    Text(tab.rawValue.capitalized).tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.trailing, .leading])
            .padding(.top, 8)
            
            Group {
                switch selectedTab {
                case .résumé:
                    ResumeTabDetailViewPDF(document: document)
                case .aperçu:
                    DocumentApercus(document: document)
                case .historique:
                    HistoriqueTabDetailView(document: document)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("\(document.estDeTypeFacture ? "Facture" : "Devis") # \(document.numero)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Envoyer", systemImage: "paperplane.fill", action: shareDocument)
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(document.contenuPdf == nil)
            }

            ToolbarItemGroup(placement: .secondaryAction) {
                Button("Modifier", systemImage: "square.and.pencil") {
                    AnalyticsService.shared.track(event: .documentEdited, category: .documentManagement)
                    modifyDocument = true
                }
                .disabled(document.estDeTypeFacture && document.status != .created)

                if document.estDeTypeFacture {
                    Button(
                        document.listPayements.isEmpty ? "Ajouter un paiement" : "Modifier le paiement",
                        systemImage: "creditcard"
                    ) {
                        showPaymentSheet = true
                    }
                } else {
                    Button("Convertir en facture", systemImage: "arrow.triangle.2.circlepath") {
                        convertDevisToFacture()
                    }
                    .disabled(document.status != .created)
                }

                if document.estDeTypeFacture {
                    Button("Exporter en Factur-X (à venir)", systemImage: "doc.text") {
                        showFacturXInformation = true
                    }
                }

                Button("Supprimer", systemImage: "trash", role: .destructive) {
                    showAlertForDelete = true
                }
                .disabled(document.status != .created)
            }
        }
        .navigationDestination(isPresented: $modifyDocument) {
            DocumentFormView(document: document)
        }
        .sheet(isPresented: $showPaymentSheet) {
            NavigationStack {
                PayementSheet(document: document)
            }
            .presentationDetents([.medium])
        }
        .sheet(item: $shareItem, onDismiss: {
            if shareCompleted && document.status == .created {
                showConfirmSent = true
            }
            shareCompleted = false
        }) { item in
            DocumentShareSheet(documentURL: item.url) { completed in
                shareCompleted = completed
                shareItem = nil
            }
        }
        .confirmationDialog(
            "Le document a-t-il été envoyé au client ?",
            isPresented: $showConfirmSent,
            titleVisibility: .visible
        ) {
            Button("Marquer comme envoyé", action: markAsSent)
            Button("Garder en brouillon", role: .cancel) { }
        } message: {
            Text("Le partage peut aussi servir à enregistrer une copie. Confirmez seulement si le client a bien reçu le document.")
        }
        .alert("Partage impossible", isPresented: $showShareError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Le PDF de ce document n’a pas pu être préparé.")
        }
        .alert("Factur-X n’est pas encore disponible", isPresented: $showFacturXInformation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Un export conforme nécessite un PDF/A-3 avec un XML structuré validé, puis une plateforme agréée pour la transmission concernée. Aucun fichier Factur-X n’est généré pour le moment.")
        }
        .alert("Conversion impossible", isPresented: $showConversionError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Le devis n’a pas pu être converti en facture.")
        }
        .alert("Supprimer ce brouillon ?", isPresented: $showAlertForDelete) {
            Button("Supprimer", role: .destructive, action: delete)
            Button("Annuler", role: .cancel) { }
        } message: {
            Text("Cette action est irréversible.")
        }
        .alert("Suppression impossible", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Le brouillon n’a pas pu être supprimé. Réessayez.")
        }
    }

    private func shareDocument() {
        guard let url = getUrlForSharing() else {
            showShareError = true
            return
        }
        shareItem = DocumentShareItem(url: url)
    }
    
    private func getUrlForSharing() -> URL? {
        guard let pdf = document.contenuPdf,
              let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let fileName = document.nomFichierPdf.flatMap { $0.isEmpty ? nil : $0 }
            ?? "\(document.estDeTypeFacture ? "Facture" : "Devis")-\(UUID().uuidString).pdf"
        let url = directory.appendingPathComponent(fileName)

        do {
            try pdf.write(to: url, options: [.atomic, .completeFileProtection])
            if document.nomFichierPdf != fileName {
                document.nomFichierPdf = fileName
                DataController.saveContext()
            }
            return url
        } catch {
            print("Impossible de préparer le PDF : \(error.localizedDescription)")
            return nil
        }
    }

    private func markAsSent() {
        guard document.status == .created else { return }

        let event = HistoriqueEvenement(context: moc)
        event.nom = Evenement.TypeEvenement.envoie.rawValue
        event.date = .now
        event.correspond = document
        document.status = .send
        DataController.saveContext()
        scheduleDueReminderIfNeeded()
        AnalyticsService.shared.track(event: .documentSent, category: .documentManagement)
    }

    private func scheduleDueReminderIfNeeded() {
        guard document.estDeTypeFacture,
              let identifier = document.id_?.uuidString,
              let dueDate = document.dateEcheance_,
              dueDate > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = "Date d’échéance dépassée"
        content.subtitle = "\(document.getNameOfDocument()) est en retard"
        content.body = "La date d’échéance de ce document est dépassée. Pensez à contacter le client."
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: dueDate
        )
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized ||
                    settings.authorizationStatus == .provisional else { return }
            center.add(request)
        }
    }

    private func convertDevisToFacture() {
        guard !document.estDeTypeFacture, document.status == .created else { return }
        document.estDeTypeFacture = true
        let viewModel = PDFViewModel(document: document)
        viewModel.pdfModel.praticien = praticien.first

        if let url = viewModel.renderView(),
           let pdf = PDFDocument(url: url),
           let data = pdf.dataRepresentation() {
            document.contenuPdf = data
            DataController.saveContext()
        } else {
            DataController.rollback()
            showConversionError = true
        }
    }

    private func delete() {
        guard document.status == .created else { return }
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            .flatMap { directory in
                document.nomFichierPdf.flatMap { fileName in
                    fileName.isEmpty ? nil : directory.appendingPathComponent(fileName)
                }
            }
        moc.delete(document)
        do {
            try moc.save()
        } catch {
            moc.rollback()
            showDeleteError = true
            return
        }
        if let fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
        dismiss()
    }
}

private enum DocumentDetailTab: String, CaseIterable, Identifiable {
    case résumé, aperçu, historique
    
    var id: Self { self }
}

private struct DocumentShareSheet: UIViewControllerRepresentable {
    var documentURL: URL
    var onCompletion: (Bool) -> Void
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [documentURL], applicationActivities: nil)
        controller.completionWithItemsHandler = { _, completed, _, _ in
            DispatchQueue.main.async {
                onCompletion(completed)
            }
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
