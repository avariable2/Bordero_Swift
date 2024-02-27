//
//  FormDocumentView.swift
//  Bordero
//
//  Created by Grande Variable on 12/02/2024.
//

import SwiftUI

struct FormDocumentView: View {
    var body: some View {
        ModifierDocumentView()
    }
}

struct ModifierDocumentView: View, Saveable, Versionnable {
    func getVersion() -> Int32 {
        return 1
    }
    
    
    @State private var clients = [Client]()
    @State private var listTypeActes = [TypeActe]()
    
    @State private var payWithStripe: Bool = false
    @State private var payWithPaypal: Bool = false
    @State private var notes: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            TitleDocumentComponentView()
                .background(Color(uiColor: .secondarySystemBackground))
            
            Form {
                
                Section {
                    NavigationLink {
                        ListClients(callbackClientClick: { client in
                            clients.append(client)
                        })
                    } label: {
                        Label("Ajouter un client", systemImage: "plus.circle")
                    }
                    
                    List {
                        ForEach(clients) { client in
                            VStack {
                                Text(client.firstname ?? "Inconnu")
                                + Text(" ")
                                + Text(client.name ?? "")
                                    .bold()
                            }
                        }
                        .onDelete(perform: delete)
                    }
                } header: {
                    Text("Client(s) séléctionné(s)")
                } footer: {
                    Text("Swipe sur la gauche pour supprimer un client de la liste.")
                }
                
                Section {
                    NavigationLink {
                        ListTypeActeToAddView()
                    } label: {
                        Label("Ajouter un type d'acte", systemImage: "plus.circle")
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Total H.T.")
                            Spacer()
                            Text("0,00 €")
                        }
                        
                        HStack {
                            Text("TVA")
                            Spacer()
                            Text("0,00 €")
                        }
                        
                        HStack {
                            Text("Total T.TC")
                            Spacer()
                            Text("0,00 €")
                        }
                        .bold()
                    }
                }
                
                Section("Options de paiement") {
                    NavigationLink {
                        
                    } label: {
                        Text("Virement banacaire")
                    }
                    
                    Toggle("Stripe - paiements par carte", isOn: $payWithStripe)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    Toggle("Paypal", isOn: $payWithPaypal)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
                
                Section("Note - Optionnel") {
                    TextEditor(text: $notes)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func delete(at offsets: IndexSet) {
        clients.remove(atOffsets: offsets)
    }
    
    func save() {
        
    }
}

#Preview {
    FormDocumentView()
}
