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
    
    var isLate: Bool {
        document.dateEcheance <= Date() && document.status == .send
    }
    
    var body: some View {
        VStack {
            Form {
                
                #if DEBUG
                Text("ID du document : \(String(describing: document.id_?.uuidString))")
                #endif
                
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
                    ClientRowView(client: $document.client_)
                        .tint(.primary)
                } header: {
                    Text("Créer pour")
                }
                
                Section {
                    HStack {
                        Text("Statut")
                        Spacer()
                        HStack(spacing: nil) {
                            
                            IconStatusDocument(status: document.status)
                            
                            Text(document.determineStatut().rawValue)
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
                        if isLate {
                            Image(systemName: "hourglass.tophalf.filled")
                                .foregroundStyle(.pink)
                        }
                        
                        Text(document.dateEcheance.formatted(.dateTime.day().month().year()))
                            .foregroundStyle(.primary)
                            .fontWeight(.light)
                    }
                    .foregroundStyle(isLate ? .red : .primary)
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
