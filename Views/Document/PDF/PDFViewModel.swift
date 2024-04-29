//
//  PDFViewModel.swift
//  Bordero
//
//  Created by Grande Variable on 11/04/2024.
//

import SwiftUI
import CoreText
import PDFKit
import CoreData

@Observable
class PDFViewModel {
    var pdfModel : PDFModel
    var documentObject : Document? = nil
    
    init(document: Document? = nil) {
        self.pdfModel = PDFModel()
        if let document = document {
            retrieveDataFromDocument(document: document)
        }
    }
    
    func reset(needToDeleteFile : Bool = true) {
        if documentObject == nil, let fileNeedToBeDeleted = pdfModel.urlFilePreview, !fileNeedToBeDeleted.lastPathComponent.isEmpty, needToDeleteFile {
            deleteFile(fileNeedToBeDeleted)
        }
        pdfModel = PDFModel()
    }
    
    func deleteFile(_ urlFile : URL) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: urlFile)
            print("Fichier supprimé avec succès")
        } catch {
            print("Erreur lors de la suppression du fichier: \(error)")
        }
    }
    
    func modifyPayementAllow(_ type : Payement, value: Bool) {
        if value {
            if !pdfModel.optionsDocument.payementAllow.contains(type) {
                pdfModel.optionsDocument.payementAllow.append(type)
            }
        } else {
            pdfModel.optionsDocument.payementAllow.removeAll { $0 == type }
        }
    }
    
    @MainActor
    func renderView(_ urlFile : URL? = nil) -> URL? {
        // MARK: - Initialisation des constantes du pdf
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let url : URL
        if let alreadyExistingUrlFile = urlFile {
            url = directory.appendingPathComponent(alreadyExistingUrlFile.lastPathComponent)
        } else {
            url = directory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(for: .pdf)
        }
        
        var pageSize = CGRect(x: 0, y: 0, width: 600, height: 800)
        guard let consumer = CGDataConsumer(url: url as CFURL),
              let pdfContext =  CGContext(consumer: consumer,
                                          mediaBox: &pageSize, nil) else {
            return nil
        }
        
        let widthView : CGFloat = 560
        var currentY: CGFloat = pageSize.height - 30 // Début en haut de la page
        
        // MARK: - Initialisation de la view
        pdfContext.beginPDFPage(nil)
        
        pdfContext.translateBy(x: 0, y: 20) // Positionne le contexte en haut de la page
        
        // MARK: - View initialisation
        let headerView = HeaderPDFView(data: pdfModel).frame(width: widthView, height: 150)
        let headerRenderer = ImageRenderer(content: headerView)
        let gridView = PDFGridInfoInvoiceView(data: pdfModel).frame(width: widthView, height: 140)
        let gridRenderer = ImageRenderer(content: gridView)
        let tableHeaderView = TableHeaderView().frame(width: widthView, height: 50)
        let tableHeaderRenderer = ImageRenderer(content: tableHeaderView)
        
        let coutPartView = CoutPartView(remise: pdfModel.optionsDocument.remise, sousTot: pdfModel.calcTotalHT(), montantTva: pdfModel.calcTotalTVA(), total: pdfModel.calcTotalTTC())
            .frame(width: widthView, height: pdfModel.optionsDocument.remise.montant == 0 ? 100 : 150)
        let coutPartRenderer = ImageRenderer(content: coutPartView)
       
        let payementSignatureView = PayementEtSignature(data: pdfModel).frame(width: widthView)
        let payementSignatureRenderer = ImageRenderer(content: payementSignatureView)
        
        // MARK: - View Rendu
        headerRenderer.render { size, renderHeader in
            pdfContext.saveGState()
            currentY -= size.height
            pdfContext.translateBy(x: 20, y: currentY) // Descend de la hauteur du header
            renderHeader(pdfContext)
            pdfContext.restoreGState()
        }
        
        gridRenderer.render { size, renderGrid in
            pdfContext.saveGState()
            currentY -= size.height
            pdfContext.translateBy(x: 20, y: currentY) // Descend pour positionner le grid en dessous du header
            renderGrid(pdfContext)
            pdfContext.restoreGState()
        }
        
        tableHeaderRenderer.render { size, renderTableHeader in
            pdfContext.saveGState()
            currentY -= size.height
            pdfContext.translateBy(x: 20, y: currentY) // Descend pour positionner la tab en dessous de la grid
            renderTableHeader(pdfContext)
            pdfContext.restoreGState()
        }
        
        for ttlTypeActe in pdfModel.elements {
            let tableElement = TableGridRowView(purchase: self.getTableElement(ttlTypeActe)).frame(width: widthView)
            let tableElementRenderer = ImageRenderer(content: tableElement)
            
            tableElementRenderer.render { size, renderTableElement in
                pdfContext.saveGState()
                
                checkIfNeedANewPage(&currentY, sizeView: size, pdfContext: pdfContext)

                pdfContext.translateBy(x: 20, y: currentY)
                renderTableElement(pdfContext)
                pdfContext.restoreGState()
            }
        }
        
        coutPartRenderer.render { size, renderCoutPart in
            pdfContext.saveGState()
            
            checkIfNeedANewPage(&currentY, sizeView: size, pdfContext: pdfContext)
            
            pdfContext.translateBy(x: 20, y: currentY) // Descend pour positionner la tab en dessous de la grid
            renderCoutPart(pdfContext)
            pdfContext.restoreGState()
        }
        
        payementSignatureRenderer.render { size, renderPayementSignature in
            pdfContext.saveGState()
            
            checkIfNeedANewPage(&currentY, sizeView: size, pdfContext: pdfContext)
            
            pdfContext.translateBy(x: 20, y: currentY) // Descend pour positionner la tab en dessous de la grid
            renderPayementSignature(pdfContext)
            pdfContext.restoreGState()
        }
        
        pdfContext.endPDFPage() // Termine la page courante
        pdfContext.closePDF() // Ferme le contexte PDF
        
        return url
    }
    
    func checkIfNeedANewPage( _ currentY: inout CGFloat, sizeView : CGSize, pdfContext : CGContext) {
        currentY -= sizeView.height
        
        if currentY <= 20 { // Si l'element descend en bas de la page + padding alors on creer une nouvelle page
            pdfContext.endPDFPage()
            
            pdfContext.beginPDFPage(nil)
            currentY = 780 // On reinitialise en haut de la page
            currentY -= sizeView.height // et on recommence à enlever la taille
        }
    }
    
    func getTableElement(_ ttlTA : SnapshotTypeActe) -> PDFTableData {
        var libelleFinalAvecOuSansDate = ttlTA.name
        if !Calendar.current.isDateInToday(ttlTA.date) {
            libelleFinalAvecOuSansDate.append(" du \(ttlTA.date.formatted(.dateTime.day().month().year()))")
        }
        
        return PDFTableData(
            libelle: libelleFinalAvecOuSansDate, 
            infoLibelle: ttlTA.info,
            remarque: ttlTA.remarque,
            quantity: ttlTA.quantity,
            priceHT: ttlTA.price,
            tva: ttlTA.tva,
            priceTTC: ttlTA.total
        )
    }
    
    func finalizeAndSave(completion: (Document) -> Void) async {
        let moc = DataController.shared.container.viewContext
        let document = await getDocument(context: moc)
        
        DataController.saveContext()
        
        completion(document)
        
        reset(needToDeleteFile: false) // reset before launch the new screen
    }
    
    func getDocument(context : NSManagedObjectContext) async -> Document {
        let document : Document
        if let doc = documentObject {
            document = doc
            
            // MARK: Creation de l'historique
            let objEvenement = Evenement(nom: .modification, date: Date())
            let evenementCreation = HistoriqueEvenement(context: context)
            evenementCreation.id = UUID()
            evenementCreation.correspond = document
            evenementCreation.date = objEvenement.date
            evenementCreation.nom = objEvenement.nom.rawValue
            document.historique?.adding(evenementCreation)
            
        } else {
            document = Document(context: context)
            
            // MARK: Creation de l'historique
            let objEvenement = Evenement(nom: .création, date: Date())
            let evenementCreation = HistoriqueEvenement(context: context)
            evenementCreation.id = UUID()
            evenementCreation.correspond = document
            evenementCreation.date = objEvenement.date
            evenementCreation.nom = objEvenement.nom.rawValue
            document.historique?.adding(evenementCreation)
        }
        
        document.estDeTypeFacture = self.pdfModel.optionsDocument.estFacture
        document.numero = self.pdfModel.optionsDocument.numeroDocument
        document.status = .created
        
        if let client = self.pdfModel.client {
            
            document.snapshotClient = Document.SnapshotClient(
                lastname: client.lastname,
                firstname: client.firstname,
                phone: client.phone,
                email: client.email,
                code_entreprise: client.code_entreprise ?? "",
                adresse: client.getAdresseSurUneLigne(client.adresse1),
                uuidClient: client.id
            )
            
            document.client_ = client
        }
        
        for snapshotTypeActe in self.pdfModel.elements {
            snapshotTypeActe.estUnElementDe = document
            document.elements?.adding(snapshotTypeActe)
        }
        
        document.payementFinish = self.pdfModel.optionsDocument.payementFinish
        document.payementUse = self.pdfModel.optionsDocument.payementUse.rawValue // Prend le nom du payement pour le retrouvé après
        document.note = self.pdfModel.optionsDocument.note
        
        if let praticien = self.pdfModel.praticien {
            
            document.snapshotPraticien = Document.SnapshotPraticien(
                lastname: praticien.lastname,
                firstname: praticien.firstname,
                phone: praticien.phone,
                email: praticien.email,
                website:  praticien.website,
                adresse: praticien.getAdresseSurUneLigne(),
                siret: praticien.siret,
                adeli: praticien.adeli,
                signature: praticien.signature,
                logo : praticien.logoSociete
            )
        }
        
        // Params
        document.dateEmission = self.pdfModel.optionsDocument.dateEmission
        document.dateEcheance = self.pdfModel.optionsDocument.dateEcheance
        
        document.remise = Document.Remise(
            type: self.pdfModel.optionsDocument.remise.type.description,
            montant: self.pdfModel.optionsDocument.remise.montant
        )
        
        document.payementAllow = Document.PayementAllow(
            carte: self.pdfModel.optionsDocument.payementAllow.contains(.carte),
            cheque: self.pdfModel.optionsDocument.payementAllow.contains(.cheque),
            virement: self.pdfModel.optionsDocument.payementAllow.contains(.virement),
            especes: self.pdfModel.optionsDocument.payementAllow.contains(.especes))
        
        document.totalHT = self.pdfModel.calcTotalHT()
        document.totalTVA = self.pdfModel.calcTotalTVA()
        document.totalTTC = self.pdfModel.calcTotalTTC()
        
        document.montantPayer = self.pdfModel.optionsDocument.payementFinish ? self.pdfModel.calcTotalTTC() : 0
        
        // MARK: Sauvegarde du rendu du pdf pour etre affiché
        // Déclaration d'une propriété pour stocker le document PDF
        var pdfDocument: PDFDocument?

        if let url = await self.renderView() {
            pdfDocument = PDFDocument(url: url)
        }
        
        if let pdf = pdfDocument {
            document.contenuPdf = pdf.dataRepresentation()
        } else {
            // Gérer le cas où pdfDocument est nil
            print("Erreur : Le document PDF n'a pas pu être chargé ou créé.")
        }
        document.nomFichierPdf = self.pdfModel.urlFilePreview?.absoluteString

        return document
    }
    
    func retrieveDataFromDocument(document : Document) {
        documentObject = document
        pdfModel.optionsDocument.estFacture = document.estDeTypeFacture 
        pdfModel.optionsDocument.numeroDocument = document.numero
        
        pdfModel.client = document.client_
        
        pdfModel.elements = Array(document.listSnapshotTypeActe)
        
        pdfModel.optionsDocument.payementFinish = document.payementFinish
        pdfModel.optionsDocument.payementUse = Payement.findPaymentType(from: document.payementUse) ?? Payement.carte
        if document.payementAllow.carte {
            pdfModel.optionsDocument.payementAllow.append(.carte)
        }
        if document.payementAllow.especes {
            pdfModel.optionsDocument.payementAllow.append(.especes)
        }
        if document.payementAllow.virement {
            pdfModel.optionsDocument.payementAllow.append(.virement)
        }
        if document.payementAllow.cheque {
            pdfModel.optionsDocument.payementAllow.append(.cheque)
        }
        pdfModel.optionsDocument.note = document.note
        
        pdfModel.optionsDocument.dateEmission = document.dateEmission
        pdfModel.optionsDocument.dateEcheance = document.dateEcheance
        
        pdfModel.optionsDocument.remise = Remise(
            type: Remise.TypeRemise.findDiscountType(from: document.remise.type) ?? .pourcentage,
            montant: document.remise.montant
        )
        
        pdfModel.urlFilePreview = URL(string: document.nomFichierPdf ?? "")
        
    }
}
