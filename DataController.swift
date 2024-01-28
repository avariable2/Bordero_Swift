//
//  DataController.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Model")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load : \(error.localizedDescription)")
            }
        }
    }
    
}
