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
    
    private var document : PDFDocument? {
        PDFDocument(url: url)
    }
    
    func makeUIView(context: Context) -> PDFView {
        // Créer et configurer PDFView ici
        let pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: 600, height: 800))
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.autoScales = true // Ajuste automatiquement le PDF à la taille de la vue
        if let document = document, pdfView.document != document  {
            pdfView.document = document
        }
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // Charger le document PDF
        // NE pas modifier l'element ici puisqu'il ne change pas
    }
}
