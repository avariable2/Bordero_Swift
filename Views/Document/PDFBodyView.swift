//
//  PDFBodyView.swift
//  Bordero
//
//  Created by Grande Variable on 08/04/2024.
//

import Foundation
import SwiftUI

struct PDFBodyView : View {
    static let color : Color = .accentColor.opacity(0.13)
    static let currencyStyle = Decimal.FormatStyle.Currency(code: "EUR")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Image(systemName: "apple.logo")
                        .font(.largeTitle)
                        .padding(.bottom)
                    
                    VStack(alignment: .leading) {
                        Text("VVVV VVV")
                        Text("6 rue du Pasteur")
                        Text("5600 BANNES")
                        Text("06 65 45 56 56")
                        Text("lele.gmail@gmail.com")
                        Text("www.oestopatebretagne.com")
                    }
                    .font(.caption)
                }
                
                Spacer()
                
                Text("Facture")
                    .font(.largeTitle)
                    .bold()
            }
            
            GridPdfInfoView()
            
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
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)
                                .padding()
                            
                            Divider()
                            
                            Text("AAA")
                                .padding(.leading, 50)
                        }
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
        .font(.callout)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .background(
            .windowBackground
        )
    }
}

struct CellInGridView: View {
    let titre : String
    let information : String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(titre.uppercased())
                .foregroundStyle(.secondary)
                .bold()
            
            Text(information)
        }
        .padding(5)
        .frame(maxWidth: .infinity, alignment: .topLeading)
//        .background(PDFBodyView.color)
    }
}

private struct TableView : View {
    @State private var data = [
        TableData(libelle: "Consultation en oestéopathie/Consultation en oestéopathie", quantity: 1, priceHT: 55, tva: 0, priceTTC: 55),
        TableData(libelle: "Consultation en oestéopathie", quantity: 1, priceHT: 55, tva: 0, priceTTC: 55),
    ]

    var body: some View {
        Grid(
            alignment: .topLeading, horizontalSpacing: 2,
            verticalSpacing: 2
        ) {
            // En-tête
            GridRow {
                Text("Libellé")
                    .border(.brown)
                    .gridCellColumns(4)
                
                Text("Qté")
                    .gridCellColumns(1)
                
                Text("HT")
                    .gridCellColumns(1)
                
                Text("TVA")
                    .gridCellColumns(1)
                
                Text("TTC")
                    .gridCellColumns(1)
            }
            .frame(maxWidth: .infinity)
            .font(.callout)
            .padding(5)
            .fontWeight(.semibold)
            .background(Color.gray.opacity(0.2))

            // Données
            ForEach(data) { purchase in
                GridRow {
                    HStack(alignment: .center) {
                        Image(systemName: "cross.case.circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(.white, .purple)
                        
                        Text(purchase.libelle)
                            .lineLimit(purchase.libelle.count > 50 ? 2 : 1, reservesSpace: true)
                            
                    }
                    .gridCellColumns(4)
                    
                    Text("\(purchase.quantity)")
                        .gridCellColumns(1)
                    
                    Text(purchase.priceHT, format: PDFBodyView.currencyStyle)
                        .gridCellColumns(1)
                    
                    Text(purchase.tva, format: .percent)
                        .gridCellColumns(1)
                    
                    Text(purchase.priceTTC, format: PDFBodyView.currencyStyle)
                        .fontWeight(.semibold)
                        .gridCellColumns(1)
                    
                }
                .frame(maxWidth: .infinity)
                .padding([.top, .bottom], 5)
            }
        }
        .frame(maxWidth: .infinity)
        
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

#Preview {
//    DisplayPDFView(facture: exempleFacture, viewModel: PDFViewModel())
        PDFBodyView()
}

struct GridPdfInfoView: View {
    var body: some View {
        Grid(alignment: .top, horizontalSpacing: 2, verticalSpacing: 2) {
            GridRow {
                    Grid(alignment: .topLeading, horizontalSpacing: 1, verticalSpacing: 1) {
                        GridRow {
                            CellInGridView(titre: "Nom de société", information: "Cabinet d'ostéopathie")
                                .gridCellColumns(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                        
                        GridRow {
                            CellInGridView(titre: "N° SIRET", information: "80378752200025")
                                .gridCellColumns(3)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                            
                            CellInGridView(titre: "N° ADELI", information: "220001481")
                                .gridCellColumns(3)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                        
                        GridRow {
                            CellInGridView(titre: "Date de facture", information: "31 aout 2024")
                                .gridCellColumns(3)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                            CellInGridView(titre: "N° de document", information: "20240318004")
                                .gridCellColumns(3)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//                .border(.pink)
                
                VStack(alignment: .leading) {
                    Text("Facturé à".uppercased())
                        .foregroundStyle(.secondary)
                        .bold()
                    
                    Text("Apple S.")
                    Text("San Franscisco")
                    Text("Le bourg")
                    Text("19200 Saint parfois le neuf")
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//                .background(PDFBodyView.color)
//                .border(.pink)
            }
            .background(PDFBodyView.color)
            .font(.caption)
            .frame(height: 127)
        }
    }
}
