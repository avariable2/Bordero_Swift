//
//  ListClients.swift
//  Bordero
//
//  Created by Grande Variable on 07/02/2024.
//

import SwiftUI
import CoreData

struct SplitViewListClients : View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @FetchRequest(fetchRequest: Client.fetch(NSPredicate(
        format: "version <= %d",
        argumentArray: [FormClientSheet.getVersion()]
    ))) private var clients: FetchedResults<Client>

    @State private var selectedClient : Client?
    
    var body: some View {
        Group {
            if horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad {
                NavigationSplitView {
                    ListClients(
                        onSelectClient: { client in
                            selectedClient = client
                        },
                        selectedClientID: selectedClient?.objectID
                    )
                    .navigationSplitViewColumnWidth(
                        min: 300,
                        ideal: 360,
                        max: 420
                    )
                } detail: {
                    NavigationStack {
                        if let selectedClient {
                            ClientDetailView(client: selectedClient)
                        } else {
                            ContentUnavailableView(
                                "Sélectionnez un client",
                                systemImage: "person.crop.rectangle"
                            )
                        }
                    }
                }
            } else {
                NavigationStack {
                    ListClients()
                }
            }
        }
        .onAppear(perform: ensureSelection)
        .onChange(of: clients.map(\.objectID)) {
            ensureSelection()
        }
    }

    private func ensureSelection() {
        if !clients.contains(where: { $0.objectID == selectedClient?.objectID }) {
            selectedClient = clients.first
        }
    }
}

struct ListClients: View {
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(fetchRequest: Client.fetch(NSPredicate(
        format: "version <= %d",
        argumentArray: [FormClientSheet.getVersion()]
    ))) private var clients: FetchedResults<Client>
    
    @State private var activeSheet: ActiveSheet?
    @State private var searchText = ""
    @State private var selectedClientIDs = Set<NSManagedObjectID>()
    @State private var isShowingDeleteConfirmation = false
    @State private var editMode: EditMode = .inactive

    private let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map(String.init)
    
    var callbackClientClick : ((Client) -> Void)?
    var onSelectClient: ((Client) -> Void)?
    var selectedClientID: NSManagedObjectID?
    
    var filteredClients : [Client] {
        filteredClients(clients: Array(clients), searchText: searchText)
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                let unnamedClients = filteredClients.filter {
                    guard let firstCharacter = $0.name_?.uppercased().first else {
                        return true
                    }
                    return !alphabet.contains(String(firstCharacter))
                }

                ZStack {
                    List(selection: $selectedClientIDs) {
                        ForEach(alphabet, id: \.self) { letter in
                            let clientsForLetter = filteredClients.filter {
                                $0.name_?.uppercased().hasPrefix(letter) == true
                            }

                            if !clientsForLetter.isEmpty {
                                Section {
                                    ForEach(clientsForLetter) { client in
                                        ClientRow(
                                            client: client,
                                            callback: callbackClientClick,
                                            onSelect: onSelectClient
                                        )
                                        .listRowBackground(
                                            Color(.secondarySystemGroupedBackground)
                                                .overlay(client.objectID == selectedClientID ? Color.green.opacity(0.12) : Color.clear)
                                        )
                                            .tag(client.objectID)
                                    }
                                } header: {
                                    Text(letter)
                                        .id(letter)
                                }
                            }
                        }

                        if !unnamedClients.isEmpty {
                            Section {
                                ForEach(unnamedClients) { client in
                                    ClientRow(
                                        client: client,
                                        callback: callbackClientClick,
                                        onSelect: onSelectClient
                                    )
                                    .listRowBackground(
                                        Color(.secondarySystemGroupedBackground)
                                            .overlay(client.objectID == selectedClientID ? Color.green.opacity(0.12) : Color.clear)
                                    )
                                        .tag(client.objectID)
                                }
                            } header: {
                                Text("#")
                                    .id("#")
                            }
                        }
                    }
                    .environment(\.editMode, $editMode)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGroupedBackground))
                    .overlay {
                        if !clients.isEmpty && filteredClients.isEmpty {
                            ContentUnavailableView.search
                        }
                    }
                    .searchable(
                        text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .automatic),
                        prompt: Text("Recherche")
                    )
                    .headerProminence(.increased)
                }
            }
        }
        .trackEventOnAppear(event: .clientListBrowsed, category: .clientManagement)
        .navigationTitle("Clients")
        .navigationBarTitleDisplayMode(callbackClientClick != nil ? .inline : .large)
        .overlay {
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
            }
        }
        .toolbar {
            if callbackClientClick == nil && !clients.isEmpty {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(
                        editMode.isEditing ? "Terminer" : "Sélectionner",
                        systemImage: editMode.isEditing ? "checkmark" : "checklist"
                    ) {
                        withAnimation {
                            toggleEditing()
                        }
                    }

                    if editMode.isEditing && !selectedClientIDs.isEmpty {
                        Button("Supprimer", systemImage: "trash", role: .destructive) {
                            isShowingDeleteConfirmation = true
                        }
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Ajouter un client", systemImage: "plus", action: createClient)
            }
        }
        .confirmationDialog(
            deleteConfirmationTitle,
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Supprimer", role: .destructive, action: deleteSelectedClients)
            Button("Annuler", role: .cancel) { }
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
    
    private var deleteConfirmationTitle: String {
        let count = selectedClientIDs.count
        return count == 1
            ? "Supprimer le client sélectionné ?"
            : "Supprimer les \(count) clients sélectionnés ?"
    }

    private func createClient() {
        activeSheet = .createClient
    }

    private func toggleEditing() {
        if editMode.isEditing {
            selectedClientIDs.removeAll()
            editMode = .inactive
        } else {
            editMode = .active
        }
    }

    private func deleteSelectedClients() {
        for client in clients where selectedClientIDs.contains(client.objectID) {
            moc.delete(client)
        }

        do {
            try moc.save()
            selectedClientIDs.removeAll()
        } catch {
            moc.rollback()
            print(error.localizedDescription)
        }
    }
    
    func filteredClients(clients: [Client], searchText: String) -> [Client] {
        guard !searchText.isEmpty else { return clients }
        return clients.filter { client in
            client.firstname.lowercased().contains(searchText.lowercased()) == true || client.lastname.lowercased().contains(searchText.lowercased()) == true
        }
    }
}

struct ClientRow: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    
    let client: Client
    let callback : ((Client) -> Void)?
    var onSelect: ((Client) -> Void)?
    
    var ligneAvecNom : some View {
        HStack {
            Text("\(client.firstname) \(Text(client.lastname).bold())")
            Spacer()
        }
    }
    
    var body: some View {
        VStack {
            if editMode?.wrappedValue.isEditing == true {
                ligneAvecNom
            } else if let onSelect {
                Button {
                    onSelect(client)
                } label: {
                    ligneAvecNom
                        .tint(.primary)
                }
                .buttonStyle(.plain)
            } else if let call = callback {
                Button {
                    call(client)
                    dismiss()
                } label: {
                    ligneAvecNom
                        .tint(.primary)
                }
            } else {
                NavigationLink{
                    ClientDetailView(client: client)
                } label: {
                    ligneAvecNom
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

#if DEBUG
#Preview("Avec liste factives") {
    NavigationStack {
        ListClients()
    }
        .environment(\.managedObjectContext, PreviewDataController.invoices.context)
}
#endif

#if DEBUG
#Preview("Liste vide") {
    ListClients()
        .environment(\.managedObjectContext, PreviewDataController.empty.context)
}
#endif
