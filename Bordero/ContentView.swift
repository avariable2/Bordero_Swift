//
//  ContentView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI
import Observation

@Observable
class NavigationDestinationClient {
    var path = NavigationPath()
}

struct ContentView: View {
    @State var userNeediCloud : UseriCloudController.StateCheckiCloud
    
    @State var path = NavigationDestinationClient()
    
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
                
                NavigationStack(path: $path.path) {
                    ListClients()
                }
                .environment(path)
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
    
    var partitionedItems: [[NavItem]] {
        stride(from: 1, to: model.navigation.dropFirst(1).count, by: 2).map {
            Array(model.navigation[$0..<min($0 + 2, model.navigation.dropFirst(1).count)])
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // Volet de navigation principal
            List(selection: $selectedNav.animation()) {
                
                if let resume = model.navigation.first(where: { $0.id == 1 }) {
                    Label {
                        Text(resume.name)
                            .tint(.primary)
                    } icon: {
                        Image(systemName: resume.icon)
                            .foregroundStyle(.blue)
                    }
                }
                
                let tab = Array(model.navigation.dropFirst())
                Section {
                    ForEach(tab.chunked(into: 2), id: \.self) { sectionItems in
                    
                        ForEach(sectionItems, id: \.id) { item in
                            Label {
                                Text(item.name)
                                    .tint(.primary)
                            } icon: {
                                Image(systemName: item.icon)
                                    .foregroundStyle(item.foregroundColor![0], item.foregroundColor![1])
                            }
                        }
                    }
                } header: {
                    Text("Parcourir")
                }
                
            }
            .tint(Color.secondary.opacity(0.3))
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
                    ListTypeActe()
                case 5:
                    FormClientView()
                case 6:
                    ListClients()
                case 7:
                    DocumentFormView()
                case 8:
                    ListDocument()
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
        NavItem(id: 3, name: "Ajouter un type d'acte", icon: "square.and.pencil", foregroundColor: [.primary,.purple]),
        NavItem(id: 4, name: "Types d'acte", icon: "eyeglasses", foregroundColor: [.purple,.purple]),
        NavItem(id: 5, name: "Ajouter un client", icon: "person.badge.plus",
                foregroundColor: [.green,.brown]),
        NavItem(id: 2, name: "Clients", icon: "person.2", foregroundColor: [.brown, .brown.opacity(0.6)]),
        //        NavItem(id: 6, name: "Consulter la liste des clients", icon: "person.crop.rectangle.stack", foregroundColor: [.orange,.orange]),
        NavItem(id: 7, name: "Créer un document", icon: "doc.badge.plus", foregroundColor: [.green,.gray]),
        NavItem(id: 8, name: "Documents", icon: "doc.text.magnifyingglass", foregroundColor: [.blue,.gray]),
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


extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
