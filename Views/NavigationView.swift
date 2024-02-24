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
                        Label("Ajouter un type d'acte", systemImage: "square.and.pencil")
                            .tint(.primary)
                            .foregroundStyle(.primary, .purple)
                    }
                    
                    NavigationLink {
                        ListTypeActeView()
                    } label: {
                        Label {
                            Text("Consulter tous les types d'acte")
                                .tint(.primary)
                        } icon: {
                            Image(systemName: "eyeglasses")
                                .foregroundStyle( .purple, .orange)
                        }
                    }
                }
                
                Section {
                    Button {
                        activeSheet = .createClient
                    } label: {
                        Label {
                            Text("Ajouter un client")
                                .tint(.primary)
                        } icon: {
                            Image(systemName: "person.crop.rectangle.badge.plus")
                                .foregroundStyle( .green, .orange)
                        }
                    }
                    
                    NavigationLink {
                        ListClients()
                    } label: {
                        Label {
                            Text("Consulter la liste des clients")
                                .tint(.primary)
                        } icon: {
                            Image(systemName: "person.crop.rectangle.stack")
                                .foregroundStyle(.orange)
                        }
                    }
                } header: {
                    Text("Clients")
                }
                
                Section("Documents") {
                    NavigationLink {
                        FormDocumentView()
                    } label: {
                        Label {
                            Text("Créer un document")
                                .tint(.primary)
                        } icon: {
                            Image(systemName: "doc.badge.plus")
                                .foregroundStyle(.green, .blue)
                        }
                    }
                    
                    NavigationLink {
                        EmptyView()
                    } label: {
                        Label {
                            Text("Consulter les documents")
                                .tint(.primary)
                        } icon: {
                            Image(systemName: "doc.text.magnifyingglass")
                                .foregroundStyle(.gray, .primary)
                        }
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
