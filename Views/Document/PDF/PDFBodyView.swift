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
    static let currencyStyle = Decimal.FormatStyle.Currency(code: "EUR").locale(.current)
    
    let data : PDFModel
    
    var body: some View {
        VStack() {
            HeaderPDFView(data: data)
                .frame(height: 160)
            
            PDFGridInfoInvoiceView(data: data)
                .frame(height: 140)
            
            PDFTableView(data: data.elements, remise: data.optionsDocument.remise)
            
            PDFPayementAndSignature(data: data)
        }
        .background(
            .windowBackground
        )
    }
}

struct CoutPartView: View {
    
    let remise : Remise
    let sousTot : Double
    let montantTva : Double
    let total : Double
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing) {
                
                RowSousTableView(text: "Sous total", value: sousTot)
                
                if remise.montant != 0 {
                    switch remise.type {
                    case .pourcentage:
                        
                        RowSousTableView(text: "Taux de remise", value: remise.montant, isPourcent: true)
//                            
//                        RowSousTableView(text: "Montant de remise", value: sousTot * remise.montant)
                        
                    case .montantFixe:
                        RowSousTableView(text: "Remise", value: remise.montant)
                    }
                }
                
                RowSousTableView(text: "Montant TVA", value: montantTva)
                
                Divider()
                
                HStack {
                    Text("Total".uppercased())
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                        .padding(.trailing)
                    
                    Divider()
                    
                    Text(total.formatted(.currency(code: "EUR")))
                        .font(.body)
                        .bold()
                        .padding(.leading, 50)
                }
                .frame(height: 20)
                
                Divider()
            }
        }
        .font(.callout)
    }
}

struct RowSousTableView: View {
    let text : String
    let value : Double
    var isPourcent : Bool
    
    init(text: String, value: Double, isPourcent : Bool = false) {
        self.text = text
        self.value = value
        self.isPourcent = isPourcent
    }
    
    var body: some View {
        HStack {
            Text(text)
                .foregroundStyle(.primary.opacity(0.65))
            
            if isPourcent {
                Text(value, format: .percent)
                    .bold()
            } else {
                Text(value.formatted(.currency(code: "EUR")))
                    .bold()
            }
            
        }
        .font(.caption)
    }
}



#Preview() {
    PDFBodyView(data: PDFModel())
        .frame(width: 600)
}
