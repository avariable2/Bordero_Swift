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
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)], predicate: NSPredicate(
        format: "version <= %d",
        argumentArray: [FormClientView.getVersion()]
    ))  var clients: FetchedResults<Client>
    
    @State private var activeSheet: ActiveSheet?
    @State private var searchText = ""
    
    let alphabet: [String] = { (65...90).map { String(UnicodeScalar($0)!) } }()
    
    var callbackClientClick : ((Client) -> Void)?
    
    var filteredClients : [Client] {
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
                NavigationStack {
                    ScrollViewReader { proxy in
                        ZStack {
                            List {
                                ForEach(alphabet, id: \.self) { letter in
                                    let tabFiltered = filteredClients.filter({ (client) -> Bool in
                                        client.name?.prefix(1) ?? "0" == letter
                                    })
                                    Section {
                                        ForEach(tabFiltered) { client in
                                            ClientRow(client: client)
                                        }
                                    } header: {
                                        Text(letter).id(letter)
                                    }
                                }
                            }
                            .navigationDestination(for: Client.self) { client in
                                ClientDetailView(client: client)
                            }
                            .overlay(content:  {
                                if filteredClients.isEmpty {
                                    ContentUnavailableView.search(text: searchText)
                                }
                            })
                            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Recherche"))
                            .headerProminence(.increased)
                            
                            
                            VStack {
                                ForEach(alphabet, id: \.self) { letter in
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            print("letter = \(letter)")
                                            //need to figure out if there is a name in this section before I allow scrollto or it will crash
                                            if filteredClients.first(where: { $0.name?.prefix(1) ?? "0" == letter }) != nil {
                                                withAnimation {
                                                    proxy.scrollTo(letter)
                                                }
                                            }
                                        }, label: {
                                            Text(letter)
                                                .font(.system(size: 12))
                                                .padding(.trailing, 7)
                                        })
                                    }
                                }
                            }
                            
                        }
                    }
                }
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

struct ClientRow: View {
    let client: Client
    
    var body: some View {
        NavigationLink(value: client) {
            HStack {
                Text(client.firstname ?? "Inconnu")
                + Text(" ")
                + Text(client.name ?? "").bold()
                Spacer()
            }
        }
    }
}

#Preview {
    ListClients()
}

extension Client : Comparable {
    public static func < (lhs: Client, rhs: Client) -> Bool {
        // Fournir des valeurs par défaut pour les chaînes optionnelles pour la comparaison
        let lhsName = lhs.name ?? ""
        let lhsFirstname = lhs.firstname ?? ""
        let rhsName = rhs.name ?? ""
        let rhsFirstname = rhs.firstname ?? ""
        
        return (lhsName, lhsFirstname) < (rhsName, rhsFirstname)
    }
}
