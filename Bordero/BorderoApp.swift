//
//  BorderoApp.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI
import CoreData

@main
struct BorderoApp: App {
    private var dataController = DataController.shared
    private var userController = UseriCloudController()
    
    var body: some Scene {
        WindowGroup {
            ContentView(userNeediCloud: userController.accountAvailable)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }

        WindowGroup("Nouvelle facture", id: "invoice-creation", for: UUID.self) { $invoiceID in
            InvoiceCreationWindowView(invoiceID: invoiceID)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
