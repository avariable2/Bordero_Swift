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
        
//        let view = FormPraticienView(isOnBoarding: false).frame(width: 600, height: 800)
        let view = PDFBodyView(data: documentData).frame(width: 600, height: 800)
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
                let verticalTranslation = pageSize.size.height / 2 - size.height / 2
                
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
}
