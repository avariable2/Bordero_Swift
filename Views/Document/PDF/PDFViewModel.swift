//
//  PDFViewModel.swift
//  Bordero
//
//  Created by Grande Variable on 11/04/2024.
//

import SwiftUI

class PDFViewModel: ObservableObject {
    @Published var documentData = PDFModel()
    
    // Directement depuis l'exemple de Apple
    @MainActor
    func renderView() -> URL? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let url = directory
            .appendingPathComponent("MyPDF")
            .appendingPathExtension(for: .pdf)
        
        let view = PDFBodyView(data: documentData).frame(width: 600, height: 800)
        let renderer = ImageRenderer(content: view)
        
        renderer.render { size, renderer in
            var mediaBox = CGRect(x: 0, y: 0, width: 600, height: 800)
            guard let consumer = CGDataConsumer(url: url as CFURL),
                  let pdfContext =  CGContext(consumer: consumer,
                                              mediaBox: &mediaBox, nil)
            else {
                return
            }
            pdfContext.beginPDFPage(nil)
            pdfContext.translateBy(x: mediaBox.size.width / 2 - size.width / 2,
                                   y: mediaBox.size.height / 2 - size.height / 2)
            renderer(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }
        
        return url
    }
}
