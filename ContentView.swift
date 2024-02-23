//
//  ContentView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
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
            
            NavigationView()
                .tabItem {
                    Image(systemName: "rectangle.split.2x2.fill")
                    Text("Parcourir")
                }
        }
    }
}

#Preview {
    ContentView()
}
