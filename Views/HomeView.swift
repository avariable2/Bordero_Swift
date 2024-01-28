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
    
    // Textfield pour l'utilisateur
    @State private var nom : String = ""
    @State private var numberString: String = ""
    @State private var floatValue: Float?
    
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
                    }.sheet(isPresented: $showingAlert) {
                        
                        VStack(alignment: .center, spacing: 10) {
                             
                            Text("Creer un type d'acte")
                                .font(.title)
                                .bold()
                            
                            VStack(spacing: 20) {
                                TextField("Entrer un nom", text: $nom)
                                    
                                    
                                TextField("Entrer un prix", text: $numberString)
                                    .keyboardType(.decimalPad)
                                    .onChange(of: numberString) {
                                        validateNumberString()
                                    }
                                
                                
                            }
                            .textFieldStyle(.roundedBorder)
                            .padding([.trailing, .leading], 20)
                            
                            VStack(spacing: 30) {
                                
                                Button("Créer") {
                                    creerTypeActe()
                                    showingAlert.toggle()
                                }
                                .disabled(disableForm)
                                
                                
                                Button("Annuler", role: .destructive) {
                                    numberString = ""
                                    floatValue = nil
                                    nom = ""
                                    showingAlert.toggle()
                                }
                            }
                            
                        }
                        .presentationDetents([.medium, .large])
                        
                    }
                    
                    NavigationLink {
                        ListTypeActeView()
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
        guard let prix = floatValue else {
            print("Il y'a une erreur avec la valeur set dans la modal")
            return
        }
        
        let typeActe = TypeActe(context: moc)
        typeActe.id = UUID()
        typeActe.name = nom
        typeActe.price = prix
        
        do {
            try moc.save()
            print("Success")
        } catch let err {
            print(err.localizedDescription)
        }
        
    }
}

#Preview {
    HomeView()
}

