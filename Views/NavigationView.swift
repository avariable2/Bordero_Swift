//
//  NavigationView.swift
//  Bordero
//
//  Created by Grande Variable on 23/02/2024.
//

import SwiftUI

struct NavigationView: View {
    @Environment(\.managedObjectContext) var moc
    
    @State private var activeSheet: ActiveSheet?
    
    var body: some View {
        NavigationStack {
            List {
                Section("Type de séance") {
                    Button {
                        activeSheet = .createTypeActe
                    } label: {
                        Label("Ajouter un type d'acte", systemImage: "pencil.and.list.clipboard")
                            .tint(.primary)
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
                            .tint(.primary)
                    }
                    
                    NavigationLink {
                        ListClients()
                    } label: {
                        Label("Consulter la liste des clients", systemImage: "person.2")
                    }
                } header: {
                    Text("Clients")
                }
                
                Section("Documents") {
                    NavigationLink {
                        FormDocumentView()
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
            .navigationTitle("Parcourir")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                }
            }
        }
    }
}

#Preview {
    NavigationView()
}
