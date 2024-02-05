//
//  HomeView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) var moc
    
    @State private var showingAlert: Bool = false
    
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
                        
                        CreateTypeActeView(showingAlert: $showingAlert)
                            .presentationDetents([.medium])
                        
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
}

#Preview {
    HomeView()
}

