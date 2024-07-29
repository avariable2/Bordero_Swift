//
//  ContentView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

enum MenuNavigation : String, Identifiable, CaseIterable {
    case clients
    case documents
    case parametres = "Paramètres"
    
    var id : String { return self.rawValue }
    var systemNameImage : String {
        switch self {
        case .clients:
            "person.2"
        case .documents:
            "list.bullet.rectangle"
        case .parametres:
            "person.crop.circle"
        }
    }
}

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var selection : MenuNavigation? = .documents
    
    var body: some View {
        VStack {
            if horizontalSizeClass == .compact {
                CustomTabView(selection: $selection)
            } else {
                NavigationIpad(selectedMenu: $selection)
            }
        }
    }
}

struct CustomTabView: View {
    @Binding var selection : MenuNavigation?
    @State var activeSheet : ActiveSheet? = nil
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                ListClients()
            }
            .tabItem {
                Image(systemName: "person.2")
                Text("Clients")
            }
            .tag(MenuNavigation.clients)
            
            NavigationStack {
                ListDocument()
            }
            .tabItem {
                Image(systemName: "list.bullet.rectangle.fill")
                    .bold()
                Text("Documents")
            }
            .tag(MenuNavigation.documents)
            
            NavigationStack {
                ParametersView(activeSheet: $activeSheet)
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Paramètres")
            }
            .tag(MenuNavigation.parametres)
        }
    }
}

struct NavigationIpad: View {
    @State private var selectedClient : Client?
    
    @Binding var selectedMenu : MenuNavigation?
    @State var activeSheet : ActiveSheet? = nil
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedMenu) {
                ForEach(MenuNavigation.allCases, id: \.id) { menu in
                    Label(menu.rawValue.capitalized, systemImage: menu.systemNameImage)
                        .tag(menu)
                }
            }
            .navigationTitle("Bordero")
            .navigationBarTitleDisplayMode(.large)
        } content: {
            if let selectedMenu {
                destinationMenu(for: selectedMenu)
            } else {
                Text("Rien n'a été sélectionné")
            }
        } detail: {
            Text("Rien n'a été sélectionné")
        }
    }
    
    @ViewBuilder
    func destinationMenu(for menu: MenuNavigation) -> some View {
        switch menu {
        case .clients:
            ListClients()
        case .documents:
            ListDocument()
        case .parametres:
            ParametersView(activeSheet: $activeSheet)
        }
    }
}

#Preview {
    ContentView()
}
