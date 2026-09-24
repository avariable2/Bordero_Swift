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
        TabView {
            Tab("Documents", systemImage: "doc.text") {
                DocumentsWorkspaceView()
            }
            
            Tab("Clients", systemImage: "person.2") {
                SplitViewListClients()
            }

            Tab("Paiements", systemImage: "eurosign") {
                NavigationStack {
                    ListAllClientPaiements()
                }
            }
            
            Tab("Paramètres", systemImage: "gearshape") {
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
