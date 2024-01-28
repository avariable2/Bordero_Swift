//
//  HomeView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) var moc
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    @State private var showingAlert: Bool = false
    @State private var nom : String = ""
    @State private var prix : Float = 0
    
    @State private var numberString: String = ""
    @State private var floatValue: Float?
    
    private var alertTitre : String = "Creer un type d'acte"
    
    private var disableForm: Bool {
        nom.isEmpty || floatValue == nil
    }

    
    var body: some View {
        NavigationView {
            List {
                Section("Type de séance") {
                    Button {
                        showingAlert = true
                    } label: {
                        Label("Ajouter un type d'acte", systemImage: "pencil.and.list.clipboard")
                            .tint(.black)
                    }.alert(Text(alertTitre),
                            isPresented: $showingAlert) {
                        
                        TextField("Nom", text: $nom)
                        
                        TextField("Prix", text: $numberString)
                            .keyboardType(.decimalPad)
                            .onChange(of: numberString) {
                                validateNumberString()
                            }
                        
                        Button("Créer") {
                            creerTypeActe()
                        }
                        .disabled(disableForm)
                        
                        Button("Annuler", role: .cancel) {}
                        
                    } message: {
                        Text("Les deux champs sont obligatoires")
                    }
                    
                    
                    NavigationLink {
                        EmptyView()
                    } label: {
                        Label("Consulter tous les type d'acte", systemImage: "list.bullet.clipboard")
                    }
                   
                }
                
                Section {
                    NavigationLink {
                        EmptyView()
                    } label: {
                        Label("Ajouter un client", systemImage: "person")
                    }
                    
                    NavigationLink {
                        EmptyView()
                    } label: {
                        Label("Consulter la liste des clients", systemImage: "person.2")
                    }
                } header: {
                    Text("Clients")
                }
//                } footer: {
//                    Text("")
//                }
                
                Section("Documents") {
                    NavigationLink {
                        EmptyView()
                    } label: {
                        Label("Créer un document", systemImage: "doc")
                    }
                    
                    NavigationLink {
                        EmptyView()
                    } label: {
                        Label("Consulter les documents", systemImage: "list.bullet")
                    }
                   
                }
            }
            .navigationTitle("Actions rapide")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func validateNumberString() {
        if let value = Float(numberString) {
           // Si la conversion réussit, mettre à jour le state Float
           floatValue = value
       } else {
           // Réinitialiser le state Float si la chaîne n'est pas un nombre valide
           floatValue = nil
       }
    }
    
    private func creerTypeActe() {
        let typeActe = TypeActe(context: moc)
        typeActe.id = UUID()
        typeActe.name = nom
        typeActe.price = prix
    }
}

#Preview {
    HomeView()
}

