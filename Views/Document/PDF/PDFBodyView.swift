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
            
            PayementEtSignature(data: data)
        }
        .background(
            .windowBackground
        )
    }
}

struct HeaderPDFView : View {
    
    let data: PDFModel
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Image(systemName: "apple.logo")
                    .font(.largeTitle)
                    .padding(.bottom)
                
                if let praticien = data.praticien {
                    VStack(alignment: .leading) {
                        Text("\(praticien.lastname.uppercased()) \(praticien.firstname)")
                        if let tabAddr = praticien.adresses as? Set<Adresse>, let coordonne = tabAddr.first {
                            
                            Text(getTableauInfoAdresse(coordonne).formatted(.list(type: .and, width: .narrow)))
                        }
                        Text(praticien.phone)
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
        .font(.callout)
    }
    
    func getTableauInfoAdresse(_ coordonne : Adresse) -> [String] {
        var tab : [String] = []
        if let rue = coordonne.rue, !rue.isEmpty {
            tab.append(rue)
        }
        if let codepostal = coordonne.codepostal, !codepostal.isEmpty {
            tab.append(codepostal)
        }
        if let etageAppt = coordonne.etageAppt, !etageAppt.isEmpty {
            tab.append(etageAppt)
        }
        if let ville = coordonne.ville, !ville.isEmpty {
            tab.append(ville)
        }
        
        return tab
    }
}

struct CoutPartView: View {
    
    let remise : Remise
    let sousTot : Decimal
    let montantTva : Decimal
    let total : Decimal
    
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
    let value : Decimal
    var isPourcent : Bool
    
    init(text: String, value: Decimal, isPourcent : Bool = false) {
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
                    Text("Mode de règlement acceptées : \(data.optionsDocument.payementAllow.map { $0.rawValue }.joined(separator: ", "))")
                }
                
                if data.optionsDocument.payementFinish && data.optionsDocument.typeDocument == .facture {
                    Text("\(data.optionsDocument.typeDocument.rawValue.capitalized) réglée avec : \(data.optionsDocument.payementUse)")
                }
                
                if data.optionsDocument.afficherDateEcheance {
                    Text("Date d'échéance : \(data.optionsDocument.dateEcheance.formatted(date: .numeric, time: .omitted))")
                }
                
                if !data.optionsDocument.note.isEmpty {
                    Text("Note: \(data.optionsDocument.note)")
                }
                
            }
            
            Spacer()
            
            VStack {
                if let tabAddr = praticien?.adresses as? Set<Adresse>, let ville = tabAddr.first?.ville, !ville.isEmpty {
                    Text("A \(ville), le \(data.optionsDocument.dateEmission.formatted(date: .numeric, time: .omitted)),")
                        .padding()
                }
                else {
                   Text("Le \(data.optionsDocument.dateEmission.formatted(date: .numeric, time: .omitted)),")
                       .padding()
               }
                
                if let sign = praticien?.signature, let uiImage = UIImage(data: sign) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .frame(maxHeight: 60)
                }
                    
            }
        }
        .font(.caption)
        .padding(.top)
    }
}

#Preview() {
    PDFBodyView(data: PDFModel())
        .frame(width: 600)
}
