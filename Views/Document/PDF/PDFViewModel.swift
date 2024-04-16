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
    
    // Directement depuis l'exemple de Apple
    @MainActor
    func renderView() -> URL? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let url = directory
            .appendingPathComponent("MyPDF")
            .appendingPathExtension(for: .pdf)
        
        let view = PDFBodyView(data: documentData).frame(width: 600)
        let renderer = ImageRenderer(content: view)
        
        renderer.render { size, renderer in
            var pageSize = CGRect(x: 0, y: 0, width: 600, height: 800)
            var currentPageY: CGFloat = 0
            let totalHeight = size.height
            
            guard let consumer = CGDataConsumer(url: url as CFURL),
                  let pdfContext =  CGContext(consumer: consumer,
                                              mediaBox: &pageSize, nil)
            else {
                return
            }
            
            while currentPageY < totalHeight {
                pdfContext.beginPDFPage(nil) // Starts a new page
                pdfContext.saveGState()
                
                
                // Move the context up by 'currentPageY'
                let horizontalTranslation = (pageSize.width - size.width) / 2
                let verticalTranslation = -currentPageY
                
                pdfContext.translateBy(
                    x: horizontalTranslation,
                    y: verticalTranslation
                )
                
                renderer(pdfContext) // Draw the content starting from 'currentPageY'
                
                pdfContext.restoreGState()
                pdfContext.endPDFPage() // Ends the current page
                
                currentPageY += pageSize.height // Move to the next page height
            }
            
            pdfContext.closePDF() // Finished with the PDF
        }
        
        return url
    }
    
    @MainActor
    func renderViewDecouper() -> URL? {
        // MARK: - Initialisation des constantes du pdf
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let url = directory
            .appendingPathComponent("MyPDF")
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
        return PDFTableData(
            libelle: ttlTA.typeActeReal.name,
            quantity: Decimal(ttlTA.quantity),
            priceHT: Decimal(ttlTA.typeActeReal.price),
            tva: Decimal(ttlTA.typeActeReal.tva),
            priceTTC: Decimal(ttlTA.typeActeReal.total)
        )
    }
}
