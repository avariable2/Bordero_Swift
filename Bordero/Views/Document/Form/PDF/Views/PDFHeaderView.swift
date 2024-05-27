//
//  PDFHeaderView.swift
//  Bordero
//
//  Created by Grande Variable on 24/04/2024.
//

import SwiftUI

struct HeaderPDFView : View {
    
    let data: PDFModel
    
    var body: some View {
        HStack(alignment: .top) {
            if let praticien = data.praticien {
                HStack {
                    if let data = praticien.logoSociete, let uiImage = UIImage(data: data) {
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 140, alignment: .leading)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(praticien.lastname.uppercased()).bold()
                        + Text(" ")
                        + Text(praticien.firstname)
                        
                        if let coordonne = praticien.adresse1, !coordonne.isEmpty {
                            Text(PDFUtils.getRowAdresse(coordonne).formatted(.list(type: .and, width: .narrow)))
                        }
                        
                        if !praticien.phone.isEmpty {
                            Text(praticien.phone)
                        }
                        
                        if !praticien.email.isEmpty {
                            Text(verbatim: praticien.email)
                        }
                        
                        if !praticien.website.isEmpty {
                            Text(verbatim: praticien.website)
                        }
                        
                        Spacer()
                    }
                    .font(.caption)
                    .frame(maxHeight: 140)
                    
                    Spacer()
                }
                .frame(maxWidth: 350)
            }
            
            Spacer()
            
            Text(data.optionsDocument.estFacture ? "Facture" : "Devis")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
        }
        .font(.callout)
    }
}

#Preview {
    HeaderPDFView(data: PDFModel())
}
