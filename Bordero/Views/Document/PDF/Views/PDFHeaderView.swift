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
                            .frame(maxWidth: 150, maxHeight: 140)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(praticien.lastname.uppercased()).bold()
                            + Text(" ")
                            + Text(praticien.firstname)
                        
                        if let coordonne = praticien.adresse1 {
                            Text(PDFUtils.getRowAdresse(coordonne).formatted(.list(type: .and, width: .narrow)))
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
