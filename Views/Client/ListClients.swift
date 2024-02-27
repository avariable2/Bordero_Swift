//
//  ListClients.swift
//  Bordero
//
//  Created by Grande Variable on 07/02/2024.
//

import SwiftUI

struct ListClients: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(
        format: "version <= %d",
        argumentArray: [FormClientView.getVersion()]
    ))  var clients: FetchedResults<Client>
    
    var callbackClientClick : ((Client) -> Void)?
    @State private var activeSheet: ActiveSheet?
    @State private var searchText = ""
    
    var filteredClients: [Client] {
        filteredClients(clients: Array(clients), searchText: searchText)
    }
    
    var body: some View {
        VStack {
            if clients.isEmpty {
                
                ContentUnavailableView(label: {
                    Label("Aucun client", systemImage: "person.slash")
                }, description: {
                    Text("Les clients ajoutés apparaîtront ici.")
                }, actions: {
                    Button {
                        activeSheet = .createClient
                    } label: {
                        Text("Ajouter un client")
                    }
                    .sheet(item: $activeSheet) { item in
                        switch item {
                        case .createClient:
                            FormClientView(activeSheet: $activeSheet)
                                .presentationDetents([.large])
                        default:
                            EmptyView() // IMPOSSIBLE
                        }
                    }
                })
                
            } else {
                List {
                    ForEach(filteredClients) { client in
                        ClientRowView(
                            client: client,
                            onDelete: deleteClient,
                            onClick: { client in
                                applyOnClick(client)
                            }
                        )
                    }
                    .onDelete(perform: delete)
                }
                .overlay(content:  {
                    if filteredClients.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    }
                })
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Recherche"))
            }
        }
        .navigationTitle("Clients")
        .navigationBarTitleDisplayMode(callbackClientClick != nil ?.inline : .large)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    activeSheet = .createClient
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .createClient:
                FormClientView(activeSheet: $activeSheet)
                    .presentationDetents([.large])
            case .editClient(let client):
                FormClientView(activeSheet: $activeSheet, clientToModify: client)
                    .presentationDetents([.large])
            default:
                EmptyView() // IMPOSSIBLE
            }
        }
    }
    
    private func applyOnClick(_ client: Client) {
        if callbackClientClick != nil {
            callbackClientClick!(client)
            dismiss()
        } else {
            activeSheet = .editClient(client: client)
        }
    }
    
    private func deleteClient(client: Client) {
        // Trouver l'indice du client dans le tableau
        if let indexToDelete = clients.firstIndex(of: client) {
            // Créer un IndexSet avec cet indice
            let indexSet = IndexSet(integer: indexToDelete)
            // Appeler la fonction de suppression existante
            delete(at: indexSet)
        }
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let clientToDelete = clients[index]
            moc.delete(clientToDelete)
        }
        
        do {
            try moc.save()
            print("Success")
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    func filteredClients(clients: [Client], searchText: String) -> [Client] {
        guard !searchText.isEmpty else { return clients }
        return clients.filter { client in
            client.firstname?.lowercased().contains(searchText.lowercased()) == true || client.name?.lowercased().contains(searchText.lowercased()) == true
        }
    }
}

struct ClientRowView : View {
    
    var client : Client
    var onDelete: (Client) -> Void
    var onClick : (Client) -> Void
    
    var body : some View {
        Button {
            onClick(client)
        } label: {
            HStack {
                Text(client.firstname ?? "Inconnu")
                + Text(" ")
                + Text(client.name ?? "")
                    .bold()
                Spacer()
            }
            .contentShape(Rectangle())
            .frame( maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Section {
                Button {
                    // TODO
                } label: {
                    Label("Nouveau document", systemImage: "square.and.pencil.circle")
                }
            }
            
            Section {
                Button {
                    // TODO
                } label: {
                    Label("Modifier", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    onDelete(client)
                } label: {
                    Label("Supprimer le client", systemImage: "trash")
                }
            }
        }
    }
}

struct EmptyListClientView : View {
    
    @Binding var activeSheet : ActiveSheet?
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Aucun client")
                .font(.title)
            
            Text("Les clients ajoutés apparaîtront ici.")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Button {
                activeSheet = .createClient
            } label: {
                Text("Ajouter un client")
            }
            .padding(.top)
            .sheet(item: $activeSheet) { item in
                switch item {
                case .createClient:
                    FormClientView(activeSheet: $activeSheet)
                        .presentationDetents([.large])
                default:
                    EmptyView() // IMPOSSIBLE
                }
            }
            
            Spacer()
        }
    }
}

struct EmptySearchListClientView : View {
    
    @Binding var searchText : String
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.largeTitle)
            
            Text("Aucun résultat pour \"\(searchText)\"")
                .font(.title2)
            
            Text("Vérifiez l'orthographe ou lancez \nune nouvelle recherche.")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
    }
}

#Preview {
    ListClients()
}
