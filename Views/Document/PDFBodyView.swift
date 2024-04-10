//
//  PDFBodyView.swift
//  Bordero
//
//  Created by Grande Variable on 08/04/2024.
//

import Foundation
import SwiftUI

struct PDFBodyView : View {
    static let color : Color = .gray.opacity(0.05)
    static let currencyStyle = Decimal.FormatStyle.Currency(code: "EUR")
    
    let data : DocumentData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Image(systemName: "apple.logo")
                        .font(.largeTitle)
                        .padding(.bottom)
                    
                    VStack(alignment: .leading) {
                        Text("\(data.praticien.lastname.uppercased()) \(data.praticien.firstname)")
                        if let tabAddr = data.praticien.adresses as? Set<Adresse> {
                            ForEach(tabAddr.sorted { $0.id < $1.id }, id : \.self) { adresse in
                                Text("\(adresse.rue ?? ""), \(adresse.codepostal ?? "") \(adresse.ville ?? "")")
                            }
                        }
                        Text("\(data.praticien.phone)")
                        Text(verbatim: data.praticien.email)
                            .foregroundStyle(.blue)
                        Text(verbatim: data.praticien.website)
                            .foregroundStyle(.blue)
                    }
                    .font(.caption)
                }
                
                Spacer()
                
                Text(data.optionsDocument.typeDocument.rawValue.capitalized)
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
            
            GridPdfInfoView(data: data)
            
            VStack {
                TableView(data: data.elements)
                
                CoutPartView()
                
                ExtractedView()
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
                .font(.caption2)
                .foregroundStyle(.primary.opacity(0.65))
            
            Text(information)
                .font(.caption)
        }
        .padding(5)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        //        .background(PDFBodyView.color)
    }
}

private struct TableView : View {
    private var dataTab : [TableData]  = []
    
    init(data: [DocumentData.TableElement]) {
        for tableElement in data {
            self.dataTab.append(
                TableData(
                    libelle: tableElement.1.name,
                    quantity: Decimal(tableElement.0),
                    priceHT: Decimal(tableElement.1.price),
                    tva: Decimal(tableElement.1.tva),
                    priceTTC: Decimal(tableElement.1.total)
                )
            )
        }
    }
    var body: some View {
        Grid(
            alignment: .topLeading, horizontalSpacing: 2,
            verticalSpacing: 2
        ) {
            // En-tête
            GridRow {
                Text("Libellé")
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
            .font(.caption)
            .padding(3)
            .foregroundStyle(.primary.opacity(0.65))
            .background(PDFBodyView.color)
            
            // Données
            ForEach(dataTab) { purchase in
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
        .font(.callout)
        
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

struct GridPdfInfoView: View {
    
    let data : DocumentData
    
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
                        CellInGridView(titre: "N° SIRET", information: data.praticien.siret)
                            .gridCellColumns(3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        
                        CellInGridView(titre: "N° ADELI", information: data.praticien.adeli)
                            .gridCellColumns(3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                    }
                    
                    GridRow {
                        CellInGridView(titre: "Date de facture", information: data.optionsDocument.dateCreated.formatted(date: .numeric, time: .omitted))
                            .gridCellColumns(3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        
                        CellInGridView(titre: "N° de document", information: data.optionsDocument.numeroDocument)
                            .gridCellColumns(3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                
                VStack(alignment: .leading) {
                    Text("Adressé à".uppercased())
                        .font(.caption2)
                        .foregroundStyle(.primary.opacity(0.65))
                    
                    HStack {
                        ForEach(data.clients) { client in
                            VStack(alignment: .leading) {
                                Text("\(client.lastname.uppercased())")
                                Text("\(client.firstname)")
                                if let tabAddr = client.adresses as? Set<Adresse> {
                                    ForEach(tabAddr.sorted { $0.id < $1.id }, id : \.self) { adresse in
                                        Text("\(adresse.rue ?? ""), \(adresse.codepostal ?? "") \(adresse.ville ?? "")")
                                    }
                                }
                                Text(client.phone)
                                Text(client.email)
                                    .lineLimit(client.email.count > 50 ? 2 : 1, reservesSpace: true)
                            }
                            Spacer()
                        }
                    }
                    
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .background(PDFBodyView.color)
            .font(.caption)
            .frame(height: 127)
        }
    }
}

struct CoutPartView: View {
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing, spacing: 15) {
                
                RowSousTableView(text: "Sous total", value: "55 €")
                
                RowSousTableView(text: "Montant TVA total", value: "20 %")
                
                Divider()
                
                HStack {
                    Text("Total".uppercased())
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                        .padding(.trailing)
                    
                    Divider()
                    
                    Text("50 €")
                        .font(.title3)
                        .bold()
                        .padding(.leading, 50)
                }
                .frame(height: 20)
                
                Divider()
            }
            .padding()
            
        }
    }
}

struct RowSousTableView: View {
    let text : String
    let value : String
    let isPourcent : Bool = false
    
    var body: some View {
        HStack {
            Text(text)
                .foregroundStyle(.primary.opacity(0.65))
            
            Text(value)
                .bold()
        }
        .font(.callout)
    }
}

#Preview {
    //    DisplayPDFView(facture: exempleFacture, viewModel: PDFViewModel())
    PDFBodyView(data: exempleFacture)
}

struct ExtractedView: View {
    var body: some View {
        HStack(alignment: .top) {
            
            VStack(alignment: .leading) {
                Text("Commentaires : ")
                    .fontWeight(.semibold)
                
                Text("Mode de règlement : Chèques")
            }
            
            Spacer()
            
            VStack {
                Text("A Vann, le 18/04/2020,")
                    .padding()
                
                Image(systemName: "signature")
                    .font(.title)
            }
        }
        .font(.caption)
        .padding()
    }
}
