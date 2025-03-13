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
    case calendrier
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
        case .calendrier:
            "calendar"
        }
    }
}

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .compact {
            CustomTabView()
        } else {
            NavigationIpad()
        }
    }
}

struct CustomTabView: View {
    @AppStorage("selectedTab") var selection: MenuNavigation = .documents
    @State var activeSheet: ActiveSheet? = nil
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                ListClients()
            }
            .tabItem {
                Image(systemName: "person.2")
                Text(MenuNavigation.clients.rawValue.capitalized)
            }
            .tag(MenuNavigation.clients)
            
            NavigationStack {
                ListDocument()
            }
            .tabItem {
                Image(systemName: "list.bullet.rectangle.fill")
                    .bold()
                Text(MenuNavigation.documents.rawValue.capitalized)
            }
            .tag(MenuNavigation.documents)
            
            NavigationStack {
                MainCalendarView()
            }
            .tabItem {
                Image(systemName: "calendar")
                    .bold()
                Text(MenuNavigation.calendrier.rawValue.capitalized)
            }
            .tag(MenuNavigation.calendrier)
            
            NavigationStack {
                ParametersView(activeSheet: $activeSheet)
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text(MenuNavigation.parametres.rawValue.capitalized)
            }
            .tag(MenuNavigation.parametres)
        }
    }
}

struct NavigationIpad: View {
    @State private var selectedClient: Client?
    @AppStorage("selectedMenu") private var selectedMenuRawValue: String = MenuNavigation.documents.rawValue
    @State var activeSheet: ActiveSheet? = nil
    
    private var selectedMenu: Binding<MenuNavigation?> {
        Binding(
            get: { MenuNavigation(rawValue: selectedMenuRawValue) },
            set: { newValue in
                selectedMenuRawValue = newValue?.rawValue ?? MenuNavigation.documents.rawValue
            }
        )
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: selectedMenu) {
                ForEach(MenuNavigation.allCases, id: \.id) { menu in
                    Label(menu.rawValue.capitalized, systemImage: menu.systemNameImage)
                        .tag(menu)
                }
            }
            .navigationTitle("Bordero")
            .navigationBarTitleDisplayMode(.large)
        } content: {
            if let menu = MenuNavigation(rawValue: selectedMenuRawValue) {
                destinationMenu(for: menu)
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
        case .calendrier:
            MainCalendarView()
        case .parametres:
            ParametersView(activeSheet: $activeSheet)
        
        }
    }
}

#Preview {
    ContentView()
}
