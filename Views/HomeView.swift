//
//  HomeView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) var moc
    
    @State private var activeSheet: ActiveSheet?
    
    var body: some View {
        NavigationView {
            List {
                Section("Type de séance") {
                    Button {
                        activeSheet = .createTypeActe
                    } label: {
                        Label("Ajouter un type d'acte", systemImage: "pencil.and.list.clipboard")
                            .tint(.black)
                    }
                    
                    NavigationLink {
                        ListTypeActeView()
                    } label: {
                        Label("Consulter tous les types d'acte", systemImage: "list.bullet.clipboard")
                    }
                   
                }
                
                Section {
                    Button {
                        activeSheet = .createClient
                    } label: {
                        Label("Ajouter un client", systemImage: "person")
                            .tint(.black)
                    }
                    
                    NavigationLink {
                        EmptyView()
                    } label: {
                        Label("Consulter la liste des clients", systemImage: "person.2")
                    }
                } header: {
                    Text("Clients")
                }
                
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
            .sheet(item: $activeSheet) { item in
                
                switch item {
                    
                case .createTypeActe:
                    FormTypeActeView(activeSheet: $activeSheet)
                        .presentationDetents([.medium])
                case .createClient:
                    FormClientView(activeSheet: $activeSheet)
                        .presentationDetents([.large])
                default:
                    EmptyView() // IMPOSSIBLE
                }
            }
            .navigationTitle("Actions rapides")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
}

#Preview {
    HomeView()
}

