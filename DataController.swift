//
//  DataController.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import CoreData
import Foundation
import CloudKit

class DataController: ObservableObject {
    let container = NSPersistentCloudKitContainer(name: "Model")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load : \(error.localizedDescription)")
            }
        }
    }
    
}
