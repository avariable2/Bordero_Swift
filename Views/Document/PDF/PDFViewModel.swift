//
//  PDFViewModel.swift
//  Bordero
//
//  Created by Grande Variable on 11/04/2024.
//

import SwiftUI

class PDFViewModel: ObservableObject {
    @Published var documentData = PDFModel()
    @Published var generatedPDFURL: URL?
    
    @MainActor func renderView() {
        let renderer = ImageRenderer(content: PDFBodyView(
            data: documentData
        ))
        
        let tempURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let renderURL = tempURL.appending(path: "\(UUID().uuidString).pdf")
        
        if let consumer = CGDataConsumer(url: renderURL as CFURL), let context = CGContext(consumer: consumer, mediaBox: nil, nil) {
            renderer.render { size, renderer in
                var mediaBox = CGRect(origin: .zero, size: size)
                context.beginPage(mediaBox: &mediaBox)
                renderer(context)
                context.endPDFPage()
                context.closePDF()
                DispatchQueue.main.async {
                    self.generatedPDFURL = renderURL
                }
            }
        }
    }
    
    func updateDataAndGenereatedPreview() {
        
    }
}
