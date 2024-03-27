//
//  ContentView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

struct ContentView: View {
    @State var userNeediCloud : UseriCloudController.StateCheckiCloud
    
    var body: some View {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            NavigationIpad(userNeediCloud: userNeediCloud)
        } else {
            TabView {
                NavigationStack {
                    HomeView(showNeediCloud: userNeediCloud == .notConnected)
                }
                .tabItem {
                    Image(systemName: "house")
                    Text("Résumé")
                }
                
                NavigationStack {
                    ListClients()
                }
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Clients")
                }
                
                NavigationStack {
                    ExploreView()
                }
                .tabItem {
                    Image(systemName: "rectangle.split.2x2.fill")
                    Text("Parcourir")
                }
                
            }
            
        }
    }
}

struct NavigationIpad : View {
    @State private var model = NavModel()
    @State private var selectedNav: NavItem.ID? = nil
    
    @State private var activeSheet : ActiveSheet?
    
    @State private var isExpanded: Bool = true
    
    var userNeediCloud : UseriCloudController.StateCheckiCloud
    
    var body: some View {
        NavigationSplitView {
            // Volet de navigation principal
            List(selection: $selectedNav) {
                ForEach(model.navigation.prefix(2)) { item in
                    Label(item.name, systemImage: item.icon)
                }

                // Utiliser un DisclosureGroup pour les éléments restants
                DisclosureGroup(isExpanded: $isExpanded) {
                    ForEach(model.navigation.dropFirst(2)) { navItem in
                        Label(navItem.name, systemImage: navItem.icon)
                    }
                } label: {
                    Text("Parcourir")
                        .font(.title2)
                        .bold()
                }
                
                
            }
            .listStyle(.sidebar)
            .navigationTitle("Bordero")
        } detail: {
            if let navSelected = model.nav(id: selectedNav) {
                switch navSelected.id {
                case 1:
                    HomeView(showNeediCloud: userNeediCloud == .notConnected)
                case 2:
                    ListClients()
                case 3:
                    FormTypeActeView()
                case 4:
                    ListTypeActeView()
                case 5:
                    FormClientView()
                case 6: 
                    ListClients()
                case 7: 
                    FormDocumentView()
                case 8:
                    EmptyView()
                default:
                    EmptyView()
                }
            } else {
                HomeView(showNeediCloud: userNeediCloud == .notConnected)
            }
        }
    }
}



@Observable
class NavModel {
    var navigation : [NavItem] = [
        NavItem(id: 1, name: "Résumé", icon: "house"),
        NavItem(id: 2, name: "Clients", icon: "person.2"),
        NavItem(id: 3, name: "Ajouter un type d'acte", icon: "square.and.pencil"),
        NavItem(id: 4, name: "Consulter tous les types d'acte", icon: "eyeglasses"),
        NavItem(id: 5, name: "Ajouter un client", icon: "person.crop.rectangle.badge.plus"),
        NavItem(id: 6, name: "Consulter la liste des clients", icon: "person.crop.rectangle.stack"),
        NavItem(id: 7, name: "Créer un document", icon: "doc.badge.plus"),
        NavItem(id: 8, name: "Consulter les documents", icon: "doc.text.magnifyingglass"),
    ]
    
    func nav(id : NavItem.ID?) -> NavItem? {
        navigation.first(where: { $0.id == id })
    }
}

struct NavItem : Identifiable, Hashable {
    var id : Int
    var name : String
    var icon : String
    var foregroundColor : [Color]?
}


#Preview {
    ContentView(userNeediCloud: UseriCloudController.StateCheckiCloud.connected)
}
