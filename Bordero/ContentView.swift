//
//  ContentView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var userNeediCloud : UseriCloudController.StateCheckiCloud
    
    var body: some View {
        if horizontalSizeClass == .compact {
            CustomTabView(userNeediCloud: userNeediCloud)
        } else {
            NavigationIpad(userNeediCloud: userNeediCloud)
        }
    }
}

struct CustomTabView: View {
    var userNeediCloud: UseriCloudController.StateCheckiCloud
    @State private var selection = 2
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                ListClients()
            }
            .tabItem {
                Image(systemName: "person.2")
                Text("Clients")
            }
            .tag(1)
            
            NavigationStack {
                ListDocument()
            }
            .tabItem {
                Image(systemName: "list.bullet.rectangle.fill")
                    .bold()
                Text("Documents")
            }
            .tag(2)
            
            NavigationStack {
                ExploreView()
            }
            .tabItem {
                Image(systemName: "rectangle.split.2x2.fill")
                Text("Parcourir")
            }
            .tag(3)
        }
    }
}

struct NavigationIpad: View {
    @State private var model = NavModel()
    @State private var selectedNav: NavItem.ID? = nil
    @State private var showExpandableFirstSection = true
    @State private var preferredColumn =
        NavigationSplitViewColumn.detail
    
    @State private var selectedClient : Client?
    
    var userNeediCloud: UseriCloudController.StateCheckiCloud
    
    var body: some View {
        NavigationSplitView {
            List {
                Section {
                    NavigationLink {
                        HomeView(showNeediCloud: userNeediCloud == .notConnected)
                    } label: {
                        Label("Résumé", systemImage: "house")
                            .tint(.primary)
                    }
                }
                
                Section("Parcourir", isExpanded: $showExpandableFirstSection) {
                    ForEach(model.navigation) { item in
                        NavigationLink {
                            destinationView(for: item.id)
                        } label: {
                            Label {
                                Text(item.name)
                            } icon: {
                                Image(systemName: item.icon)
                                    .symbolRenderingMode(.multicolor)
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Bordero")
        } detail: {
            VStack {
                if let navSelected = selectedNav {
                    destinationView(for: navSelected)
                } else {
                    HomeView(showNeediCloud: userNeediCloud == .notConnected)
                }
            }
        }
    }
    
    @ViewBuilder
    func destinationView(for id: Int) -> some View {
        switch id {
        case 1:
            HomeView(showNeediCloud: userNeediCloud == .notConnected)
        case 2:
            ListClients()
                .trackEventOnAppear(event: .clientListBrowsed, category: .clientManagement)
        case 3:
            FormTypeActeView()
        case 4:
            ListTypeActe()
        case 5:
            FormClientView()
        case 6:
            SplitViewListClients()
        case 7:
            DocumentFormView()
        case 8:
            ListDocument()
                .trackEventOnAppear(event: .documentListBrowsed, category: .documentManagement)
        default:
            EmptyView()
        }
    }
}

@Observable
class NavModel {
    var navigation: [NavItem] = [
//        NavItem(id: 5, name: "Ajouter un client", icon: "person.badge.plus"),
        NavItem(id: 2, name: "Liste des clients", icon: "person.2"),
//        NavItem(id: 3, name: "Ajouter un acte", icon: "stethoscope"),
        NavItem(id: 4, name: "Liste des actes", icon: "cross.case"),
        NavItem(id: 7, name: "Créer document", icon: "pencil.and.list.clipboard"),
        NavItem(id: 8, name: "Liste des docs", icon: "list.bullet"),
    ]
}

struct NavItem: Identifiable, Hashable {
    var id: Int
    var name: String
    var icon: String
}

#Preview {
    ContentView(userNeediCloud: UseriCloudController.StateCheckiCloud.connected)
}
