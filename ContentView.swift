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
                    Image(systemName: "bolt")
                    Text("Actions rapides")
                }
            
            HomeView()
                .tabItem {
                    Image(systemName: "doc.plaintext")
                    Text("Documents")
                }
            
            NavigationStack {
                ListClients()
            }
            .tabItem {
                Image(systemName: "person.2")
                Text("Clients")
            }
            
            HomeView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Paramètres")
                }
        }
    }
}

#Preview {
    ContentView()
}
