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
                        CellInGridView(titre: "Nom de société", information: "Cabinet d'ostéopathie")
                            .gridCellColumns(6)
                    }
                    
                    GridRow {
                        CellInGridView(titre: "N° SIRET", information: data.praticien?.siret ?? "")
                            .gridCellColumns(3)
                        
                        CellInGridView(titre: "N° ADELI", information: data.praticien?.adeli ?? "")
                            .gridCellColumns(3)
                    }
                    
                    GridRow {
                        CellInGridView(titre: "Date de facture", information: data.optionsDocument.dateCreated.formatted(date: .numeric, time: .omitted))
                            .gridCellColumns(3)
                        
                        CellInGridView(titre: "N° de document", information: data.optionsDocument.numeroDocument)
                            .gridCellColumns(3)
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
    }
}

#Preview {
    List {
        PDFGridInfoInvoiceView(data: PDFModel())
    }
    
}
