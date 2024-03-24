//
//  ClientDetailView.swift
//  Bordero
//
//  Created by Grande Variable on 24/03/2024.
//

import SwiftUI

struct ClientDetailView: View {
    @State private var activeSheet: ActiveSheet?
    @ObservedObject var client : Client
    
    var body: some View {
        List {
            HStack(alignment: .top) {
                ProfilImageView(imageData: nil)
                    .frame(height: 80)
                    .font(.system(size: 60))
                
                VStack(alignment: .leading) {
                    Text("\(client.firstname ?? "Inconnu") \(client.name ?? "Inc")")
                        .font(.title2)
                        .bold()
                    
                    if let email = client.email {
                        Text(email.isEmpty ? "Pas d'e-mail enregistrer" : email)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let phone = client.phone {
                        Text(phone.isEmpty ? "Pas de téléphone enregistrer" : phone)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section {
                NavigationLink {
                    EmptyView()
                } label: {
                    Text("Creer un document à partir de ce client")
                        .foregroundStyle(.blue)
                }
                
                Button(role: .destructive) {
                    
                } label: {
                    Text("Supprimer le client")
                    
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
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .editClient(let client):
                FormClientView(activeSheet: $activeSheet, clientToModify: client)
                    .presentationDetents([.large])
            default:
                EmptyView() // IMPOSSIBLE
            }
        }
    }
}

//#Preview {
//    ClientDetailView(client: )
//}
