//
//  SwiftUIView.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI
import SafariServices
import MessageUI
import PDFKit

enum ErrorDocument : Identifiable {
    case failToConvertIntoFacture
    var id: Self { self }
}

struct ResumeTabDetailViewPDF: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: []) var praticien: FetchedResults<Praticien>
    
    // MARK: Attribut pour changer la facture en devis
    @State var showModalLoading = false
    @State var errorChangement : ErrorDocument? = nil
    
    @State var presentURL: URL? = nil
    @ObservedObject var document : Document
    
    @State var showSheetPayement = false
    
    @State var showSelectTypeSend = false
    
    @State var showSendByMail = false
    @State var resultOrErrorMail: Result<MFMailComposeResult, Error>? = nil
    
    @State var showSendByMessage = false
    
    var body: some View {
        VStack {
            Form {
                Section {
                    VStack(alignment: .center, spacing: 20) {
                        
                        GroupBox {
                            ScrollView(.vertical, showsIndicators: true) {
                                Text("En france, la loi contre la fraude ne permet pas la modification ou la suppression d'une facture déjà envoyée ou exportée.")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxHeight: 65)
                            
                            Button {
                                presentURL = URL(string: "https://www.legifrance.gouv.fr/codes/id/LEGISCTA000006191855")!
                            } label: {
                                Text("En savoir plus")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.link)
                            }
                            
                        } label: {
                            Label("Loi Française", systemImage: "building.columns")
                                .tint(.primary)
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
                } header: {
                    Text("Attention")
                }
                
                Section {
                    Button {
                        
                    } label: {
                        if let client = document.client_ {
                            ClientRowView(firstname: client.firstname, name: client.lastname)
                                .tint(.primary)
                        } else {
                            Label {
                                Text("Le client n'à pas été retrouvé ou bien à été supprimer.")
                                    .fontWeight(.regular)
                            } icon: {
                                Image(systemName: "person.crop.circle.badge.questionmark.fill")
                                    .foregroundStyle(.yellow, .gray)
                                    .imageScale(.large)
                            }
                            .tint(.primary)
                        }
                    }
                    
                } header: {
                    Text("Créer pour")
                }
                
                Section {
                    HStack {
                        Text("Status")
                        Spacer()
                        HStack(spacing: nil) {
                            Image(systemName: "circle.circle.fill")
                                .foregroundStyle(.black, document.determineColor())
                            Text(document.determineStatut())
                                .foregroundStyle(.primary)
                                .fontWeight(.light)
                        }
                    }
                    
                    HStack {
                        Text("Reste à payé")
                        Spacer()
                        Text(document.resteAPayer, format: .currency(code: "EUR"))
                            .fontWeight(.semibold)
                    }
                    
                    LabeledContent("Date d'émission") {
                        Text(document.dateEmission.formatted(.dateTime.day().month().year()))
                            .foregroundStyle(.primary)
                            .fontWeight(.light)
                    }
                    
                    LabeledContent("Date d'échéance") {
                        Text(document.dateEcheance.formatted(.dateTime.day().month().year()))
                            .foregroundStyle(.primary)
                            .fontWeight(.light)
                    }
                } header: {
                    Text("Informations")
                }
                
                Section {
                    RowMontantDetail(text: "Total H.T.", price: document.totalHT)
                    RowMontantDetail(text: "T.V.A", price: document.totalTVA)
                    RowMontantDetail(text: "Total T.T.C", price: document.totalTTC)
                } header: {
                    Text("Détails")
                }
            }
            .sheet(item: $presentURL) { url in
                SafariView(url: url)
            }
            .sheet(isPresented: $showSheetPayement) {
                NavigationStack {
                    PayementSheet(document: document)
                }
                .presentationDetents([.medium])
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
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Button {
                        showSelectTypeSend = true
                    } label: {
                        Label("Envoyer", systemImage: "paperplane.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .confirmationDialog(Text("Séléctionner la méthode d'envoie"), isPresented: $showSelectTypeSend, titleVisibility: .visible) {
                        
                        Button {
                            showSendByMail = true
                            addEvenementWhenSend()
                        } label: {
                            Label("Mail", systemImage: "envelope")
                        }
                        .disabled(!MFMailComposeViewController.canSendMail())
                        
                        Button {
                            showSendByMessage = true
                            addEvenementWhenSend()
                        } label: {
                            Label("Message", systemImage: "message")
                        }
                    }
                    
                    if document.estDeTypeFacture {
                        Button {
                            showSheetPayement = true
                        } label: {
                            Text(document.listPayements.isEmpty ? "Ajouter un paiement" : "Modifier le paiement")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button {
                            convertDevisToFacture()
                        } label: {
                            Text("Convertir en Facture")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .popover(isPresented: $showModalLoading) {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
            }
        }
    }
    
    func convertDevisToFacture() {
        showModalLoading = true
        
        document.estDeTypeFacture = true
        let pdfViewModel = PDFViewModel(document: document)
        pdfViewModel.pdfModel.praticien = praticien.first
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
        if let praticien = praticien.first {
            return document.estDeTypeFacture ? 
            replaceHashtags(in: praticien.structMessageFacture.corps, with: getValue()) :
            replaceHashtags(in: praticien.structMessageDevis.corps, with: getValue())
        }
        return ""
    }
    
    func retrieveMessageTitle() -> String {
        if let praticien = praticien.first {
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
            "NOM_SOCIETE" : praticien.first?.nom_proffession ?? ""
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
        
        DataController.saveContext()
    }
}

struct RowMontantDetail: View {
    let text : String
    let price : Double
    
    var body: some View {
        HStack {
            Text(text.uppercased())
                .foregroundStyle(.secondary)
                .font(.caption)
            
            Spacer()
            
            Text(price, format: .currency(code: "EUR"))
                .fontWeight(.light)
        }
    }
}

#Preview {
    ResumeTabDetailViewPDF(document: Document.example)
}

extension URL: Identifiable {
    public var id: String {
        self.absoluteString
    }
}
