//
//  SwiftUIView.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI
import SafariServices
import MessageUI
import PDFKit

enum ErrorDocument : Identifiable {
    case failToConvertIntoFacture
    var id: Self { self }
}

struct ResumeTabDetailViewPDF: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: []) var praticien: FetchedResults<Praticien>
    
    @State var presentURL: URL? = nil
    @ObservedObject var document : Document
    
    
    var body: some View {
        VStack {
            Form {
                Section {
                    VStack(alignment: .center, spacing: 20) {
                        
                        GroupBox {
                            ScrollView(.vertical, showsIndicators: true) {
                                Text("En france, la loi contre la fraude ne permet pas la modification ou la suppression d'une facture déjà envoyée ou exportée.")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxHeight: 65)
                            
                            Button {
                                presentURL = URL(string: "https://www.legifrance.gouv.fr/codes/id/LEGISCTA000006191855")!
                            } label: {
                                Text("En savoir plus")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.link)
                            }
                            
                        } label: {
                            Label("Loi Française", systemImage: "building.columns")
                                .tint(.primary)
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
                } header: {
                    Text("Attention")
                }
                
                Section {
                    Button {
                        
                    } label: {
                        if let client = document.client_ {
                            ClientRowView(firstname: client.firstname, name: client.lastname)
                                .tint(.primary)
                        } else {
                            Label {
                                Text("Le client n'a pas été retrouvé ou bien a été supprimé.")
                                    .fontWeight(.regular)
                            } icon: {
                                Image(systemName: "person.crop.circle.badge.questionmark.fill")
                                    .foregroundStyle(.yellow, .gray)
                                    .imageScale(.large)
                            }
                            .tint(.primary)
                        }
                    }
                    
                } header: {
                    Text("Créer pour")
                }
                
                Section {
                    HStack {
                        Text("Statut")
                        Spacer()
                        HStack(spacing: nil) {
                            Image(systemName: "circle.circle.fill")
                                .foregroundStyle(.black, document.determineColor())
                            Text(document.determineStatut())
                                .foregroundStyle(.primary)
                                .fontWeight(.light)
                        }
                    }
                    
                    HStack {
                        Text("Reste à payer")
                        Spacer()
                        Text(document.resteAPayer, format: .currency(code: "EUR"))
                            .fontWeight(.semibold)
                    }
                    
                    LabeledContent("Date d'émission") {
                        Text(document.dateEmission.formatted(.dateTime.day().month().year()))
                            .foregroundStyle(.primary)
                            .fontWeight(.light)
                    }
                    
                    LabeledContent("Date d'échéance") {
                        Text(document.dateEcheance.formatted(.dateTime.day().month().year()))
                            .foregroundStyle(.primary)
                            .fontWeight(.light)
                    }
                } header: {
                    Text("Informations")
                }
                
                Section {
                    RowMontantDetail(text: "Total H.T.", price: document.totalHT)
                    RowMontantDetail(text: "TVA", price: document.totalTVA)
                    RowMontantDetail(text: "Total T.T.C.", price: document.totalTTC)
                } header: {
                    Text("Détails")
                }
            }
            .sheet(item: $presentURL) { url in
                SafariView(url: url)
            }
            
        }
    }
}

struct RowMontantDetail: View {
    let text : String
    let price : Double
    
    var body: some View {
        HStack {
            Text(text.uppercased())
                .foregroundStyle(.secondary)
                .font(.caption)
            
            Spacer()
            
            Text(price, format: .currency(code: "EUR"))
                .fontWeight(.light)
        }
    }
}

#Preview {
    ResumeTabDetailViewPDF(document: Document.example)
}

extension URL: Identifiable {
    public var id: String {
        self.absoluteString
    }
}
