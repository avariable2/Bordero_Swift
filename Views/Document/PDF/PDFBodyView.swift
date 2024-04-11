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
    
    let data : PDFModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Image(systemName: "apple.logo")
                        .font(.largeTitle)
                        .padding(.bottom)
                    
                    if let praticien = data.praticien {
                        VStack(alignment: .leading) {
                            Text("\(praticien.lastname.uppercased()) \(praticien.firstname)")
                            if let tabAddr = praticien.adresses as? Set<Adresse>, let coordonne = tabAddr.first, ((coordonne.rue?.isEmpty) == nil) || ((coordonne.ville?.isEmpty) == nil) {
                                Text("\(coordonne.rue ?? ""), \(coordonne.codepostal ?? "") \(coordonne.ville ?? "")")
                            }
                            Text("\(praticien.phone)")
                            Text(verbatim: praticien.email)
                                .foregroundStyle(.blue)
                            Text(verbatim: praticien.website)
                                .foregroundStyle(.blue)
                        }
                        .font(.caption)
                    }
                }
                
                Spacer()
                
                Text(data.optionsDocument.typeDocument.rawValue.capitalized)
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
            
            PDFGridInfoInvoiceView(data: data)
                .frame(height: 140)
            
            TableView(data: data.elements)
            
            PayementEtSignature(data: data)
        }
        .font(.callout)
        .frame(width: 592.2, height: 841.8, alignment: .topLeading)
        .padding()
        .background(
            .windowBackground
        )
    }
}

private struct TableView : View {
    private var dataTab : [TableData]  = []
    
    private var sousTot : Decimal = 0
    private var montantTva : Decimal = 0
    private var total : Decimal = 0
    
    // Memo : TABLE ELEMENT => (quantité, TypeActe object)
    init(data: [TTLTypeActe]) {
        for tableElement in data {
            self.dataTab.append(
                TableData(
                    libelle: tableElement.typeActeReal.name,
                    quantity: Decimal(tableElement.quantity),
                    priceHT: Decimal(tableElement.typeActeReal.price),
                    tva: Decimal(tableElement.typeActeReal.tva),
                    priceTTC: Decimal(tableElement.typeActeReal.total)
                )
            )
            
            sousTot = sousTot + Decimal(tableElement.typeActeReal.price)
            montantTva = montantTva + (Decimal(tableElement.typeActeReal.tva) * Decimal(tableElement.typeActeReal.price))
            total = total + Decimal(tableElement.typeActeReal.total)
        }
    }
    var body: some View {
        VStack {
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
            
            CoutPartView(sousTot: sousTot, montantTva: montantTva, total: total)
            
        }
        .frame(alignment: .topLeading)
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


struct CoutPartView: View {
    
    let sousTot : Decimal
    let montantTva : Decimal
    let total : Decimal
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing, spacing: 15) {
                
                RowSousTableView(text: "Sous total", value: sousTot)
                
                RowSousTableView(text: "Montant TVA", value: montantTva)
                
                Divider()
                
                HStack {
                    Text("Total".uppercased())
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                        .padding(.trailing)
                    
                    Divider()
                    
                    Text(total, format: .currency(code: "EUR"))
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
    let value : Decimal
    let isPourcent : Bool = false
    
    var body: some View {
        HStack {
            Text(text)
                .foregroundStyle(.primary.opacity(0.65))
            
            Text(value, format: .currency(code: "EUR"))
                .bold()
        }
        .font(.callout)
    }
}

struct PayementEtSignature: View {
    let data : PDFModel
    
    var body: some View {
        let praticien = data.praticien
        HStack(alignment: .top) {
            
            VStack(alignment: .leading) {
                Text("Commentaires : ")
                    .fontWeight(.semibold)
                
                if data.optionsDocument.payementAllow.isEmpty {
                    Text("Mode de règlement acceptées : Aucun")
                } else {
                    Text("Mode de règlement acceptées : \(data.optionsDocument.payementAllow.map { $0.rawValue.capitalized }.joined(separator: ", "))")
                }
                
                
                if data.optionsDocument.payementFinish {
                    Text("\(data.optionsDocument.typeDocument.rawValue.capitalized) réglée avec : \(data.optionsDocument.payementUse)")
                }
                
                if data.optionsDocument.afficherDateEcheance {
                    Text("Date d'échéance : \(data.optionsDocument.dateEcheance.formatted(date: .numeric, time: .omitted))")
                }
                
            }
            
            Spacer()
            
            VStack {
                if let tabAddr = praticien?.adresses as? Set<Adresse>, let ville = tabAddr.first?.ville, !ville.isEmpty {
                    Text("A \(ville), le \(data.optionsDocument.dateCreated.formatted(date: .numeric, time: .omitted)),")
                        .padding()
                }
                else {
                   Text("Le \(data.optionsDocument.dateCreated.formatted(date: .numeric, time: .omitted)),")
                       .padding()
               }
                
                if let sign = praticien?.signature, let uiImage = UIImage(data: sign) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                }
            }
        }
        .font(.caption)
        .padding()
    }
}

#Preview() {
    PDFBodyView(data: PDFModel())
}
