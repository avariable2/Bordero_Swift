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
    
    @State private var showAdresses = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    ProfilImageView(imageData: nil)
                        .frame(height: 40)
                        .font(.system(size: 30))
                    
                    
                    Text("\(client.firstname ?? "Inconnu") \(client.name ?? "Inc")")
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                    
                    Image(systemName: showAdresses ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
                .onTapGesture {
                    withAnimation {
                        showAdresses.toggle()
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
                        
                    }
                }
            }
            
            Section {
                if let email = client.email {
                    RowIconColor(
                        text: email.isEmpty ? "Aucun e-mail renseigné" : email,
                        systemName: "envelope.circle.fill",
                        color: .blue,
                        accessibility: "L'e-mail du client"
                    )
                }
                
                if let phone = client.phone {
                    RowIconColor(
                        text: phone.isEmpty ? "Aucun téléphone renseigné" : phone,
                        systemName: "phone.circle.fill",
                        color: .green,
                        accessibility: "Le numéro de téléphone du client"
                    )
                }
            }
            
            Section {
                NavigationLink {
                    EmptyView()
                } label: {
                    Text("Creer un document à partir de ce client")
                        .foregroundStyle(.blue)
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
                FormClientView(activeSheet: $activeSheet, clientToModify: client) {
                    dismiss()
                }
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
