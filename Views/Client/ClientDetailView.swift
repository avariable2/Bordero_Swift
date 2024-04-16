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
    
    let client : Client
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
            
            if showAdresses, let adresses = client.adresses as? Set<Adresse> {
                ForEach(adresses.sorted { $0.id < $1.id }, id : \.self) { adresse in
                    RowIconColor(
                        text: "\(adresse.rue ?? ""), \(adresse.codepostal ?? "") \(adresse.ville ?? "")",
                        systemName: "house.circle.fill",
                        color: .brown,
                        accessibility: "Adresse renseigné pour le client"
                    )
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = "\(adresse.rue ?? ""), \(adresse.codepostal ?? "") \(adresse.ville ?? "")"
                        }) {
                            Text("Copier")
                            Image(systemName: "doc.on.doc")
                        }
                    }
                    
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
