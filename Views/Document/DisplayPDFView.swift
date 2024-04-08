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
    
    @MainActor
    func renderView(viewSize: CGSize) {
        let renderer = ImageRenderer(content: PDFBodyView().frame(width: viewSize.width, height: viewSize.height, alignment: .center))
        
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
    let facture : Facture
    @ObservedObject var viewModel : PDFViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                if let url = viewModel.generatedPDFURL {
                    PDFKitView(url: url)
                        .edgesIgnoringSafeArea(.all)
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
        }
    }
    
//    func creerPDF(facture: Facture) -> Data? {
//        let pdfMetaData = [
//            kCGPDFContextCreator: "Mon App",
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
//            let titleAttributes = [
//                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)
//            ]
//            
//            // Titre
//            let title = "\(facture.typeDocument == .facture ? "Facture" : "Devis")"
//            title.draw(at: CGPoint(x: 20, y: 20), withAttributes: titleAttributes)
//            
//            // Informations du praticien
//            let praticienInfo = """
//            Numéro Delit: \(facture.praticien.numeroDelit ?? "N/A")
//            Numéro SIREP: \(facture.praticien.numeroSIREP ?? "N/A")
//            Nom: \(facture.praticien.nom ?? "N/A")
//            Adresse: \(facture.praticien.adresse ?? "N/A")
//            Téléphone: \(facture.praticien.telephone ?? "N/A")
//            Email: \(facture.praticien.email ?? "N/A")
//            """
//            praticienInfo.draw(at: CGPoint(x: 20, y: 50), withAttributes: attributes)
//            
//            // Démarrez le rendu des éléments de la facture plus bas
//            var yOffset = 200
//            for utilisateur in facture.utilisateurs {
//                let userInfo = "Utilisateur: \(utilisateur.nom), Adresse: \(utilisateur.adresse)"
//                userInfo.draw(at: CGPoint(x: 20, y: yOffset), withAttributes: attributes)
//                yOffset += 20
//            }
//            
//            // Éléments de la facture
//            let itemsTitle = "Articles:"
//            itemsTitle.draw(at: CGPoint(x: 20, y: yOffset), withAttributes: titleAttributes)
//            yOffset += 30
//            
//            for item in facture.elements {
//                let itemInfo = "\(item.description) - Quantité: \(item.quantite) - Prix Unitaire: \(item.prixUnitaire)€ - Total: \(item.prixTotal)€"
//                itemInfo.draw(at: CGPoint(x: 20, y: yOffset), withAttributes: attributes)
//                yOffset += 20
//            }
//            
//            // Si c'est un devis, ajouter un espace pour la signature
//            if !facture.signature {
//                let signatureInfo = "Signature:"
//                signatureInfo.draw(at: CGPoint(x: 20, y: yOffset + 20), withAttributes: titleAttributes)
//                // Vous pourriez ajouter ici un espace pour une image de signature ou laisser de la place pour une signature manuscrite
//            }
//        }
//        
//        return data
//    }
}

struct PDFBodyView : View {
    static let color : Color = .accentColor.opacity(0.13)
    static let currencyStyle = Decimal.FormatStyle.Currency(code: "EUR")
    
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
                    .background(PDFBodyView.color)
                    
                }
            }
            .frame(height: 155)
            
            VStack {
                TableView()
                
                HStack {
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 20) {
                        RowSousTableView(text: "Sous total", value: "AAA")
                        RowSousTableView(text: "Montant TVA total", value: "20 %")
                        
                        Divider()
                        
                        HStack {
                            Text("Total".uppercased())
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)
                                .padding()
                            
                            Divider()
                            
                            Text("AAA")
                                .padding(.leading, 50)
                        }
                        .font(.title3)
                        .frame(height:40)
                        
                        Divider()
                    }
                }
                
                HStack {
                    Spacer()
                    
                    VStack {
                        Text("A Vann, le 18/04/2020,")
                            .font(.caption)
                            .padding()
                        
                        Image(systemName: "signature")
                            .font(.title)
                    }
                    
                    
                }
                .padding()
                
                
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
        .background(PDFBodyView.color)
    }
}

private struct TableView : View {
    @State private var data = [
        TableData(libelle: "Consultation en oestéopathie", quantity: 1, priceHT: 55, tva: 0, priceTTC: 55),
        TableData(libelle: "Consultation en oestéopathie", quantity: 1, priceHT: 55, tva: 0, priceTTC: 55),
    ]
    
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
            }
            .width(60)
            
            TableColumn("Montant HT") { purchase in
                Text(purchase.priceHT, format: PDFBodyView.currencyStyle)
            }
            .width(100)
            
            TableColumn("TVA") { purchase in
                Text(purchase.tva, format: .percent)
            }
            .width(60)
            
            TableColumn("Montant TTC") { purchase in
                Text(purchase.priceTTC, format: PDFBodyView.currencyStyle)
                    .foregroundStyle(.primary)
                    .fontWeight(.semibold)
            }
            .width(100)
        }
        .frame(height: CGFloat(data.count * 60 + 30)) // Dynamic height
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

struct RowSousTableView: View {
    let text : String
    let value : String
    let isPourcent : Bool = false
    
    var body: some View {
        HStack {
            Text(text)
                .foregroundStyle(.secondary)
            
            Text(value)
                .bold()
            
        }
    }
}
