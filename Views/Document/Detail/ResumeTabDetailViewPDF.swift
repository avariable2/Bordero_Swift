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
    @State var documentData : PDFModel
    
    func determineStatut() -> String {
        let typesPresent = Set(documentData.historique.map { $0.nom })
        
        // Vérifier si l'événement 'payer' est présent
        if typesPresent.contains(.payer) {
            return "Payer"
        }
        
        // Vérifier si l'événement 'envoie' est présent
        if typesPresent.contains(.envoie) {
            return "Envoyée"
        }
        
        // Si ni 'envoie' ni 'payer' ne sont présents
        return "Créer"
    }
    
    func determineColor(_ text : String) -> Color {
        return switch text {
        case "Payer": .purple
        case "Envoyée": .blue
        default : .green
        }
    }
    
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
                .sheet(item: $presentURL) { url in
                    SafariView(url: url)
                }
                
                Section {
                    NavigationLink {
                        if let client = documentData.client {
                            ClientDetailView(client: client)
                        }
                    } label: {
                        HStack {
                            ProfilImageView(imageData: nil)
                                .font(.title)
                            
                            if let client = documentData.client {
                                Text("\(client.firstname) \(client.lastname)")
                                    .font(.title2)
                                    .bold()
                            }
                        }
                    }
                } header: {
                    Text("Client")
                }
                
                Section {
                    HStack {
                        let status = determineStatut()
                        Image(systemName: "waveform.path.ecg")
                            .imageScale(.large)
                            .foregroundStyle(.pink)
                        
                        HStack {
                            Text("Status")
                                .font(.title3)
                            
                            Spacer()
                            
                            Text(status)
                                .padding(5)
                                .background(RoundedRectangle(cornerRadius: 25)
                                    .foregroundStyle(determineColor(status))
                                )
                                .foregroundStyle(.white)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "eurosign.circle")
                            .imageScale(.large)
                            .foregroundStyle(.blue)
                        
                        HStack {
                            Text("Reste à payé")
                                .font(.title3)
                            
                            Spacer()
                            
                            Text(30, format: .currency(code: "EUR"))
                        }
                    }
                    
                    RowInformationDate(
                        logo: "calendar.badge.clock",
                        titre: "Date d'émission",
                        color: .yellow
                    )
                    
                    RowInformationDate(
                        logo: "calendar.badge.exclamationmark",
                        titre: "Date d'échéance",
                        color: .red.opacity(0.9)
                    )
                } header: {
                    Text("Informations")
                }
                
                Section {
                    RowMontantDetail(text: "Total H.T.", price: documentData.calcTotalHT())
                    RowMontantDetail(text: "T.V.A", price: documentData.calcTotalTVA())
                    RowMontantDetail(text: "Total T.T.C", price: documentData.calcTotalTTC())
                        .bold()
                } header: {
                    Text("Détail")
                }
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
            
            VStack(alignment: .leading) {
                Text(titre)
                    .font(.title3)
                
                Text(Date(), format: .dateTime)
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
