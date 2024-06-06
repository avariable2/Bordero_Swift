//
//  ApercusTabDetailView.swift
//  Bordero
//
//  Created by Grande Variable on 23/04/2024.
//

import SwiftUI
import PDFKit

struct DocumentApercus : View {
    var document : Document
    
    @State var pdfData : Data?
    
    init(document: Document) {
        self.document = document
        self.pdfData = nil
    }
    
    var body: some View {
        VStack {
            if let data = pdfData {
                DocumentPDFKitView(document: PDFDocument(data: data))
            } else {
                VStack {
                    ContentUnavailableView(
                        "Erreur de chargement",
                        systemImage: "doc.viewfinder",
                        description: Text("Si cela se produit trop souvent, n'hésitez pas à contacter le développeur.").foregroundStyle(.secondary)
                    )
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear() {
            self.pdfData = document.contenuPdf
        }
    }
}
