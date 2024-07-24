//
//  ListClients.swift
//  Bordero
//
//  Created by Grande Variable on 07/02/2024.
//

import SwiftUI

struct SplitViewListClients : View {
    @State private var selectedClient : Client?
    
    var body: some View {
        NavigationSplitView {
            ListClients { client in
                selectedClient = client
            }
        } detail: {
            if let selectedClient = selectedClient {
                ClientDetailView(client: selectedClient)
            } else {
                Text("Sélectionner un client")
            }
        }
    }
}

struct ListClients: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Client.name_, ascending: true)], predicate: NSPredicate(
        format: "version <= %d",
        argumentArray: [FormClientSheet.getVersion()]
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
                })
                
            } else {
                ScrollViewReader { proxy in
                    
                    let noNameClients = filteredClients.filter {
                        let firstChar = $0.name_?.uppercased().prefix(1) ?? "#"
                        return !alphabet.contains(String(firstChar))
                    }
                    
                    ZStack {
                        List {
                            // Sections pour les contacts avec nom
                            ForEach(alphabet, id: \.self) { letter in
                                
                                // Filtre les nom par la lettre
                                let tabFiltered = filteredClients.filter({ client -> Bool in
                                    guard let firstLetter = client.name_?.prefix(1).uppercased() else { return false }
                                    return firstLetter == letter
                                })
                                
                                // Affiche uniquement si la liste de nom n'est pas vide
                                if !tabFiltered.isEmpty {
                                    Section {
                                        ForEach(tabFiltered) { client in
                                            ClientRow(client: client, callback : callbackClientClick)
                                        }
                                    } header: {
                                        Text(letter).id(letter)
                                    }
                                }
                            }
                            
                            // Section pour les contacts sans nom
                            if !noNameClients.isEmpty {
                                Section {
                                    ForEach(noNameClients) { client in
                                        ClientRow(client: client, callback: callbackClientClick)
                                    }
                                } header: {
                                    Text("#").id("#")
                                }
                            }
                        }
                        .overlay(content: {
                            if filteredClients.isEmpty {
                                ContentUnavailableView.search(text: searchText)
                            }
                        })
                        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Recherche"))
                        .headerProminence(.increased)

                        VStack {
                            ForEach(alphabet, id: \.self) { letter in
                                SectionIndexButton(letter: letter, proxy: proxy, filteredClients: filteredClients)
                            }
                            
                            // Index de section ajusté pour inclure la section des contacts sans nom
                            if !noNameClients.isEmpty {
                                SectionIndexButton(letter: "#", proxy: proxy)
                            }
                        }
                    }
                }
            }
        }
        .trackEventOnAppear(event: .clientListBrowsed, category: .clientManagement)
        .navigationTitle("Clients")
        .navigationBarTitleDisplayMode(callbackClientClick != nil ?.inline : .large)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    activeSheet = .createClient
                } label: {
                    Image(systemName: "person.fill.badge.plus")
                        .foregroundStyle(.green, .blue)
                }
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .createClient:
                FormClientSheet(onCancel: {
                    activeSheet = nil
                }, onSave: {
                    activeSheet = nil
                })
                    .presentationDetents([.large])
            case .editClient(let client):
                FormClientSheet(onCancel: {
                    activeSheet = nil
                }, onSave: {
                    activeSheet = nil
                }, clientToModify: client)
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
            client.firstname.lowercased().contains(searchText.lowercased()) == true || client.lastname.lowercased().contains(searchText.lowercased()) == true
        }
    }
}

struct SectionIndexButton: View {
    let letter: String
    let proxy: ScrollViewProxy
    var filteredClients: [Client] = []

    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                // Logique de défilement ajustée
                if letter == "#" {
                    if filteredClients.first(where: { $0.name_?.isEmpty ?? true }) != nil {
                        withAnimation {
                            proxy.scrollTo("#")
                        }
                    }
                } else {
                    if filteredClients.first(where: { $0.name_?.prefix(1) ?? "0" == letter }) != nil {
                        withAnimation {
                            proxy.scrollTo(letter)
                        }
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

struct ClientRow: View {
    @Environment(\.dismiss) private var dismiss
    
    let client: Client
    let callback : ((Client) -> Void)?
    
    var body: some View {
        VStack {
            if let call = callback {
                Button {
                    call(client)
                    dismiss()
                } label: {
                    HStack {
                        Text(client.firstname)
                        + Text(" ")
                        + Text(client.lastname).bold()
                        Spacer()
                    }
                    .tint(.primary)
                }
            } else {
                NavigationLink{
                    ClientDetailView(client: client)
                } label: {
                    HStack {
                        Text(client.firstname)
                        + Text(" ")
                        + Text(client.lastname).bold()
                        Spacer()
                    }
                }
            }
        }
    }
}

extension Client : Comparable {
    public static func < (lhs: Client, rhs: Client) -> Bool {
        // Fournir des valeurs par défaut pour les chaînes optionnelles pour la comparaison
        let lhsName = lhs.lastname
        let lhsFirstname = lhs.firstname
        let rhsName = rhs.lastname
        let rhsFirstname = rhs.firstname
        
        return (lhsName, lhsFirstname) < (rhsName, rhsFirstname)
    }
}

//#Preview {
//    ListClients(path: NavigationPath())
//}
