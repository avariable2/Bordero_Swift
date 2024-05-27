//
//  ToolBarView.swift
//  Bordero
//
//  Created by Grande Variable on 27/05/2024.
//

import SwiftUI
import MessageUI
import PDFKit
import UserNotifications

struct ToolBarView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var document : Document
    var praticien : Praticien?
    
    @State var showModalLoading = false
    @State var errorChangement : ErrorDocument? = nil
    @State var showSheetPayement = false
    @State var showSelectTypeSend = false
    @State var showSendByMail = false
    @State var resultOrErrorMail: Result<MFMailComposeResult, Error>? = nil
    
    @State var showSendByMessage = false
    
    var body: some View {
        if horizontalSizeClass == .compact {
            VStack {
                Group {
                    primaryButton()
                    buttonSecondary()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
        } else {
            primaryButton()
            buttonSecondary()
        }
    }
    
    private func primaryButton() -> some View {
        Button {
            showSelectTypeSend = true
        } label: {
            Label("Envoyer", systemImage: "paperplane.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .popover(isPresented: $showSelectTypeSend) {
            popOverBody()
                .frame(minWidth: 300, maxHeight: 500)
                .presentationCompactAdaptation(.popover)
        }
    }
    
    private func buttonSecondary() -> some View {
        VStack {
            if document.estDeTypeFacture {
                Button {
                    showSheetPayement = true
                } label: {
                    Label {
                        Text(document.listPayements.isEmpty ? "Ajouter un paiement" : "Modifier le paiement")
                            
                    } icon: {
                        Image(systemName: document.listPayements.isEmpty ? "creditcard" : "creditcard.and.123")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .sheet(isPresented: $showSheetPayement) {
                    NavigationStack {
                        PayementSheet(document: document)
                    }
                    .presentationDetents([.medium])
                }
                
            } else {
                Button {
                    convertDevisToFacture()
                } label: {
                    Text("Convertir en Facture")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .sheet(item: $errorChangement) { error in
                    switch errorChangement {
                    case .failToConvertIntoFacture:
                        ContentUnavailableView(
                            "Impossible de transformer votre devis",
                            image: "xmark.circle"
                        )
                    default:
                        EmptyView()
                    }
                }
                .popover(isPresented: $showModalLoading) {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
        }
    }
    
    private func popOverBody() -> some View {
        VStack {
            Button {
                showSendByMail = true
                addEvenementWhenSend()
            } label: {
                Label("Mail", systemImage: "envelope")
            }
            .disabled(!MFMailComposeViewController.canSendMail())
            .sheet(isPresented: $showSendByMail) {
                MailUIView(
                    recipients: [
                        document.client_?.email ?? ""
                    ],
                    title: retrieveMessageTitle(),
                    body: retrieveMessageBody(),
                    pdfToSend: document.contenuPdf,
                    namePdfToSend: document.getNameOfDocument(),
                    result: $resultOrErrorMail
                )
            }
            
            Divider()
            
            Button {
                showSendByMessage = true
                addEvenementWhenSend()
            } label: {
                Label("Message", systemImage: "message")
            }
            .sheet(isPresented: $showSendByMessage) {
                MessageComposeView(
                    recipients: [
                        document.client_?.phone ?? ""
                    ],
                    body: retrieveMessageBody(),
                    pdfToSend: document.contenuPdf,
                    namePdfToSend: document.getNameOfDocument()
                ) { messageSent in
                    
                }
            }
        }
        .font(.title3)
        .padding()
    }
    
    func convertDevisToFacture() {
        showModalLoading = true
        
        document.estDeTypeFacture = true
        let pdfViewModel = PDFViewModel(document: document)
        pdfViewModel.pdfModel.praticien = praticien
        let url = pdfViewModel.renderView()
        
        if let url = url, let pdfDocument = PDFDocument(url: url) {
            document.contenuPdf = pdfDocument.dataRepresentation()
            DataController.saveContext()
        } else {
            errorChangement = .failToConvertIntoFacture
            DataController.rollback()
        }
        
        showModalLoading = false
    }
    
    func retrieveMessageBody() -> String {
        if let praticien = praticien {
            return document.estDeTypeFacture ?
            replaceHashtags(in: praticien.structMessageFacture.corps, with: getValue()) :
            replaceHashtags(in: praticien.structMessageDevis.corps, with: getValue())
        }
        return ""
    }
    
    func retrieveMessageTitle() -> String {
        if let praticien = praticien {
            return document.estDeTypeFacture ?
            replaceHashtags(in: praticien.structMessageFacture.titre, with: getValue()) :
            replaceHashtags(in: praticien.structMessageDevis.titre, with: getValue())
        }
        return "\(document.estDeTypeFacture ? "Facture" : "Devis") \(document.numero)"
    }
    
    func replaceHashtags(in text: String, with values: [String: String]) -> String {
        var newText = text
        let pattern = "#(.*?)#"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
            let matches = regex.matches(in: text, options: [], range: nsRange)
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: text) {
                    let hashtag = String(text[range])
                    let key = String(hashtag.dropFirst().dropLast()) // Remove leading and trailing #
                    
                    if let replacement = values[key] {
                        newText.replaceSubrange(range, with: replacement)
                    }
                }
            }
        }
        
        return newText
    }
    
    func getValue() -> [String : String] {
        return [
            "TOTAL" : document.totalTTC.formatted(.currency(code: "EUR")),
            "DATE_DOCUMENT" : document.dateEmission.formatted(.dateTime.day().month().year()),
            "NOM_DOCUMENT" : document.getNameOfDocument(),
            "NUMERO" : document.numero,
            "NOM_CLIENT" : document.client_?.getFullName() ?? " ",
            "NOM_SOCIETE" : praticien?.nom_proffession ?? ""
        ]
    }
    
    func addEvenementWhenSend() {
        let evenementSend = HistoriqueEvenement(context: context)
        
        if document.status == .send {
            evenementSend.nom = Evenement.TypeEvenement.renvoie.rawValue
        } else {
            evenementSend.nom = Evenement.TypeEvenement.envoie.rawValue
            document.status = .send
        }
        evenementSend.date = Date()
        evenementSend.correspond = document
        document.historique?.adding(evenementSend)
        
        checkNotificationAndAddIfNeeded()
        
        DataController.saveContext()
    }
    
    func checkNotificationAndAddIfNeeded() {
        if document.estDeTypeFacture == false { return }
        guard let documentID = document.id_?.uuidString else { return }
            
        addNotification(withIdentifier: documentID)
    }
    
    func addNotification(withIdentifier identifier: String) {
        guard let dateEcheance = document.dateEcheance_ else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Date d'échéance dépassée"
        content.subtitle = "\(document.getNameOfDocument()) est en retard"
        content.body = "La date d'échéance pour \(document.getNameOfDocument()) était le \(document.dateEcheance.formatted(.dateTime.day().month().year())). Penser à contacter le client dès que possible."
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateEcheance)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Erreur lors de l'ajout de la notification: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ToolBarView(document: Document.example)
}
