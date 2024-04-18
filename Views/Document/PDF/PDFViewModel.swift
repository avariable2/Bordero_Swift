//
//  PDFViewModel.swift
//  Bordero
//
//  Created by Grande Variable on 11/04/2024.
//

import SwiftUI
import CoreText
import PDFKit

@Observable
class PDFViewModel {
    var documentData : PDFModel
    
    init(documentData : PDFModel = PDFModel()) {
        self.documentData = documentData
    }
    
    func reset() {
        documentData = PDFModel()
    }
    
    @MainActor
    func renderView() -> URL? {
        // MARK: - Initialisation des constantes du pdf
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let url = directory
            .appendingPathComponent("pdfTmp")
            .appendingPathExtension(for: .pdf)
        
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
        let headerView = HeaderPDFView(data: documentData).frame(width: widthView, height: 150)
        let headerRenderer = ImageRenderer(content: headerView)
        let gridView = PDFGridInfoInvoiceView(data: documentData).frame(width: widthView, height: 140)
        let gridRenderer = ImageRenderer(content: gridView)
        let tableHeaderView = TableHeaderView().frame(width: widthView, height: 50)
        let tableHeaderRenderer = ImageRenderer(content: tableHeaderView)
        
        let coutPartView = CoutPartView(remise: documentData.optionsDocument.remise, sousTot: documentData.calcTotalHT(), montantTva: documentData.calcTotalTVA(), total: documentData.calcTotalTTC())
            .frame(width: widthView, height: documentData.optionsDocument.remise.montant == 0 ? 100 : 150)
        let coutPartRenderer = ImageRenderer(content: coutPartView)
       
        let payementSignatureView = PayementEtSignature(data: documentData).frame(width: widthView)
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
        
        for ttlTypeActe in documentData.elements {
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
    
    func getTableElement(_ ttlTA : TTLTypeActe) -> PDFTableData {
        var libelleFinalAvecOuSansDate = ttlTA.typeActeReal.name
        if !Calendar.current.isDateInToday(ttlTA.date) {
            libelleFinalAvecOuSansDate.append(" du \(ttlTA.date.formatted(.dateTime.day().month().year()))")
        }
        
        return PDFTableData(
            libelle: libelleFinalAvecOuSansDate,
            quantity: ttlTA.quantity,
            priceHT: ttlTA.typeActeReal.price,
            tva: ttlTA.typeActeReal.tva,
            priceTTC: ttlTA.typeActeReal.total
        )
    }
    
    func getDocument() -> Document {
        let moc = DataController.shared.container.viewContext
        let document = Document(context: moc)
        document.estFacture = self.documentData.optionsDocument.typeDocument == .facture
        document.numeroDocument = self.documentData.optionsDocument.numeroDocument
        
        if let client = self.documentData.client {
            document.snapshotClient = [
                "lastname" : client.lastname,
                "firstname" : client.firstname,
                "phone" : client.phone,
                "email" : client.email,
                "adresse" : client.getAdresseSurUneLigne(client.adresse1),
                "code_entreprise" : client.code_entreprise ?? "",
            ]
        }
        
        for element in self.documentData.elements {
            let snapshotTypeActe = element.typeActeReal.getSnapshot(document, date: element.date, quantite: element.quantity)
            document.elements?.adding(snapshotTypeActe)
        }
        
        document.payementFinish = self.documentData.optionsDocument.payementFinish
        document.payementUse = self.documentData.optionsDocument.payementUse.rawValue // Prend le nom du payement pour le retrouvé après
        document.note = self.documentData.optionsDocument.note
        
        if let praticien = self.documentData.praticien {
            document.snapshotPraticien = [
                "lastname" : praticien.lastname,
                "firstname" : praticien.firstname,
                "phone" : praticien.phone,
                "email" : praticien.email,
                "adresse" : praticien.getAdresseSurUneLigne(),
                "website" : praticien.website,
                "logo" : praticien.logoSociete as Any,
                "signature" : praticien.signature as Any,
                "siret" : praticien.siret,
                "adeli" : praticien.adeli
            ]
        }
        
        // Params
        document.dateEmission = self.documentData.optionsDocument.dateEmission
        document.dateEcheance = self.documentData.optionsDocument.dateEcheance
        
        document.remise = [
            "type" : self.documentData.optionsDocument.remise.type,
            "montant" : self.documentData.optionsDocument.remise.montant
        ]
        
        document.payementAllow = [
            "carte" : self.documentData.optionsDocument.payementAllow.contains(.carte),
            "especes" : self.documentData.optionsDocument.payementAllow.contains(.especes),
            "virement" : self.documentData.optionsDocument.payementAllow.contains(.virement),
            "cheque" : self.documentData.optionsDocument.payementAllow.contains(.cheque)
        ]
        
        document.totalHT = self.documentData.calcTotalHT()
        document.totalTVA = self.documentData.calcTotalTVA()
        document.totalTTC = self.documentData.calcTotalTTC()
        
        // Creation de l'historique
        for event in self.documentData.historique {
            let evenementCreation = HistoriqueEvenement(context: moc)
            evenementCreation.correspond = document
            evenementCreation.date = Date()
            evenementCreation.nom = event.nom.rawValue
            document.historique?.adding(evenementCreation)
        }
        
        return document
    }
}
