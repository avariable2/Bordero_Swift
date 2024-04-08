//
//  PDFUIView.swift
//  Bordero
//
//  Created by Grande Variable on 25/03/2024.
//

import PDFKit
import SwiftUI

struct PDFKitView: UIViewRepresentable {
    var url: URL
    
    func makeUIView(context: Context) -> PDFView {
        // Créer et configurer PDFView ici
        let pdfView = PDFView()
        pdfView.autoScales = true // Ajuste automatiquement le PDF à la taille de la vue
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // Charger le document PDF
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
    }
}

struct PDFKitView2: UIViewRepresentable {
    
    
    typealias UIViewType = PDFView
    
    let pdfDocument : PDFDocument
    
    init(showing pdfDoc: PDFDocument){
        self.pdfDocument = pdfDoc
    }
    
    func makeUIView(context: UIViewRepresentableContext<PDFKitView>) -> UIViewType {
        let pdfView =  PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        return pdfView
    }
    func makeUIView(context: Context) -> PDFView {
        let pdfView =  PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
