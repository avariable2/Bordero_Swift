//
//  ApercusTabDetailView.swift
//  Bordero
//
//  Created by Grande Variable on 23/04/2024.
//

import SwiftUI
import PDFKit

struct DocumentApercus : View {
    @State var document: Document
    
    var body: some View {
        if let data = document.contenuPdf {
            DocumentPDFKitView(document: PDFDocument(data: data))
        } else {
            VStack {
                ContentUnavailableView(
                    "Erreur de chargement",
                    systemImage: "doc.viewfinder",
                    description: Text("Si cela se produit trop souvent, n'hesitez pas à contacter le développeur.").foregroundStyle(.secondary)
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
}
