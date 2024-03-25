//
//  DisplayPDFView.swift
//  Bordero
//
//  Created by Grande Variable on 25/03/2024.
//

import SwiftUI
import PDFKit

struct DisplayPDFView: View {
    @Environment(\.dismiss) var dismiss
    let facture : Facture
    
    var body: some View {
        NavigationStack {
            // Utiliser la fonction
            if let pdfData = creerPDF(facture: facture) {
                // Vous pouvez sauvegarder pdfData dans un fichier, l'afficher dans un PDFView, etc.
                
                PDFKitView(pdfData: PDFDocument(data: pdfData)!)
                    .navigationTitle("Aperçus")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Fermer") {
                                dismiss()
                            }
                        }
                    }
            } else {
                ContentUnavailableView("Une erreur sait produite pour creer votre aperçus", systemImage: "exclamationmark.warninglight")
            }
        }
    }
    
    func creerPDF(facture: Facture) -> Data? {
            let pdfMetaData = [
                kCGPDFContextCreator: "Mon App",
                kCGPDFContextAuthor: "votre_nom"
            ]
            let format = UIGraphicsPDFRendererFormat()
            format.documentInfo = pdfMetaData as [String: Any]
            
            let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Taille standard d'une page A4 en points à 72 DPI
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
            let data = renderer.pdfData { context in
                context.beginPage()
                
                let attributes = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)
                ]
                let titleAttributes = [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)
                ]
                
                // Titre
                let title = "\(facture.typeDocument == .facture ? "Facture" : "Devis")"
                title.draw(at: CGPoint(x: 20, y: 20), withAttributes: titleAttributes)
                
                // Informations du praticien
                let praticienInfo = """
            Numéro Delit: \(facture.praticien.numeroDelit ?? "N/A")
            Numéro SIREP: \(facture.praticien.numeroSIREP ?? "N/A")
            Nom: \(facture.praticien.nom ?? "N/A")
            Adresse: \(facture.praticien.adresse ?? "N/A")
            Téléphone: \(facture.praticien.telephone ?? "N/A")
            Email: \(facture.praticien.email ?? "N/A")
            """
                praticienInfo.draw(at: CGPoint(x: 20, y: 50), withAttributes: attributes)
                
                // Démarrez le rendu des éléments de la facture plus bas
                var yOffset = 200
                for utilisateur in facture.utilisateurs {
                    let userInfo = "Utilisateur: \(utilisateur.nom), Adresse: \(utilisateur.adresse)"
                    userInfo.draw(at: CGPoint(x: 20, y: yOffset), withAttributes: attributes)
                    yOffset += 20
                }
                
                // Éléments de la facture
                let itemsTitle = "Articles:"
                itemsTitle.draw(at: CGPoint(x: 20, y: yOffset), withAttributes: titleAttributes)
                yOffset += 30
                
                for item in facture.elements {
                    let itemInfo = "\(item.description) - Quantité: \(item.quantite) - Prix Unitaire: \(item.prixUnitaire)€ - Total: \(item.prixTotal)€"
                    itemInfo.draw(at: CGPoint(x: 20, y: yOffset), withAttributes: attributes)
                    yOffset += 20
                }
                
                // Si c'est un devis, ajouter un espace pour la signature
                if !facture.signature {
                    let signatureInfo = "Signature:"
                    signatureInfo.draw(at: CGPoint(x: 20, y: yOffset + 20), withAttributes: titleAttributes)
                    // Vous pourriez ajouter ici un espace pour une image de signature ou laisser de la place pour une signature manuscrite
                }
            }
            
            return data
        }
}

#Preview {
    DisplayPDFView(facture: exempleFacture)
}
