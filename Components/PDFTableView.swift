//
//  TableView.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI

private struct PDFTableData: Identifiable {
    let libelle: String
    let quantity: Decimal
    let priceHT: Decimal
    let tva: Decimal
    let priceTTC: Decimal
    
    let id = UUID()
}

struct PDFTableView : View {
    private var dataTab : [PDFTableData]  = []
    
    private var sousTot : Decimal = 0
    private var montantTva : Decimal = 0
    private var total : Decimal = 0
    private var remise : Remise
    
    // Memo : TABLE ELEMENT => (quantité, TypeActe object)
    init(data: [TTLTypeActe], remise: Remise) {
        for tableElement in data {
            self.dataTab.append(
                PDFTableData(
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
        
        self.remise = remise
        
        if remise.montant != 0 {
            switch remise.type {
            case .pourcentage:
                total = total / remise.montant
            case .montantFixe:
                total = total - remise.montant
            }
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
                                .fixedSize()
                            
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
            
            CoutPartView(
                remise: remise,
                sousTot: sousTot,
                montantTva: montantTva,
                total: total
            )
            
        }
        .frame(alignment: .topLeading)
        
    }
}
