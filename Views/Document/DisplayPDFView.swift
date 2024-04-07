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
            VStack {
                // Utiliser la fonction
                if let pdfData = creerPDF(facture: facture) {
                    // Vous pouvez sauvegarder pdfData dans un fichier, l'afficher dans un PDFView, etc.
                    
                    PDFKitView(pdfData: PDFDocument(data: pdfData)!)
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
            .navigationTitle("Aperçus")
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

struct PDFBodyView : View {
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Image(systemName: "apple.logo")
                        .font(.largeTitle)
                    
                    VStack(alignment: .leading) {
                        Text("VVVV VVV")
                        Text("6 rue du Pasteur")
                        Text("5600 BANNES")
                        Text("06 65 45 56 56")
                        Text("lele.gmail@gmail.com")
                        Text("www.oestopatebretagne.com")
                    }
                }
                
                Spacer()
                
                Text("Facture")
                    .font(.largeTitle)
                    .bold()
            }
            .padding([.bottom, .top])
            
            Grid(alignment: .topLeading, horizontalSpacing: 2, verticalSpacing: 2) {
                GridRow {
                    Grid(alignment: .topLeading, horizontalSpacing: 2, verticalSpacing: 2) {
                        GridRow {
                            CellInGridView(titre: "Nom de société", information: "Cabinet d'ostéopathie")
                                .gridCellColumns(6)
                        }
                        
                        GridRow {
                            CellInGridView(titre: "N° SIRET", information: "80378752200025")
                                .gridCellColumns(3)
                            CellInGridView(titre: "N° ADELI", information: "220001481")
                                .gridCellColumns(3)
                        }
                        
                        GridRow {
                            CellInGridView(titre: "Date de facture", information: "31 aout 2024")
                                .gridCellColumns(3)
                            CellInGridView(titre: "N° de document", information: "20240318004")
                                .gridCellColumns(3)
                        }
                    }
                    .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .topLeading)
                    
                    VStack(alignment: .leading) {
                        Text("Facturé à".uppercased())
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                            .bold()
                        
                        Text("Apple S.")
                        Text("San Franscisco")
                        Text("Le bourg")
                        Text("19200 Saint parfois le neuf")
                    }
                    .padding()
                    .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .topLeading)
                    .background(.green.opacity(0.13))
                    
                }
            }
            .frame(height: 155)
            
            VStack {
                TableView()
                
                HStack {
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        VStack {
                            HStack {
                                Text("Montant total HT")
                                
                                Text("AAA")
                            }
                        }
                        
                        VStack {
                            HStack {
                                Text("TVA")
                                
                                Text("AAA")
                            }
                        }
                    }
                    
                }
            }
            .frame(alignment: .topLeading)
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .background(
            .windowBackground
        )
    }
}

#Preview {
//    DisplayPDFView(facture: exempleFacture)
    PDFBodyView()
}

struct CellInGridView: View {
    let color : Color = .green.opacity(0.13)
    
    let titre : String
    let information : String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(titre.uppercased())
                .foregroundStyle(.secondary)
                .font(.subheadline)
                .bold()
            
            Text(information)
        }
        .padding(5)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(color)
    }
}

private struct TableView : View {
    @State private var data = [
        TableData(libelle: "Consultation en oestéopathie", quantity: 1, priceHT: 55, tva: 0, priceTTC: 55),
        TableData(libelle: "Consultation en oestéopathie", quantity: 1, priceHT: 55, tva: 0, priceTTC: 55),
        TableData(libelle: "Consultation en oestéopathie", quantity: 1, priceHT: 55, tva: 0, priceTTC: 55),
    ]
    
    let currencyStyle = Decimal.FormatStyle.Currency(code: "EUR")
    
    var body: some View {
        Table(data) {
            TableColumn("Libellé") { purchase in
                HStack {
                    Image(systemName: "cross.case.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.white, .purple)
                    
                    Text(purchase.libelle)
                }
            }
            
            TableColumn("Qté") { purchase in
                Text(purchase.quantity, format: .number)
                    .multilineTextAlignment(.center)
            }
            .width(60)
            
            TableColumn("Montant HT") { purchase in
                Text(purchase.priceHT, format: currencyStyle)
            }
            .width(100)
            
            TableColumn("TVA") { purchase in
                Text(purchase.tva, format: .percent)
            }
            .width(60)
            
            TableColumn("Montant TTC") { purchase in
                Text(purchase.priceTTC, format: currencyStyle)
                    .foregroundStyle(.primary)
                    .fontWeight(.semibold)
            }
            .width(100)
        }
        .scrollDisabled(true)
    }
}

private struct TableData: Identifiable {
    let libelle: String
    let quantity: Decimal
    let priceHT: Decimal
    let tva: Decimal
    let priceTTC: Decimal
    
    let id = UUID()
}
