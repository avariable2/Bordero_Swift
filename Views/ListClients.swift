//
//  ListClients.swift
//  Bordero
//
//  Created by Grande Variable on 07/02/2024.
//

import SwiftUI

struct ListClients: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: []) var clients: FetchedResults<Client>
    @State private var searchText = ""
    
    var body: some View {
        List {
            if filteredClients(clients: Array(clients), searchText: searchText).isEmpty {
                Text("Aucun résultat")
            } else {
                ForEach(filteredClients(clients: Array(clients), searchText: searchText)) { client in
                    Text(client.firstname ?? "Inconnu")
                    + Text(" ")
                    + Text(client.name ?? "").bold()
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Clients")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Recherche"))
    }
    
    func filteredClients(clients: [Client], searchText: String) -> [Client] {
        guard !searchText.isEmpty else { return clients }
        return clients.filter { client in
            client.firstname?.lowercased().contains(searchText.lowercased()) == true || client.name?.lowercased().contains(searchText.lowercased()) == true
        }
    }
}

#Preview {
    ListClients()
}
