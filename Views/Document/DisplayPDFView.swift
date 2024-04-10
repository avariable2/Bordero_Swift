//
//  DisplayPDFView.swift
//  Bordero
//
//  Created by Grande Variable on 25/03/2024.
//

import SwiftUI
import PDFKit

class PDFViewModel: ObservableObject {
    @Published var generatedPDFURL: URL?
    
    @MainActor func renderView(viewSize: CGSize) {
        let renderer = ImageRenderer(content: PDFBodyView(data: exempleFacture).frame(width: viewSize.width, height: viewSize.height, alignment: .center))
        
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
}


struct DisplayPDFView: View {
    @Environment(\.dismiss) var dismiss
    let facture : DocumentData
    @ObservedObject var viewModel : PDFViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                if let url = viewModel.generatedPDFURL {
                    PDFKitView(url: url)
                } else {
                    VStack {
                        ProgressView()
                        Text("Génération du PDF en cours...")
                    }
                }
            }
            .onAppear {
                viewModel.renderView(viewSize: CGSize(width: 612, height: 792))
            }
            .navigationTitle("Aperçus")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Retour")
                    }
                }
            }
        }
    }
    
//    func creerPDF(facture: DocumentData) -> Data? {
//        let pdfMetaData = [
//            kCGPDFContextCreator: "Bordero",
//            kCGPDFContextAuthor: "votre_nom"
//        ]
//        let format = UIGraphicsPDFRendererFormat()
//        format.documentInfo = pdfMetaData as [String: Any]
//        
//        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Taille standard d'une page A4 en points à 72 DPI
//        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
//        let data = renderer.pdfData { context in
//            context.beginPage()
//            
//            let attributes = [
//                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)
//            ]
//            
//            let titleAttributes = [
//                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 32)
//            ]
//            
//            // LOGO de apple
//            let globeIcon = UIImage(systemName: "apple.logo")
//            let appleLogoRect = CGRect(x: 20, y: 20, width: 30, height: 35)
//            globeIcon!.draw(in: appleLogoRect)
//            
//            // Titre
//            let title = "\(facture.typeDocument == .facture ? "Facture" : "Devis")"
//            title.draw(at: CGPoint(x: 480, y: 20), withAttributes: titleAttributes)
//            
//            infoPraticien(attributes)
//        }
//        
//        return data
//    }
//    
//    // MARK: - Partie information de l'utilisateur
//    func infoPraticien( _ attributes: [NSAttributedString.Key : UIFont]) {
//        // Informations du praticien
//        let urlTextAttributes: [NSAttributedString.Key: Any] = [
//            .font: UIFont.systemFont(ofSize: 12),
//            .foregroundColor: UIColor.link
//        ]
//        let praticienInfo = NSMutableAttributedString(string:
//        """
//        \(facture.praticien.nom ?? "N/A")
//        \(facture.praticien.adresse ?? "N/A")
//        \(facture.praticien.telephone ?? "N/A")\n
//        """, attributes: attributes)
//        if let email = facture.praticien.email {
//            let emailString = NSAttributedString(string: "\(email)\n", attributes: urlTextAttributes)
//            praticienInfo.append(emailString)
//        }
//        
//        if let websiteURL = facture.praticien.website, let _ = URL(string: websiteURL) {
//            let websiteString = NSAttributedString(string: websiteURL, attributes: urlTextAttributes)
//            praticienInfo.append(websiteString)
//        }
//        let textRect = CGRect(x: 20, y: 70, width: 200, height: 200)
//        praticienInfo.draw(in: textRect)
//    }
    
}



#Preview {
    DisplayPDFView(facture: exempleFacture, viewModel: PDFViewModel())
    //    PDFBodyView()
}


