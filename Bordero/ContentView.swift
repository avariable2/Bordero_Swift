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
        TabView {
            Tab("Home", systemImage: "house") {
                NavigationStack {
                    HomeView()
                }
            }
            
            Tab("Documents", systemImage: "document") {
                NavigationStack {
                    ListDocument()
                }
            }
            
            Tab("Clients", systemImage: "person.2") {
                NavigationStack {
                    ListClients()
                }
            }
            
            Tab("Paramètres", systemImage: "person.crop.circle.fill") {
                NavigationStack {
                    ParametersView(activeSheet: .constant(nil))
                }
            }
            
        }
    }
}

#Preview {
    ContentView(userNeediCloud: UseriCloudController.StateCheckiCloud.connected)
}
