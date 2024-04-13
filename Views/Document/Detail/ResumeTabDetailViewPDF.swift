//
//  SwiftUIView.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI

struct ResumeTabDetailViewPDF: View {
    let client : Client
    var body: some View {
        VStack {
            GroupBox {
                VStack(alignment: .leading) {
                    Text("En france, la loi contre la fraude ne permet pas la modification ou la suppression d'une facture déjà envoyée ou exportée.")
                    
                    Text("En savoir plus")
                        .foregroundStyle(.link)
                }
            }
            .padding([.leading, .trailing])
            
            Form {
                Section {
                    HStack {
                        ProfilImageView(imageData: nil)
                            .font(.title)
                        
                        Text("\(client.firstname) \(client.lastname)")
                            .font(.title2)
                            .bold()
                    }
                } header: {
                    Text("Client")
                }
                
                Section {
                    RowInformationDate(
                        logo: "doc.badge.clock.fill",
                        titre: "Date de création",
                        color: .yellow
                    )
                    
                    RowInformationDate(
                        logo: "clock.badge.exclamationmark.fill",
                        titre: "Date d'échéance",
                        color: .red.opacity(0.9)
                    )
                } header: {
                    Text("Informations")
                }
                
                Section {
                    RowMontantDetail(text: "Total H.T.", price: 30)
                    RowMontantDetail(text: "T.V.A", price: 0)
                    RowMontantDetail(text: "Total T.T.C", price: 30)
                }
            }
            .headerProminence(.increased)
        }
    }
}

struct RowMontantDetail: View {
    let text : String
    let price : Decimal
    
    var body: some View {
        HStack {
            Text(text.uppercased())
                .foregroundStyle(.secondary)
                .font(.caption)
            
            Spacer()
            
            Text(price, format: .currency(code: "EUR"))
        }
    }
}

struct RowInformationDate: View {
    
    let logo : String
    let titre : String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: logo)
                .symbolRenderingMode(.palette)
                .foregroundStyle(color, .gray.opacity(0.7))
                .imageScale(.large)
            
            VStack {
                Text(titre)
                    .font(.title3)
                
                Text(Date(), format: .dateTime)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ResumeTabDetailViewPDF(client: Client(firstname: "Adriennne", lastname: "VARY", phone: "0102030405", email: "exemple.vi@gmail.com", context: DataController.shared.container.viewContext))
}
