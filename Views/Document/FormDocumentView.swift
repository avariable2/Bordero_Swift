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

struct ModifierDocumentView: View {
    
    @State private var clients = [Client]()
    
    @State private var payWithStripe: Bool = false
    @State private var payWithPaypal: Bool = false
    @State private var notes: String = ""
    
    var body: some View {
        VStack {
            
            Form {
                Section {
                    NavigationLink {
                        FormPraticienView()
                    } label: {
                        Label("Vos coordonnées", systemImage: "stethoscope")
                    }
                }
                
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
                    }
                } header: {
                    Text("Client(s) séléctionné(s)")
                } footer: {
                    Text("Vous pouvez ajouter autant de clients que nécessaires.")
                }
                
                NavigationLink {
                    DetailFormView()
                } label: {
                    Text("Détails")
                }
                
                Section {
                    NavigationLink {
                        EmptyView()
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
                
                NavigationLink {
                    
                } label: {
                    Label("Joindre des photos", systemImage: "paperclip")
                }
                
            }
            .navigationTitle("Facture 001")
        }
    }
}

#Preview {
    FormDocumentView()
}
