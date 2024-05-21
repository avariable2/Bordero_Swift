//
//  PDFPayementAndSignature.swift
//  Bordero
//
//  Created by Grande Variable on 10/05/2024.
//

import SwiftUI

struct PDFPayementAndSignature: View {
    let data : PDFModel
    
    var body: some View {
        let praticien = data.praticien
        HStack(alignment: .top) {
            
            VStack(alignment: .leading) {
                Text("Commentaires : ")
                    .fontWeight(.semibold)
                
                if praticien?.paramsDocument.showModePaiement ?? true {
                    if data.optionsDocument.payementAllow.isEmpty {
                        Text("Mode de règlement acceptées : Aucun")
                    } else {
                        Text("Mode de règlement acceptées : \(data.optionsDocument.payementAllow.map { $0.rawValue }.joined(separator: ", "))")
                    }
                }
                
                if data.optionsDocument.payementFinish && data.optionsDocument.estFacture {
                    Text("Facture réglée avec : \(data.optionsDocument.payementUse.rawValue)")
                }
                
                if data.optionsDocument.afficherDateEcheance && (praticien?.paramsDocument.showDateEcheance ?? true) {
                    Text("Date d'échéance : \(data.optionsDocument.dateEcheance.formatted(date: .numeric, time: .omitted))")
                }
                
                if !data.optionsDocument.note.isEmpty {
                    Text("Note: \(data.optionsDocument.note)")
                }
                
            }
            
            Spacer()
            
            VStack {
                if let adresse1 = praticien?.adresse1, let ville : String = adresse1["ville"] as? String, !ville.isEmpty {
                    Text("A \(ville), le \(data.optionsDocument.dateEmission.formatted(date: .numeric, time: .omitted)),")
                        .padding()
                } else {
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
