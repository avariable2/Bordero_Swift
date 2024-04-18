//
//  ClientDetailView.swift
//  Bordero
//
//  Created by Grande Variable on 24/03/2024.
//

import SwiftUI

struct ClientDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var activeSheet: ActiveSheet?
    @ObservedObject var client : Client
    
    var body: some View {
        List {
            ClientDetailHeaderView(client: client)
            
            Section {
                RowIconColor(
                    text: client.email.isEmpty ? "Aucun e-mail renseigné" : client.email,
                    systemName: "envelope.circle.fill",
                    color: .blue,
                    accessibility: "L'e-mail du client"
                )
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = client.email
                    }) {
                        Text("Copier")
                        Image(systemName: "doc.on.doc")
                    }
                }
                
                RowIconColor(
                    text: client.phone.isEmpty ? "Aucun téléphone renseigné" : client.phone,
                    systemName: "phone.circle.fill",
                    color: .green,
                    accessibility: "Le numéro de téléphone du client"
                )
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = client.phone
                    }) {
                        Text("Copier")
                        Image(systemName: "doc.on.doc")
                    }
                }
            }
            
            Section("Historique") {
                Text("Vous trouverez ici dans de futures mise à jour l'ensemble des documents pour ce client. Mais également les restes à payer, ect.")
                    .foregroundStyle(.secondary)
            }
            
        }
        .navigationTitle("Fiche client")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Modifier") {
                    activeSheet = .editClient(client: client)
                }
                .buttonStyle(.bordered)
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .editClient(let client):
                FormClientSheet(onCancel: {
                    activeSheet = nil
                }, onSave: {
                    activeSheet = nil
                }, clientToModify: client) {
                    dismiss()
                }
                .presentationDetents([.large])
            default:
                EmptyView() // IMPOSSIBLE
            }
        }
    }
}

#Preview {
    ClientDetailView(client: Client(firstname: "Adriennne", lastname: "VARY", phone: "0102030405", email: "exemple.vi@gmail.com", context: DataController.shared.container.viewContext))
}

struct ClientDetailHeaderView: View {
    
    @ObservedObject var client : Client
    @State private var showAdresses = false
    
    var body: some View {
        Section {
            ViewThatFits {
                HStack {
                    ProfilImageView(imageData: nil)
                        .font(.title)
                    
                    Text("\(client.firstname) \(client.lastname)")
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                    
                    Image(systemName: showAdresses ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    HStack {
                        ProfilImageView(imageData: nil)
                            .font(.title)
                        
                        Text(client.firstname)
                            .font(.title3)
                            .bold()
                        
                        Text(client.lastname)
                            .font(.title3)
                            .bold()
                        
                    }
                    Image(systemName: showAdresses ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    HStack {
                        ProfilImageView(imageData: nil)
                            .font(.title)
                        Spacer()
                        VStack {
                            Text(client.firstname)
                                .fixedSize()
                                .font(.title3)
                                .bold()
                            
                            Text(client.lastname)
                                .font(.title3)
                                .bold()
                        }
                        .multilineTextAlignment(.center)
                        
                        
                    }
                    
                    Image(systemName: showAdresses ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                        .padding(.top)
                }
            }
            
            if showAdresses {
                
                if let coordonne1 = client.adresse1, !coordonne1.isEmpty {
                    RowAdresse(adresseSurUneLigne: client.getAdresseSurUneLigne(coordonne1))
                }
                if let coordonne2 = client.adresse2, !coordonne2.isEmpty {
                    RowAdresse(adresseSurUneLigne: client.getAdresseSurUneLigne(coordonne2))
                }
                if let coordonne3 = client.adresse3, !coordonne3.isEmpty {
                    RowAdresse(adresseSurUneLigne: client.getAdresseSurUneLigne(coordonne3))
                }
            }
        }
        .onTapGesture {
            withAnimation {
                showAdresses.toggle()
            }
        }
    }
}

struct RowAdresse: View {
    
    let adresseSurUneLigne : String
    
    var body: some View {
        RowIconColor(
            text: adresseSurUneLigne,
            systemName: "house.circle.fill",
            color: .brown,
            accessibility: "Adresse renseigné pour le client"
        )
        .contextMenu {
            Button(action: {
                UIPasteboard.general.string = adresseSurUneLigne
            }) {
                Text("Copier")
                Image(systemName: "doc.on.doc")
            }
        }
    }
}
