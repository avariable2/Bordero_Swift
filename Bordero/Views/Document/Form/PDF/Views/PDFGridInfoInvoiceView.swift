//
//  Test.swift
//  Bordero
//
//  Created by Grande Variable on 11/04/2024.
//

import SwiftUI

struct PDFGridInfoInvoiceView : View {
    let data : PDFModel
    
    var body: some View {
        Grid(alignment: .top, horizontalSpacing: 2, verticalSpacing: 2) {
            GridRow {
                Grid(alignment: .topLeading, horizontalSpacing: 1, verticalSpacing: 1) {
                    GridRow {
                        CellInGridView(titre: "Nom de société") {
                            Text(data.praticien?.nom_proffession ?? "")
                        }
                            .gridCellColumns(5)
                    }
                    
                    GridRow {
                        CellInGridView(titre: "N° SIRET")
                        {
                            Text(data.praticien?.siret ?? "")
                        }
                            .gridCellColumns(3)
                        
                        CellInGridView(titre: "N° ADELI") {
                            Text( data.praticien?.adeli ?? "")
                        }
                            .gridCellColumns(3)
                    }
                    
                    GridRow {
                        CellInGridView(titre: "Date de facture") {
                            Text(data.optionsDocument.dateEmission.formatted(date: .numeric, time: .omitted))
                        }
                            .gridCellColumns(3)
                        
                        CellInGridView(titre: "N° de document") {
                            Text(data.optionsDocument.numeroDocument)
                        }
                            .gridCellColumns(3)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                
                CellInGridView(titre: "Adressé à") {
                    HStack {
                        if let client = data.client {
                            VStack(alignment: .leading) {
                                Text("\(client.lastname.uppercased()) \(client.firstname)")
                                
                                if let coordonne = client.adresse1 {
                                    Text(PDFUtils.getRowAdresse(coordonne).formatted(.list(type: .and, width: .narrow)))
                                }
                                
                                Text(client.phone)
                                Text(client.email)
                                    .lineLimit(client.email.count > 50 ? 2 : 1, reservesSpace: true)
                                
                                if let siret = client.code_entreprise {
                                    Text("Numéro de SIRET : \(siret)")
                                }
                            }
                            Spacer()
                        }
                    }
                }
                
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .background(PDFBodyView.color)
            .font(.caption)
        }
    }
}

struct CellInGridView<Content : View>: View {
    let titre : String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(titre.uppercased())
                .font(.caption2)
                .fixedSize()
                .foregroundStyle(.primary.opacity(0.65))
            
            content
                .font(.caption)
        }
        .padding(5)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

#Preview {
    List {
        PDFGridInfoInvoiceView(data: PDFModel())
    }
}
