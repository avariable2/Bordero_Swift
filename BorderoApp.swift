//
//  BorderoApp.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

@main
struct BorderoApp: App {
    @StateObject private var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
