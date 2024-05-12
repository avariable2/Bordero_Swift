//
//  SwiftUIView.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI
import SafariServices

struct ResumeTabDetailViewPDF: View {
    @State var presentURL: URL? = nil
    @ObservedObject var document : Document
    
    @State var showSheetPayement = false
    
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
                                Text("Le client n'à pas été retrouvé ou bien à été supprimer.")
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
                        Text("Status")
                        
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
                        Text("Reste à payé")
                        
                        Spacer()
                        
                        Text(document.totalTTC - document.montantPayer, format: .currency(code: "EUR"))
                            .fontWeight(.semibold)
                    }
                    
                    RowInformationDate(
                        logo: "calendar.circle.fill",
                        titre: "Date d'émission",
                        date: document.dateEmission,
                        color: .cyan
                    )
                    
                    RowInformationDate(
                        logo: "calendar.circle.fill",
                        titre: "Date d'échéance",
                        date: document.dateEcheance,
                        color: .purple
                    )
                } header: {
                    Text("Informations")
                }
                
                Section {
                    RowMontantDetail(text: "Total H.T.", price: document.totalHT)
                    RowMontantDetail(text: "T.V.A", price: document.totalTVA)
                    RowMontantDetail(text: "Total T.T.C", price: document.totalTTC)
                } header: {
                    Text("Détails")
                }
            }
            .sheet(item: $presentURL) { url in
                SafariView(url: url)
            }
            .sheet(isPresented: $showSheetPayement) {
                NavigationView {
                    PayementSheet()
                }
                .presentationDetents([.medium])
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Button {
                        
                    } label: {
                        Label("Envoyer", systemImage: "paperplane.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        showSheetPayement = true
                    } label: {
                        Text("Ajouter un paiement")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
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

struct RowInformationDate: View {
    
    let logo : String
    let titre : String
    let date: Date
    let color: Color
    
    var body: some View {
        HStack {
            
            HStack() {
                Text(titre)
                
                Spacer()
                
                Text(date, format: .dateTime.day().month().year())
                    .fontWeight(.light)
            }
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
