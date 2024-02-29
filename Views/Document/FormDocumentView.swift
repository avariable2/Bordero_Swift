//
//  FormDocumentView.swift
//  Bordero
//
//  Created by Grande Variable on 12/02/2024.
//

import SwiftUI
import ScrollableGradientBackground

struct FormDocumentView: View {
    var body: some View {
        NavigationStack {
            ModifierDocumentView()
        }
        
    }
}

struct ModifierDocumentView: View, Saveable, Versionnable {
    enum TypeDoc : String, CaseIterable, Identifiable {
        case facture, devis
        
        var id: Self { self }
    }
    
    static func getVersion() -> Int32 {
        return 1
    }
    
    @State private var clients = [Client]()
    @State private var listTypeActes = [TypeActe]()
    
    @State private var docIsFacture: Bool = true
    @State private var estPayer: Bool = false
    @State private var notes: String = ""
    @State private var typeSelected : TypeDoc = .facture
    
    @State var numero : String = "001"
    
    var body: some View {
        
        VStack(spacing: 0) {
            Form {
                Section {
                    
                    Picker("Type de document", selection: $typeSelected.animation()) {
                        ForEach(TypeDoc.allCases) { type in
                            Text(type.rawValue.capitalized)
                                .font(.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    LabeledContent("Numéro de facture : ") {
                        TextField("001", text: $numero.animation())
                            .textFieldStyle(.roundedBorder)
                        
                    }
                }
                
                Section {
                    NavigationLink {
                        ListClients(callbackClientClick: { client in
                            clients.append(client)
                        })
                    } label: {
                        Label {
                            Text("Ajouter un client")
                        } icon: {
                            Image(systemName: "plus.circle")
                                .foregroundStyle(.orange)
                        }
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
                        Label {
                            Text("Ajouter un type d'acte")
                        } icon: {
                            Image(systemName: "plus.circle")
                                .foregroundStyle(.purple)
                        }
                    }
                    
                    if !listTypeActes.isEmpty {
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
                    
                }
                
                if typeSelected == .facture {
                    Section {
                        Toggle("Facture déjà réglée ?", isOn: $estPayer)
                            .toggleStyle(SwitchToggleStyle(tint: .purple))
                    }
                    
                }
                
                
                Section("Options de paiement") {
                    NavigationLink {
                        
                    } label: {
                        Text("Virement banacaire")
                    }
                    
                }
                
                Section("Note - Optionnel") {
                    TextEditor(text: $notes)
                }
            }
            .navigationTitle(typeSelected == .facture ? "Facture # \(numero)" : "Devis # \(numero)")
            .safeAreaInset(edge: .bottom) {
                Button {
                    
                } label: {
                    Text("Sauvegarder")
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Détail") {
                        
                    }
                    .buttonStyle(.bordered)
                }
            }
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
