//
//  TableView.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI

struct PDFTableData: Identifiable {
    let libelle: String
    let infoLibelle : String
    let remarque : String
    let quantity: Double
    let priceHT: Double
    let tva: Double
    let priceTTC: Double
    
    let id = UUID()
}

struct PDFTableView : View {
    private var dataTab : [PDFTableData]  = []
    
    private var sousTot : Double = 0
    private var montantTva : Double = 0
    private var total : Double = 0
    private var remise : Remise
    
    // Memo : TABLE ELEMENT => (quantité, date, TypeActe object)
    init(data: [SnapshotTypeActe], remise: Remise) {
        for tableElement in data {
            
            var libelleFinalAvecOuSansDate = tableElement.name
            if !Calendar.current.isDateInToday(tableElement.date) {
                libelleFinalAvecOuSansDate.append(" du \(tableElement.date.formatted(.dateTime.day().month().year()))")
            }
            
            self.dataTab.append(
                PDFTableData(
                    libelle: libelleFinalAvecOuSansDate,
                    infoLibelle: tableElement.info,
                    remarque: tableElement.remarque,
                    quantity: tableElement.quantity,
                    priceHT: tableElement.price,
                    tva: tableElement.tva,
                    priceTTC: tableElement.total
                )
            )
            
            sousTot = sousTot + tableElement.price
            montantTva = montantTva + (tableElement.tva * tableElement.price)
            
            total = total + tableElement.total
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
            TableHeaderView()
            
            // Données
            ForEach(dataTab) { purchase in
                TableGridRowView(purchase: purchase)
            }
            
            CoutPartView(
                remise: remise,
                sousTot: sousTot,
                montantTva: montantTva,
                total: total
            )
            
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        
    }
}

struct TableGridRowView : View {
    let purchase : PDFTableData
    
    var body: some View {
        Grid(
            alignment: .topLeading, horizontalSpacing: 2,
            verticalSpacing: 2
        ) {
            GridRow {
                VStack(alignment: .leading) {
                    Text(purchase.libelle)
                    
                    if !purchase.infoLibelle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(purchase.infoLibelle)
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }
                    
                    if !purchase.remarque.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Remarques : ")
                            .foregroundStyle(.primary.opacity(0.8)).fontWeight(.medium)
                        +
                        Text(purchase.remarque)
                            .foregroundStyle(.primary.opacity(0.8))
                            .font(.footnote)
                    }
                    
                }
                .frame(maxWidth: 315)
                
                Text(purchase.quantity, format: .number.precision(.fractionLength(2)))
                    .frame(maxWidth: 65)
                
                Text(purchase.priceHT.formatted(.currency(code: "EUR")))
                    .frame(maxWidth: 70)
                
                Text(purchase.tva, format: .percent)
                    .frame(maxWidth: 70)
                
                Text(purchase.priceTTC.formatted(.currency(code: "EUR")))
                    .fontWeight(.semibold)
                    .frame(maxWidth: 70)
                
            }
            .padding([.top, .bottom], 5)
        }
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

#Preview {
    ScrollView {
        TableGridRowView(purchase: PDFTableData(libelle: "Je", infoLibelle: "Une potentielle description pour illustrer notre exemple", remarque: "", quantity: 1, priceHT: 50, tva: 2, priceTTC: 50))
            .border(Color.black)
    }
    .frame(width: 600)
    .border(Color.red)
    
}

struct TableHeaderView: View {
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
                
                Text("H.T.")
                    .gridCellColumns(1)
                
                Text("TVA")
                    .gridCellColumns(1)
                
                Text("T.T.C.")
                    .gridCellColumns(1)
            }
            .frame(maxWidth: .infinity)
            .font(.caption)
            .padding(3)
            .foregroundStyle(.primary.opacity(0.65))
            .background(PDFBodyView.color)
            
            
        }
        .frame(maxWidth: .infinity)
        .font(.callout)
    }
}
