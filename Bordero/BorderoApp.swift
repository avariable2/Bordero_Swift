//
//  BorderoApp.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

@main
struct BorderoApp: App {
    
    private var dataController = DataController.shared
    private var userController = UseriCloudController()
    
    var body: some Scene {
        WindowGroup {
            switch userController.accountAvailable {
            case .isLoading:
                HomeView(showNeediCloud: true)
                    .redacted(reason: .placeholder)
            case .connected, .notConnected:
                ContentView(userNeediCloud: userController.accountAvailable)
                    .onChange(of: userController.accountAvailable) { oldValue, newValue in
                        DataController.shared.updateICloudSettings()
                    }
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    
            }
        }
    }
}

