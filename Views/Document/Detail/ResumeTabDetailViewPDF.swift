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
    @State var document : Document
    
    @State var showDetailClient = false
    @State var client : Client? = nil
    
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
                            
                            Text("En savoir plus")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.link)
                            
                        } label: {
                            Button {
                                presentURL = URL(string: "https://www.legifrance.gouv.fr/codes/id/LEGISCTA000006191855")!
                            } label: {
                                Label("Rappel à la loi", systemImage: "building.columns")
                                    .tint(.primary)
                            }
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
                } header: {
                    Text("Attention")
                }
                
                Section {
                    Button {
                        showDetailClient = true
                    } label: {
                        HStack {
                            ProfilImageView(imageData: nil)
                                .font(.title)
                            
                            Text("\(document.snapshotClient.firstname) \(document.snapshotClient.lastname)")
                                .font(.title2)
                                .bold()
                        }
                    }
                } header: {
                    Text("Client")
                }
                
                Section {
                    HStack {
                        Image(systemName: "heart.circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(.white, .pink)
                        
                        HStack {
                            Text("Status")
                                .font(.title3)
                            
                            Spacer()
                            
                            Text(document.determineStatut())
                                .padding(5)
                                .background(RoundedRectangle(cornerRadius: 25)
                                    .foregroundStyle(document.determineColor())
                                )
                                .foregroundStyle(.white)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "creditcard.circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(.white, .yellow)
                        
                        HStack {
                            Text("Reste à payé")
                                .font(.title3)
                            
                            Spacer()
                            
                            Text(document.totalTTC - document.montantPayer, format: .currency(code: "EUR"))
                        }
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
                        .bold()
                } header: {
                    Text("Détail")
                }
            }
            .sheet(item: $presentURL) { url in
                SafariView(url: url)
            }
            .headerProminence(.increased)
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Button {
                        
                    } label: {
                        Label("Envoyer", systemImage: "paperplane.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        
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
            .navigationDestination(isPresented: $showDetailClient) {
                if client != nil {
                    ClientDetailView(client: client!)
                }
                
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
            Image(systemName: logo)
                .symbolRenderingMode(.palette)
                .foregroundStyle(color, .gray.opacity(0.7))
                .imageScale(.large)
            
            VStack(alignment: .leading) {
                Text(titre)
                    .font(.title3)
                
                Text(date, format: .dateTime.day().month().year())
                    .foregroundStyle(.secondary)
            }
        }
    }
}

//#Preview {
//    ResumeTabDetailViewPDF(client: Client(firstname: "Adriennne", lastname: "VARY", phone: "0102030405", email: "exemple.vi@gmail.com", context: DataController.shared.container.viewContext))
//}

extension URL: Identifiable {
    public var id: String {
        self.absoluteString
    }
}
