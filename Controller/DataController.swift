//
//  DataController.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import CoreData
import Foundation
import CloudKit
import Observation

@Observable class DataController {
    static let shared = DataController()
    
    let container = NSPersistentCloudKitContainer(name: "Model")
    
    private init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load : \(error.localizedDescription)")
            }
        }
        
        // https://arc.net/l/quote/eqskqvnr
        // allows the view context to automatically merge data synced (imported) from the server.
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // sets the merge conflict strategy. If this property is not set, Core Data will default to using NSErrorMergePolicy as the conflict resolution strategy (do not handle any conflicts, directly report an error), which will cause iCloud data to not merge correctly into the local database.
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        do {
              try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
             fatalError("Failed to pin viewContext to the current generation:\(error)")
        }
    }
}
